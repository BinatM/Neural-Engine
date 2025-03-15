`include "mac_item.sv"

module mac_tb;
	logic clk;
	logic rst_mem;
	
	// Instantiate interface
	mac_if intf(clk, rst_mem);
	
	// Mailbox for communication between Driver and Monitor
	mailbox #(mac_item) mbx;
	
	// Instantiate DUT
	mac dut (
		.clk(intf.clk),
		.rst_mem(intf.rst_mem),
		.mul_mem_en(intf.mul_mem_en),
		.ac_mem_en(intf.ac_mem_en),
		.img_in(intf.img_in),
		.weight_in(intf.weight_in),
		.mac_out(intf.mac_out)
	);
	
	// Clock generation
	initial begin
		clk = 0;
		forever #5 clk = ~clk; // 10ns clock cycle
	end
	
	// Driver Logic (Inside TB)
	task mac_driver();
		mac_item tr;
		forever begin
			tr = new();
			void'(tr.randomize());
	
			intf.img_in = tr.img_in;
			intf.weight_in = tr.weight_in;
			intf.mul_mem_en = tr.mul_mem_en;
			intf.ac_mem_en = tr.ac_mem_en;
			
			#10; // Wait for clock cycle
		end
	endtask
	
	// Monitor Logic (Inside TB)
	task mac_monitor();
		forever begin
			#10;
			$display("Monitor - MAC Output: %0d", intf.mac_out);
		end
	endtask
	
	initial begin
		mbx = new();  // Initialize mailbox
		rst_mem = 1;
		#10 rst_mem = 0;
	
		fork
			mac_driver();  // Run driver task
			mac_monitor(); // Run monitor task
		join_none
	
		#500;
		$finish;
	end
endmodule