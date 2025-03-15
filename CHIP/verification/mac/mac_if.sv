interface mac_if(input logic clk, input logic rst_mem);
	logic mul_mem_en;
	logic ac_mem_en;
	logic [7:0] img_in;
	logic [7:0] weight_in;
	logic [21:0] mac_out;
endinterface : mac_if