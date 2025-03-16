`timescale 1ns/1ps

// =============================================================
// Interface Definition
// =============================================================
interface mac_if(input logic clk, input logic rst_mem);
	logic mul_mem_en;
	logic ac_mem_en;
	logic [7:0] img_in;
	logic [7:0] weight_in;
	logic [21:0] mac_out;
endinterface

// =============================================================
// DUT: Multiply-and-Accumulate (MAC) Module
// =============================================================
module mac_m #(parameter IN_WIDTH = 8, OUT_WIDTH = 22)
(
	output logic [OUT_WIDTH-1:0] mac_out,
	input  logic clk,
	input  logic rst_mem,
	input  logic mul_mem_en,
	input  logic ac_mem_en,
	input  logic [IN_WIDTH-1:0] img_in,
	input  logic [IN_WIDTH-1:0] weight_in
);
	// Internal signals
	logic [IN_WIDTH*2-1:0] mul_result;  // 16-bit product
	logic [IN_WIDTH*2-1:0] mul_register;
	logic [OUT_WIDTH-1:0] acc_register;
	
	// Multiplier (combinational)
	always_comb begin
		mul_result = img_in * weight_in;
	end
	
	// Multiplier register with enable
	always_ff @(posedge clk) begin
		if (rst_mem)
			mul_register <= '0;
		else if (mul_mem_en)
			mul_register <= mul_result;
	end
	
	// Adder and accumulator register with enable
	always_ff @(posedge clk) begin
		if (rst_mem)
			acc_register <= '0;
		else if (ac_mem_en)
			acc_register <= acc_register + {6'b0, mul_register};
	end
	
	// Drive the output
	assign mac_out = acc_register;
endmodule

// =============================================================
// Transaction Item Class
// =============================================================
class mac_item;
	// Randomized stimulus fields
	rand bit         mul_mem_en;
	rand bit         ac_mem_en;
	rand logic [7:0] img_in;
	rand logic [7:0] weight_in;
	// This field will later hold the captured DUT output (for scoreboard use)
	logic [21:0]     captured_dut;
	
	// Constraint: at least one enable must be active.
	constraint enable_valid {
		(mul_mem_en || ac_mem_en) == 1'b1;
	}
	// Constraint: non-zero inputs (if desired)
	constraint non_zero_input {
		img_in    != 0;
		weight_in != 0;
	}
	
	function new();
	endfunction
	
	function void display();
		$display("Transaction - img_in: %0d, weight_in: %0d, mul_mem_en: %b, ac_mem_en: %b, captured DUT: %0d", 
				 img_in, weight_in, mul_mem_en, ac_mem_en, captured_dut);
	endfunction
endclass

// =============================================================
// Driver Class
// =============================================================
class mac_driver;
	virtual mac_if vif;
	mailbox #(mac_item) mbx;
	
	function new(virtual mac_if vif, mailbox #(mac_item) mbx);
		this.vif = vif;
		this.mbx = mbx;
	endfunction
	
	// Generate a fixed number of transactions (64) and drive the DUT.
	task run();
		mac_item tr;
		repeat (64) begin
			tr = new();
			if (!tr.randomize()) begin
				$fatal("Randomization failed");
			end
			// For simplicity, force both enables high.
			tr.mul_mem_en = 1'b1;
			tr.ac_mem_en  = 1'b1;
			
			// Drive the interface
			vif.img_in     = tr.img_in;
			vif.weight_in  = tr.weight_in;
			vif.mul_mem_en = tr.mul_mem_en;
			vif.ac_mem_en  = tr.ac_mem_en;
			
			// Send this transaction to the mailbox for later scoreboard use.
			mbx.put(tr);
			
			@(posedge vif.clk);  // wait one clock cycle
		end
	endtask
endclass

// =============================================================
// Monitor Class
// =============================================================
class mac_monitor;
	virtual mac_if vif;
	mailbox #(mac_item) mbx;
	
	function new(virtual mac_if vif, mailbox #(mac_item) mbx);
		this.vif = vif;
		this.mbx = mbx;
	endfunction
	
	// Capture the DUT output each clock cycle.
	task run();
		mac_item tr;
		forever begin
			@(posedge vif.clk);
			// Try to get a transaction from the mailbox (assuming same order as driver)
			if (mbx.num() > 0) begin
				mbx.get(tr);
				// Capture DUT output at this cycle
				tr.captured_dut = vif.mac_out;
				// Optionally, display the captured output
				$display("Monitor - Captured DUT Output: %0d", tr.captured_dut);
				// Place the transaction back into the mailbox for the scoreboard.
				mbx.put(tr);
			end
		end
	endtask
endclass

// =============================================================
// Scoreboard Class
// =============================================================
class mac_scoreboard;
	function void check_results(mac_item transactions[$]);
		mac_item last;
		mac_item tr;
		int unsigned stored_product;
		int unsigned expected_accum;
		int i;
		
		stored_product = 0;
		expected_accum = 0;
		for (i = 0; i < transactions.size(); i++) begin
			tr = transactions[i];
			if (tr.mul_mem_en)
				stored_product = tr.img_in * tr.weight_in;
			if (tr.ac_mem_en)
				expected_accum = expected_accum + stored_product;
		end
		
		last = transactions[transactions.size()-1];
		$display("Scoreboard - Computed Expected Accumulation: %0d", expected_accum);
		if (expected_accum !== last.captured_dut)
			$error("MAC Mismatch! Expected: %0d, Got: %0d", expected_accum, last.captured_dut);
		else
			$display("MAC PASS: Expected = Actual = %0d", expected_accum);
	endfunction
endclass
// =============================================================
// Top-Level Testbench Module
// =============================================================
module mac_tb;
	// Clock and reset signals
	logic clk;
	logic rst_mem;
	
	// Instantiate interface (binds signals to the DUT)
	mac_if intf(clk, rst_mem);
	
	// Instantiate the DUT
	mac dut (
		.clk(intf.clk),
		.rst_mem(intf.rst_mem),
		.mul_mem_en(intf.mul_mem_en),
		.ac_mem_en(intf.ac_mem_en),
		.img_in(intf.img_in),
		.weight_in(intf.weight_in),
		.mac_out(intf.mac_out)
	);
	
	// Clock generation: 10 ns period
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	// Reset generation: assert for a few cycles then deassert.
	initial begin
		rst_mem = 1;
		#12;  // Hold reset a little longer than one cycle
		rst_mem = 0;
	end
	
	// Create a mailbox for transactions.
	mailbox #(mac_item) mbx;
	
	// A dynamic array to log transactions for scoreboard analysis.
	mac_item transaction_log[$];
	
	// Instantiate verification objects
	mac_driver   driver;
	mac_monitor  monitor;
	mac_scoreboard scoreboard;
	
	initial begin
		mbx = new();
		driver = new(intf, mbx);
		monitor = new(intf, mbx);
		scoreboard = new();
		
		// Launch driver and monitor concurrently.
		fork
			driver.run();
			// Run monitor for a sufficient number of clock cycles to cover all transactions.
			begin
				// Let?s run for 65 clock cycles (one extra to capture final DUT output)
				repeat (65) begin
					@(posedge clk);
					// If a transaction is available, capture it into our log.
					if (mbx.num() > 0) begin
						mac_item tr;
						// Remove the transaction and store it.
						mbx.get(tr);
						transaction_log.push_back(tr);
						// Put it back into the mailbox for further monitor/scoreboard use.
						mbx.put(tr);
					end
				end
			end
		join
		
		// Wait a little extra for any pending updates.
		#20;
		// Call the scoreboard to compare the golden model?s computed accumulation with the DUT output.
		scoreboard.check_results(transaction_log);
		
		#10;
		$finish;
	end
endmodule
