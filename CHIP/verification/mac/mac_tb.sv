`timescale 1ns/1ps

module mac_tb;
  // Clock and reset signals
  logic clk;
  logic rst_mem;
  
  // Instantiate interface (binds signals to the DUT)
  mac_if intf (clk, rst_mem);
  
  // Instantiate the DUT
  mac dut (
	.clk       (intf.clk),
	.rst_mem   (intf.rst_mem),
	.mul_mem_en(intf.mul_mem_en),
	.ac_mem_en (intf.ac_mem_en),
	.img_in    (intf.img_in),
	.weight_in (intf.weight_in),
	.mac_out   (intf.mac_out)
  );
  
  // Clock generation: 10 ns period
  initial begin
	clk = 0;
	forever #5 clk = ~clk;
  end
  
  // Reset generation: assert reset for 10 ns then deassert
  initial begin
	rst_mem = 1;
	#10;
	rst_mem = 0;
  end
  
  // Mailboxes for transaction passing
  mailbox #(mac_item) generator_to_driver_mailbox;
  mailbox #(mac_item) monitor_to_scoreboard_mailbox;
  
  // =============================================================
  // Transaction Generator Task
  // =============================================================
  task Generator();
	mac_item item;
	repeat (70) begin
	  item = new();
	  // Randomize the transaction (constraints inside mac_item will apply)
	  if (!item.randomize())
		$error("Randomization failed");
	  generator_to_driver_mailbox.put(item);
	end
  endtask

  // =============================================================
  // Driver Task
  // =============================================================
  task Driver();
	mac_item item;
	forever begin
	  generator_to_driver_mailbox.get(item);
	  // Apply stimulus from the transaction
	  intf.img_in     = item.img_in;
	  intf.weight_in  = item.weight_in;
	  intf.mul_mem_en = item.mul_mem_en;
	  intf.ac_mem_en  = item.ac_mem_en;
	  @(posedge clk);
	  // Deassert control signals after one clock cycle
	  intf.mul_mem_en = 1'b0;
	  intf.ac_mem_en  = 1'b0;
	end
  endtask 
  
  // =============================================================
  // Monitor Task
  // =============================================================
  task Monitor();
	  mac_item item;
	  forever begin
		@(posedge clk);
		// Capture DUT output only when accumulator enable is active
		if (intf.ac_mem_en) begin
		  #1; // Small delay for stabilization
		  item = new();
		  item.mac_out = intf.mac_out;
		  //$display("Monitor: mac_out = %0d", item.mac_out);
		  monitor_to_scoreboard_mailbox.put(item);
		end
	  end
	endtask
  
  // =============================================================
  // Scoreboard Task
  // =============================================================
  task Scoreboard();
	mac_item item;
	int expected_accum, stored_product;
	expected_accum = 0;
	stored_product = 0;
	
	forever begin
	  monitor_to_scoreboard_mailbox.get(item);
	  
	  // If reset is active, reset expected values immediately
	  if (rst_mem) begin
		expected_accum = 0;
		stored_product = 0;
	  end else begin
		// Compute expected product if mul_mem_en was asserted
		if (item.mul_mem_en)
		  stored_product = item.img_in * item.weight_in;
		// When accumulator enable is active, update expected accumulation
		if (item.ac_mem_en)
		  expected_accum = expected_accum + stored_product;
	  end
	  
	  // For demonstration, print expected accumulation each cycle
	  $display("Scoreboard: Expected Accumulation = %0d, DUT mac_out = %0d", expected_accum, item.mac_out);
	  
	  // If the transaction mailbox is empty, perform final validation
	  if (monitor_to_scoreboard_mailbox.num() == 0) begin
		if (expected_accum !== item.mac_out)
		  $error("MAC Mismatch! Expected: %0d, Got: %0d", expected_accum, item.mac_out);
		else
		  $display("MAC PASS: Expected = Actual = %0d", expected_accum);
		disable Scoreboard;
	  end
	end

  endtask
  
  // =============================================================
  // Simulation Control Task
  // =============================================================
  task Simulation();
	// Initialize mailboxes
	generator_to_driver_mailbox = new();
	monitor_to_scoreboard_mailbox = new();
	
	// Wait for reset deassertion
	wait (rst_mem == 0);
	@(posedge clk);
	
	// Run all tasks in parallel
	fork
	  Generator();
	  Driver();
	  Monitor();
	  Scoreboard();
	join
	
	#10;
	$finish;
  endtask
  
  // Start simulation
  initial begin
	Simulation();
  end

endmodule
