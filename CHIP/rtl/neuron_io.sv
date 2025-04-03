module neuron_io (
	input  logic        clk,           // Clock
	inout wire [15:0] bus, 			   // 16-bit bidirectional I/O bus

	// Control inputs from the board
	input  logic        rd_en,
	input  logic        wr_en,
	input  logic        chip_sel,

	// Output control signals from internal modules
	input  logic        output_ready,  // From control_unit
	input  logic        output_bit,    // From activation_function
	input  logic [21:0] mac_result,    // 22-bit MAC result

	// Decoded outputs
	output logic [7:0]  img_data,      // Input image pixel
	output logic [7:0]  weight_data,   // Corresponding weight
	output logic [15:0] threshold_data // Used during threshold loading
);

	logic [15:0] bus_out;
	logic        bus_oe; // output enable signal for tri-state buffer
	logic 		 read_cycle_cnt;

	// Bus tri-state logic
	assign bus = (bus_oe) ? bus_out : 16'bz;

	// WRITE PHASE (Read from bus into internal signals)
	always_ff @(posedge clk) begin
		if (chip_sel && wr_en) begin
			img_data       <= bus[7:0];
			weight_data    <= bus[15:8];
			threshold_data <= bus; 
		end
	end

	// READ cycle counter
	always_ff @(posedge clk) begin
		if (chip_sel && !rd_en)
			read_cycle_cnt <= 1'b0;
		else if (chip_sel && rd_en)
			read_cycle_cnt <= ~read_cycle_cnt;
	end
	
	// READ phase: drive bus
	always_comb begin
		bus_out = 16'h0000;
		bus_oe  = 1'b0;

		if (chip_sel && rd_en) begin
			bus_out = (read_cycle_cnt) ? {6'b0, mac_result[21:16]} : mac_result[15:0];
			bus_oe  = 1'b1;
		end
	end
	

endmodule