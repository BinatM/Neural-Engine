// This top-level wraps the original 'top' module with IO cells for physical design.
// Only used in ASIC flow (PD), not in simulation or FPGA.

module top_io (
	input  wire        PAD_wr_en,
	input  wire        PAD_chip_sel,
	input  wire        PAD_clk,
	input  wire [15:0] PAD_bus,
	output wire        PAD_output_ready,
	output wire        PAD_output
);

  // Internal signals after level shifting
  wire        wr_en_internal;
  wire        chip_sel_internal;
  wire        clk_internal;
  wire [15:0] bus_internal;
  wire        output_ready_internal;
  wire        output_internal;

  // IO Input Cells (PRUW - input with level shifter 1.8V to 0.9V)
  // PRUW08DGZ_H_G pins: PAD, I, REN, OEN, C
  PRUW08DGZ_H_G io_wr_en (
	.PAD (PAD_wr_en),
	.I   (wr_en_internal),
	.REN (1'b1),      // always enable read
	.OEN (1'b1),      // always disable drive
	.C   (1'b0)       // tie-off control
  );

  PRUW08DGZ_H_G io_chip_sel (
	.PAD (PAD_chip_sel),
	.I   (chip_sel_internal),
	.REN (1'b1),
	.OEN (1'b1),
	.C   (1'b0)
  );

  PRUW08DGZ_H_G io_clk (
	.PAD (PAD_clk),
	.I   (clk_internal),
	.REN (1'b1),
	.OEN (1'b1),
	.C   (1'b0)
  );

  // 16-bit data bus inputs
  PRUW08DGZ_H_G io_bus_0  (.PAD(PAD_bus[0] ), .I(bus_internal[0] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_1  (.PAD(PAD_bus[1] ), .I(bus_internal[1] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_2  (.PAD(PAD_bus[2] ), .I(bus_internal[2] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_3  (.PAD(PAD_bus[3] ), .I(bus_internal[3] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_4  (.PAD(PAD_bus[4] ), .I(bus_internal[4] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_5  (.PAD(PAD_bus[5] ), .I(bus_internal[5] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_6  (.PAD(PAD_bus[6] ), .I(bus_internal[6] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_7  (.PAD(PAD_bus[7] ), .I(bus_internal[7] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_8  (.PAD(PAD_bus[8] ), .I(bus_internal[8] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_9  (.PAD(PAD_bus[9] ), .I(bus_internal[9] ), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_10 (.PAD(PAD_bus[10]), .I(bus_internal[10]), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_11 (.PAD(PAD_bus[11]), .I(bus_internal[11]), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_12 (.PAD(PAD_bus[12]), .I(bus_internal[12]), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_13 (.PAD(PAD_bus[13]), .I(bus_internal[13]), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_14 (.PAD(PAD_bus[14]), .I(bus_internal[14]), .REN(1'b1), .OEN(1'b1), .C(1'b0));
  PRUW08DGZ_H_G io_bus_15 (.PAD(PAD_bus[15]), .I(bus_internal[15]), .REN(1'b1), .OEN(1'b1), .C(1'b0));

  // IO Output Cells (PDDW - output with level shifter 0.9V to 1.8V)
  // PDDW08DGZ_H_G pins: I, PAD, OEN, REN, C
  PDDW08DGZ_H_G io_output_ready (
	.I   (output_ready_internal),
	.PAD (PAD_output_ready),
	.OEN (1'b0),      // drive always enabled
	.REN (1'b0),      // read disabled
	.C   (1'b0)       // tie-off control
  );

  PDDW08DGZ_H_G io_output (
	.I   (output_internal),
	.PAD (PAD_output),
	.OEN (1'b0),
	.REN (1'b0),
	.C   (1'b0)
  );

  // Instantiate the core logic
  top core_inst (
	.clk_in            (clk_internal),
	.bus               (bus_internal),
	.wr_en             (wr_en_internal),
	.chip_sel          (chip_sel_internal),
	.output_ready      (output_ready_internal),
	.output_bit        (output_internal)
  );

endmodule
