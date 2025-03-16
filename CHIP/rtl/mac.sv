`timescale 1ns/1ps

module mac #(parameter IN_WIDTH = 8, OUT_WIDTH = 22)
(
	output logic [OUT_WIDTH-1:0] mac_out,

	input  logic clk,
	input  logic rst_mem,
	input  logic mul_mem_en,
	input  logic ac_mem_en,
	input  logic [IN_WIDTH-1:0] img_in,
	input  logic [IN_WIDTH-1:0] weight_in
);

	// Signal declarations
	logic [IN_WIDTH*2-1:0] mul_result;     // 16-bit result from multiplier
	logic [IN_WIDTH*2-1:0] mul_register;    // Register to hold multiplier output
	logic [OUT_WIDTH-1:0] acc_register;    // Register to hold Accumulator output
	
	// Multiplier
	always_comb begin
		mul_result = img_in * weight_in;
	end
	

	// Multiplier register with enable
	always_ff @(posedge clk) begin
		if (rst_mem) begin
			mul_register <= '0;  // Reset the register
		end else if (mul_mem_en) begin
			mul_register <= mul_result;  // Zero-extend the mul result to 22-bit width and store it in mul_register
		end
	end
	
	// Adder and Accumulator
	always_ff @(posedge clk) begin
		if (rst_mem) begin
			acc_register <= '0;  // Reset the accumulator register
		end else if (ac_mem_en) begin
			acc_register <= acc_register + {6'b0 ,mul_register};  // Accumulate the result
		end
	end
	
	// Output
	assign mac_out = acc_register;

endmodule
