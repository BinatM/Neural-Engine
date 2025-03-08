module neuron_io (
	input  logic [31:0] bus,            // 32-bit shared bus
	input  logic        clk,            // Clock signal
	output logic        output_signal,  // 1-bit output signal
	output logic [15:0] input_data,     // 16-bit input data
	output logic        rd_en,          // Read enable
	output logic        wr_en,          // Write enable
	output logic        chip_sel,       // Chip select
	output logic 		threshold_ready,// threshold enable
	output logic [21:0] threshold       // 22-bit threshold
);

	// Decode the bus signals for normal operation
	assign input_data    	= bus[15:0];   // Input data (bits 0-15)
	assign rd_en         	= bus[16];     // Read enable (bit 16)
	assign wr_en         	= bus[17];     // Write enable (bit 17)
	assign chip_sel      	= bus[18];     // Chip select (bit 18)
	assign threshold_ready 	= bus[20];     // Threshold enable (bit 20)
	assign output_signal 	= bus[21];     // Output signal (bit 21)

	// Allow the user to freely write the threshold via bus[21:0]
	always_ff @(posedge clk) begin
		if (threshold_ready == 1'b1) begin
		threshold <= bus[21:0]; // User writes threshold directly to bits 0-21
		end
	end
endmodule
