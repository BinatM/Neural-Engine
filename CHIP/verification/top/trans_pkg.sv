package trans_pkg;

	// Transaction for input sequence
	class trans_item;
	  // Pixel and weight arrays: default fixed values 0..63
	  bit [7:0]           pixel       [0:63];
	  bit [7:0]           weight      [0:63];
	  // Packed data word [15:0] = {weight, pixel}
	  bit [15:0]          data        [0:63];

	  // Randomizable threshold, but fixed-write-enable delays by default
	  rand bit [21:0]     threshold;
	  // Make wr_en_delay non-rand so default zero initialization is preserved
	  int unsigned        wr_en_delay [0:70];

	  // Constructor: initialize defaults
	  function new();
		// Default pixel/weight = 0..63
		for (int i = 0; i < 64; i++) begin
		  pixel[i]  = i;
		  weight[i] = i;
		end
		threshold = 0;
		// Default no stalls
		foreach (wr_en_delay[i])
		  wr_en_delay[i] = 0;
	  endfunction

	  // Pack pixel+weight into data array
	  function void pack_data();
		foreach (data[i]) begin
		  data[i] = { weight[i], pixel[i] };
		end
	  endfunction

	  // Automatically invoked after randomize(): pack data, keep delays at zero
	  function void post_randomize();
		pack_data();
		// wr_en_delay remains as initialized (all zeros)
	  endfunction

	endclass : trans_item

	// Result item passed to scoreboard
	class result_item extends trans_item;
	  bit [21:0]      mac_result;
	  bit             decision;
	  int unsigned    cycle;
	  int unsigned    delay_sum;

	  // Copy constructor: capture original transaction
	  function new(trans_item t = null);
		super.new();
		if (t) begin
		  // Copy pixel/weight/data
		  for (int i = 0; i < 64; i++) begin
			this.pixel[i]       = t.pixel[i];
			this.weight[i]      = t.weight[i];
			this.data[i]        = t.data[i];
		  end
		  this.threshold        = t.threshold;
		  foreach (t.wr_en_delay[i])
			this.wr_en_delay[i] = t.wr_en_delay[i];
		end
	  endfunction

	endclass : result_item

  endpackage : trans_pkg
