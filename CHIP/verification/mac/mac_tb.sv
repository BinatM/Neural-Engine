`timescale 1ns/1ps

module mac_tb;
	// Clock and reset signals
	logic clk;
	logic rst_mem;
	
	// Instantiate interface (binds signals to the DUT)
	mac_if intf (clk, rst_mem);
	
	// Instantiate the DUT
	mac dut (
		.clk       (intf.clk       ),
		.rst_mem   (intf.rst_mem   ),
		.mul_mem_en(intf.mul_mem_en),
		.ac_mem_en (intf.ac_mem_en ),
		.img_in    (intf.img_in    ),
		.weight_in (intf.weight_in ),
		.mac_out   (intf.mac_out   )
	);
	
	// Clock generation: 10 ns period
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	// Reset generation: assert for a few cycles then deassert.
	initial begin
		rst_mem = 1;
		#10;
		rst_mem = 0;
	end
	
	// Create mailboxes for transaction passing
	mailbox #(mac_item) generator_to_driver_mailbox;
	mailbox #(mac_item) monitor_to_scoreboard_mailbox;
	
	// =============================================================
	// Transaction Generator Task
	// =============================================================
	task Generator();
		mac_item item;
		repeat (70) begin
			item = new();
			item.randomize();
			// Ensure mul_mem_en starts only after reset phase
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
			// Apply stimulus
			intf.img_in     = item.img_in;
			intf.weight_in  = item.weight_in;
			intf.mul_mem_en = item.mul_mem_en;
			intf.ac_mem_en  = item.ac_mem_en;
			@(posedge clk); // Wait for clock cycle
			// Deassert control signals
			intf.mul_mem_en = 1'b0;
			intf.ac_mem_en  = 1'b0;
			//monitor_to_scoreboard_mailbox.put(item); // Pass transaction for validation
		end
	endtask 
	
	// =============================================================
	// Monitor Task
	// =============================================================
	task Monitor();
		mac_item item;
		item = new();
		forever begin
			@(posedge clk);
			//if (intf.ac_mem_en) begin  // Ensure MAC operation is happening
			#1;  // Small delay to stabilize output
			item.mac_out = intf.mac_out; // Capture DUT output safely
			$display("mac_out=%0d",item.mac_out);
			monitor_to_scoreboard_mailbox.put(item);// Send to scoreboard
			//end
		end
	endtask
	
	// =============================================================
	// Scoreboard Task
	// =============================================================
	task Scoreboard();
		mac_item item;
		int expected_accum, stored_product;

		// Explicitly initialize to X
		expected_accum = 'x;
		stored_product = 'x;

		forever begin
			monitor_to_scoreboard_mailbox.get(item);

			// Handle reset: Reset expected_accum when rst_mem is high
			if (rst_mem) begin
				expected_accum = '0;  // Reset to X on rst_mem
				stored_product = '0;
			end else begin
				// Normal MAC operations
				if (item.mul_mem_en)
					stored_product = item.img_in * item.weight_in;
				if (item.ac_mem_en)
					expected_accum = (expected_accum === 'x) ? stored_product : expected_accum + stored_product;
			end
			
			// Final validation
			$display("monitor_to_scoreboard_mailbox.num() = %0d", monitor_to_scoreboard_mailbox.num());
			if (monitor_to_scoreboard_mailbox.num() == 0) begin
				$display("Scoreboard - Computed Expected Accumulation: %0d", expected_accum);
				if (expected_accum !== item.mac_out)
					$error("MAC Mismatch! Expected: %0d, Got: %0d", expected_accum, item.mac_out);
				else
					$display("MAC PASS: Expected = Actual = %0d", expected_accum);
				break;
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
		//@(negedge rst_mem);
		@(rst_mem == '1);
		@(posedge clk);
		
		// Start tasks in parallel
		fork
			Generator();
			Driver();
			Monitor();
			Scoreboard();
		join
		
		#10;
		$finish;
	endtask
	
	// Start the simulation
	initial begin
		Simulation();
	end

endmodule