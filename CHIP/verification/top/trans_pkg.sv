// File: verification/env/trans_pkg.sv
package trans_pkg;

  //----------------------------------------------------------------------  
  // Transaction: holds 64 16-bit ?pixel+weight? words, a 22-bit threshold,
  // plus a 71-entry wr_en_delay array (all zero by default).
  //----------------------------------------------------------------------  
  class trans_item;
	rand bit [15:0] data         [0:63];
	rand bit [21:0] threshold;
	int unsigned   wr_en_delay   [0:70];

	function new();
	  foreach (wr_en_delay[i])
		wr_en_delay[i] = 0;    // no delays by default
	endfunction

	// Default: data[i] == i so you get 0,1,2?63 unless you constrain otherwise
	constraint c_data { foreach(data[i]) data[i] == i; }
  endclass

  //----------------------------------------------------------------------  
  // Result: extends trans_item and adds the DUT?s outputs for checking
  //----------------------------------------------------------------------  
  class result_item extends trans_item;
	bit [21:0] mac_result;
	bit        decision;
	int unsigned cycle;      // clock count when output_ready asserted
	int unsigned delay_sum;  // sum of wr_en_delay array

	function new(trans_item t = null);
	  if (t) begin
		this.data         = t.data;
		this.threshold    = t.threshold;
		this.wr_en_delay  = t.wr_en_delay;
	  end
	endfunction
  endclass

endpackage : trans_pkg
