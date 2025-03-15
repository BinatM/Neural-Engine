class mac_item;
	rand logic mul_mem_en;
	rand logic ac_mem_en;
	rand logic [7:0] img_in;
	rand logic [7:0] weight_in;
	logic [21:0] mac_out;

	// Constraints to ensure valid operations
	constraint enable_valid {
		mul_mem_en | ac_mem_en == 1'b1;  // At least one enable signal should be active
	}

	constraint non_zero_input {
		img_in != 0;  // Ensure non-zero input values
		weight_in != 0;
	}

	function new();
	endfunction

	function void display();
		$display("Transaction - img_in: %0d, weight_in: %0d, mul_mem_en: %b, ac_mem_en: %b", 
				  img_in, weight_in, mul_mem_en, ac_mem_en);
	endfunction
endclass