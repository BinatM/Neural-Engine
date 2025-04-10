module top;
// Clock
logic clk;

// 16-bit bidirectional I/O Bus
wire [15:0] bus;

// External control signals (driven by testbench or board)
logic wr_en, rd_en, chip_sel;

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

// -------------------------------------------------------------------------
// Input Memory (Image SRAM)
// -------------------------------------------------------------------------
TS6N28HPCPHVTA64X8M4FWBSO image_mem (
	.AA(wr_data_ptr),      // Write address (6 bits)
	.D(img_data),          // Write data (8-bit pixel value)
	.BWEB(8'b0),           // Bit-wise write enable (active low), 0 = all enabled
	.WEB(1'b0),            // Write enable (active low), 0 = write enabled
	.CLKW(clk),            // Write clock

	.AB(rd_data_ptr),      // Read address (6 bits)
	.REB(1'b0),            // Read enable (active low), 0 = read enabled
	.CLKR(clk),            // Read clock

	.SLP(1'b0),            // Sleep mode control, 0 = normal mode
	.SD(1'b0),             // Shutdown mode control, 0 = normal mode

	.AMA(6'b0),            // Test write address (not used, tie to 0)
	.DM(8'b0),             // Test write data (not used, tie to 0)
	.BWEBM(8'b0),          // Test bit-wise write enable (not used)
	.WEBM(1'b1),           // Test write enable (1 = disabled)
	.AMB(6'b0),            // Test read address (not used)
	.REBM(1'b1),           // Test read enable (1 = disabled)
	.BIST(1'b0),           // BIST enable (0 = disabled)

	.Q(image_mem_out)      // Read data output (8-bit)
);

// -------------------------------------------------------------------------
// Weights Memory (Weight SRAM)
// -------------------------------------------------------------------------
TS6N28HPCPHVTA64X8M4FWBSO weight_mem (
	.AA(wr_data_ptr),      // Write address
	.D(weight_data),       // Write data (8-bit weight)
	.BWEB(8'b0),           // Bit-wise write enable (active low)
	.WEB(1'b0),            // Write enable (active low)
	.CLKW(clk),            // Write clock

	.AB(rd_data_ptr),      // Read address
	.REB(1'b0),            // Read enable (active low)
	.CLKR(clk),            // Read clock

	.SLP(1'b0),            // Sleep control
	.SD(1'b0),             // Shutdown control

	.AMA(6'b0),            // Test write address (not used)
	.DM(8'b0),             // Test write data (not used)
	.BWEBM(8'b0),          // Test bit-wise write enable (not used)
	.WEBM(1'b1),           // Test write enable (1 = off)
	.AMB(6'b0),            // Test read address (not used)
	.REBM(1'b1),           // Test read enable (1 = off)
	.BIST(1'b0),           // BIST (0 = off)

	.Q(weight_mem_out)     // Read data output
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

//-------------------------------------------------------------------------
// Clock Generation (for simulation)
//-------------------------------------------------------------------------
initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

// Test stimulus for chip_sel, wr_en, rd_en can be applied in a separate testbench.

endmodule
