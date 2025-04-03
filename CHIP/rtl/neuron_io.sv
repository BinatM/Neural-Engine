module neuron_io (
	input  logic        clk,              // Clock
	input  logic [15:0] bus,              // 16-bit shared I/O bus

	// Control inputs from the board
	input  logic        rd_en,
	input  logic        wr_en,
	input  logic        chip_sel,

	// Output control signals from internal modules
	input logic        output_ready,     // From control_unit
	input logic        output_bit,       // From activation_function
	input logic [21:0] mac_result,

	// Decoded outputs
	output logic [7:0]  input_data,       // Input image pixel
	output logic [7:0]  weight_data,      // Corresponding weight
	output logic [15:0] threshold_data   // Used during threshold loading
);

	// Parallel extraction of input and weight
	assign input_data    = bus[7:0];
	assign weight_data   = bus[15:8];
	assign threshold_data = bus;
	assign mac_result     = bus;

endmodule