class mac_item;
	rand logic mul_mem_en;
	rand logic ac_mem_en;
	rand logic [7:0] img_in;
	rand logic [7:0] weight_in;
	logic [21:0] mac_out;
	static int cycle_counter = 0 ;

	// Constraints to enforce correct timing
	constraint mul_mem_en_timing {
		if (cycle_counter >= 2 && cycle_counter < 66) // Start after reset, last for 64 cycles
			mul_mem_en == 1;
		else
			mul_mem_en == 0;
	}

	constraint ac_mem_en_timing {
		if (cycle_counter >= 3 && cycle_counter < 67) // Delayed by one cycle
			ac_mem_en == 1;
		else
			ac_mem_en == 0;
	}
	
	constraint non_zero_input {
		(cycle_counter >= 2 && cycle_counter < 66) -> (img_in != 0 && weight_in != 0);
		(cycle_counter < 2 || cycle_counter >= 66) -> (img_in == 0 && weight_in == 0);
	}

	
	function new();
	endfunction
	
	function void post_randomize();
		$display("Cycle %0d: mul_mem_en=%b, ac_mem_en=%b, img_in=%0d, weight_in=%0d", 
				 cycle_counter, mul_mem_en, ac_mem_en, img_in, weight_in);
		cycle_counter++; // Increment counter after each cycle
	endfunction


endclass