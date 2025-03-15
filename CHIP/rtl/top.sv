module top;
	// Clock and Reset
	logic clk;
	logic rst_mem;
	
	// Control Signals
	logic mul_mem_en, ac_mem_en, threshold_ready, output_ready, rd_en, wr_en, chip_sel;
	logic [5:0] rd_data_ptr, wr_data_ptr;
	
	// Data Signals
	logic [7:0] input_mem_data, weights_mem_data;
	logic [21:0] mac_out, threshold_value;
	logic binary_result;
	
	// Clock generation (10ns period)
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	// Instantiate I/O Block (Handles external communication)
	neuron_io io_inst (
		.clk(clk),
		.bus(),                 // Need to connect this to an external source
		.wr_en(wr_en),
		.rd_en(rd_en),
		.chip_sel(chip_sel),
		.threshold_ready(threshold_ready),
		.threshold(threshold_value)
	);
	
	// Instantiate Control Unit (Handles FSM and control signals)
	control_unit ctrl_inst (
		.clk(clk),
		.chip_sel(chip_sel),
		.wr_en(wr_en),
		.threshold_ready(threshold_ready),
		.rst_mem(rst_mem),
		.mul_mem_en(mul_mem_en),
		.ac_mem_en(ac_mem_en),
		.output_ready(output_ready),
		.wr_data_ptr(wr_data_ptr),
		.rd_data_ptr(rd_data_ptr)
	);
	
			
	// Instantiate Input Memory
	input_memory input_mem (
		.clk(clk),
		.data_in(input_mem_data),
		.data_out(input_mem_data),
		.wr_data_ptr(wr_data_ptr),
		.rd_data_ptr(rd_data_ptr)
	);
	
	// Instantiate Weights Memory (Same module as input memory)
	input_memory weights_mem (
		.clk(clk),
		.data_in(weights_mem_data),
		.data_out(weights_mem_data),
		.wr_data_ptr(wr_data_ptr),
		.rd_data_ptr(rd_data_ptr)
	);
	
	// Instantiate MAC Unit
	mac mac_inst (
		.clk(clk),
		.rst_mem(rst_mem),
		.mul_mem_en(mul_mem_en),
		.ac_mem_en(ac_mem_en),
		.img_in(input_mem_data),
		.weight_in(weights_mem_data),
		.mac_out(mac_out)
	);
	
	// Instantiate Activation Function (Includes Output Register)
	activation_function activation_inst (
		.clk(clk),
		.threshold_ready(threshold_ready),
		.mac_output(mac_out),
		.input_bus(threshold_value),
		.output_memory(binary_result)
	);

endmodule