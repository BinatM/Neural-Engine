module top;
	//Clock Input (I/O)
	logic clk;
	
	// Bus (I/O)
	logic [31:0] bus;
	
	// Control Signals
	logic wr_en, rd_en, chip_sel, threshold_ready;
	logic output_ready, output_signal;
	logic rst_mem, mul_mem_en, ac_mem_en;
	logic [5:0] wr_data_ptr, rd_data_ptr;
	
	// Threshold & Data
	logic [15:0] input_data;
	logic [21:0] threshold_value;
	logic [7:0] input_mem_out, weights_mem_out;
	
	// MAC Output
	logic [21:0] mac_out;
	
	// I/O Module
	neuron_io io_inst (
		.clk(clk),
		.bus(bus),
		.output_signal(output_signal),
		.input_data(input_data),
		.rd_en(rd_en),
		.wr_en(wr_en),
		.chip_sel(chip_sel),
		.threshold_ready(threshold_ready),
		.threshold(threshold_value)
	);
	
	// Control Unit
	control_unit ctrl_inst (
		.clk(clk),
		.chip_sel(chip_sel),
		.wr_en(wr_en),
		.rst_mem(rst_mem),
		.mul_mem_en(mul_mem_en),
		.ac_mem_en(ac_mem_en),
		.output_ready(output_ready),
		.wr_data_ptr(wr_data_ptr),
		.rd_data_ptr(rd_data_ptr),
		.threshold_ready(threshold_ready)
	);
	
	// Input Memory (Image)
	input_memory image_mem (
		.clk(clk),
		.data_in(input_data),      // lower 8 bits
		.data_out(input_mem_out),
		.wr_data_ptr(wr_data_ptr),
		.rd_data_ptr(rd_data_ptr)
	);
	
	// Weights Memory
	input_memory weight_mem (
		.clk(clk),
		.data_in(weight_data),      // same input_data
		.data_out(weights_mem_out),
		.wr_data_ptr(wr_data_ptr),
		.rd_data_ptr(rd_data_ptr)
	);
	
	// MAC Unit
	mac mac_inst (
		.clk(clk),
		.rst_mem(rst_mem),
		.mul_mem_en(mul_mem_en),
		.ac_mem_en(ac_mem_en),
		.img_in(input_mem_out),
		.weight_in(weights_mem_out),
		.mac_out(mac_out)
	);
	
	// Activation Function
	activation_function activation_inst (
		.clk(clk),
		.threshold_ready(threshold_ready),
		.mac_output(mac_out),
		.input_bus(input_data),             // threshold parts come from bus[15:0]
		.output_memory(output_signal)
	);

endmodule