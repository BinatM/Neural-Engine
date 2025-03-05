module input_memory (
	input logic clk,   //Clock input
	input logic [7:0] data_in, //8-bit data input
	output logic [7:0] data_out, 
	
	// Write and read pointers
	input logic [5:0] wr_data_ptr, // Write pointer (6 bits to address 64 locations)
	input logic [5:0] rd_data_ptr // read pointer (6 bits to address 64 locations)
);
	//Memory array def
	logic [7:0] mem [0:63]; // 64x8 memory array (64 locations, 8 bits each)
	
	//Write operation
	always_ff @(posedge clk) begin
		mem[wr_data_ptr] <= data_in;
	end
	
	//read operation
	always_ff @(posedge clk) begin
		data_out <= mem[rd_data_ptr];
	end
	
endmodule