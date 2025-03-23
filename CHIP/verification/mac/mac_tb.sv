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
	
	// Clock generation: 20 ns period
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
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
		repeat (67) begin
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
		@(negedge rst_mem);
		@(posedge clk);
		
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
			$display("Driver puts: img_in=%0d weight_in=%0d mul_en=%0b ac_en=%0b",
					intf.img_in, intf.weight_in, intf.mul_mem_en, intf.ac_mem_en);
		end
	endtask 
	
	// =============================================================
	// Monitor Task
	// =============================================================
	task Monitor();
		mac_item item;
		
		forever begin
			@(posedge clk);
			#1
			item = new();
			item.img_in     = intf.img_in;
			item.weight_in  = intf.weight_in;
			item.mul_mem_en = intf.mul_mem_en;
			item.ac_mem_en  = intf.ac_mem_en;
			item.rst_mem    = intf.rst_mem;
			item.mac_out    = intf.mac_out;
			monitor_to_scoreboard_mailbox.put(item);
			//$display("Monitor - mul_en=%0b, ac_en=%0b, img=%0d, weight=%0d, mac_out=%0d",
					//item.mul_mem_en, item.ac_mem_en, item.img_in, item.weight_in, item.mac_out);
		end
	endtask
	
	// =============================================================
	// Scoreboard Task
	// =============================================================
	task automatic Scoreboard();
		mac_item item;
		int expected_accum = 0;
		int stored_product = 0;
		bit first_ac = 1;
		bit started = 0;

		forever begin
			monitor_to_scoreboard_mailbox.get(item);

			if (!started) begin
				if (!item.rst_mem) begin
					started = 1;
					$display("Scoreboard started after reset deasserted.");
				end
				continue;
			end

			if (item.rst_mem) begin
				expected_accum = 0;
				stored_product = 0;
				first_ac = 1;
				continue;
			end

			if (item.mul_mem_en)
				stored_product = item.img_in * item.weight_in;

			if (item.ac_mem_en) begin
				if (first_ac)
					expected_accum = stored_product;
				else
					expected_accum += stored_product;
				first_ac = 0;
			end
			$display("DEBUG - mul_en=%0b, ac_en=%0b, img=%0d, weight=%0d, product=%0d, accumulated=%0d, mac_out=%0d",
					item.mul_mem_en, item.ac_mem_en, item.img_in, item.weight_in, stored_product, expected_accum, item.mac_out);

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
		@(negedge rst_mem);
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