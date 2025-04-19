module top (
	inout tri [15:0] bus,
	input logic clk,
	input logic wr_en,
	input logic rd_en,
	input logic chip_sel
);

// 16-bit bidirectional I/O Bus

// External control signals (driven by testbench or board)

// Internal control signals from the Control Unit
logic rst_mem, mul_mem_en, ac_mem_en;
logic output_ready, threshold_ready;
logic [5:0] wr_data_ptr, rd_data_ptr;

// Neuron I/O decoded outputs
logic [7:0] img_data;       // Decoded image pixel (data)
logic [7:0] weight_data;    // Decoded weight data
logic [15:0] threshold_data; // Decoded threshold (lower 16 bits)

// Memory outputs (to be fed to the MAC unit)
logic [7:0] image_mem_out, weight_mem_out;

// MAC and Activation internal signals
logic [21:0] mac_out;       // MAC output (22-bit)
logic output_bit;           // 1-bit output from activation function

//-------------------------------------------------------------------------
// Neuron I/O Module (Handles bidirectional bus and decodes signals)
//-------------------------------------------------------------------------
neuron_io io_inst (
	.clk(clk),
	.bus(bus),
	.rd_en(rd_en),
	.wr_en(wr_en),
	.chip_sel(chip_sel),
	.output_ready(output_ready),
	.output_bit(output_bit),
	.mac_result(mac_out),
	.img_data(img_data),
	.weight_data(weight_data),
	.threshold_data(threshold_data)
);

//-------------------------------------------------------------------------
// Control Unit
//-------------------------------------------------------------------------
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

//-------------------------------------------------------------------------
// Input Memory (Image)
//-------------------------------------------------------------------------
input_memory image_mem (
	.clk(clk),
	.data_in(img_data),          // Drive from neuron_io's decoded image data
	.data_out(image_mem_out),    // Output to MAC unit
	.wr_data_ptr(wr_data_ptr),
	.rd_data_ptr(rd_data_ptr)
);

//-------------------------------------------------------------------------
// Weights Memory
//-------------------------------------------------------------------------
input_memory weight_mem (
	.clk(clk),
	.data_in(weight_data),       // Drive from neuron_io's decoded weight data
	.data_out(weight_mem_out),   // Output to MAC unit
	.wr_data_ptr(wr_data_ptr),
	.rd_data_ptr(rd_data_ptr)
);

//-------------------------------------------------------------------------
// MAC Unit
//-------------------------------------------------------------------------
mac mac_inst (
	.clk(clk),
	.rst_mem(rst_mem),
	.mul_mem_en(mul_mem_en),
	.ac_mem_en(ac_mem_en),
	.img_in(image_mem_out),
	.weight_in(weight_mem_out),
	.mac_out(mac_out)
);

//-------------------------------------------------------------------------
// Activation Function
//-------------------------------------------------------------------------
activation_function activation_inst (
	.clk(clk),
	.threshold_ready(threshold_ready),
	.mac_output(mac_out),
	.input_bus(threshold_data),   // Use threshold_data from neuron_io
	.output_memory(output_bit)
);

// Test stimulus for chip_sel, wr_en, rd_en can be applied in a separate testbench.

endmodule
