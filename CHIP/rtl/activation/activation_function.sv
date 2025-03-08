module activation_function #(parameter WIDTH = 22, BUS_WIDTH = 16)
(
	output logic output_memory,                 // 1-bit output

	input  logic clk,
	input  logic threshold_ready,               // Signal to load threshold value
	input  logic [WIDTH-1:0] mac_output,        // MAC output
	input  logic [BUS_WIDTH-1:0] input_bus     // Threshold value from input bus
);

	// Threshold register to hold the threshold value
	logic [WIDTH-1:0] threshold_register;
	logic cycle_counter;          // Counter to track the two cycles

	// Load threshold value into the register when threshold_ready is high
	 always_ff @(posedge clk) begin
		 if (threshold_ready) begin
			 if (cycle_counter == 1'b0) begin
				 // First cycle: Load the first 16 bits from the input bus
				 threshold_register[BUS_WIDTH-1:0] <= input_bus;
				 cycle_counter <= 1'b1;  // Move to the second cycle
			 end else begin
				 // Second cycle: Load the next 16 bits and truncate to 22 bits
				 threshold_register[WIDTH-1:BUS_WIDTH] <= input_bus[WIDTH-BUS_WIDTH-1:0];
				 cycle_counter <= 1'b0;  // Reset the counter
			 end
		 end else begin
			 cycle_counter <= 1'b0;  // Reset the counter when threshold_ready is low
		 end
	 end

	// Comparator to compare MAC output with the threshold
	always_comb begin
		if (mac_output > threshold_register) begin
			output_memory = 1'b1;  // Output 1 if MAC output is greater than threshold
		end else begin
			output_memory = 1'b0;  // Output 0 otherwise
		end
	end

endmodule