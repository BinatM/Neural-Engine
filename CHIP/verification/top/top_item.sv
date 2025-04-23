class top_item;
	rand logic [7:0] img_in;
	rand logic [7:0] weight_in;
	rand logic [21:0] threshold;
	logic output_bit;

	function void print();
		$display("ITEM: img=%0d, weight=%0d, threshold=%0d, out=%0b", img_in, weight_in, threshold, output_bit);
	endfunction
endclass
