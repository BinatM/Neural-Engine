module activation_function #(parameter WIDTH = 22)
(
	output logic output_memory,                 // 1-bit output

	input  logic clk,
	input  logic threshold_ready,               // Signal to load threshold value
	input  logic [WIDTH-1:0] mac_output,        // MAC output
	input  logic [WIDTH-1:0] threshold_data     // Threshold value from input bus
);

	// Threshold register to hold the threshold value
	logic [WIDTH-1:0] threshold_register;

	// Load threshold value into the register when threshold_ready is high
	always_ff @(posedge clk) begin
		if (threshold_ready) begin
			threshold_register <= threshold_data;
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