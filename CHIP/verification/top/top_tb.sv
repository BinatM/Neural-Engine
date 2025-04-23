// File: verification/top_tb.sv
`timescale 1ns/1ps
import trans_pkg::*;

module top_tb;

  // Clock generator
  logic clk = 0;
  always #5 clk = ~clk;

  // Shared tri-state bus
  tri [15:0] bus_line;

  // Driver-side bus signals
  logic [15:0] bus_drv;
  logic        bus_drv_en;

  // TB-DUT interface (control + debug)
  tb_if vif (.clk(clk));

  // Connect tri-state driver from testbench to shared bus
  assign bus_line = bus_drv_en ? bus_drv : 16'bz;

  // Instantiate DUT
  top dut (
	.bus          (bus_line),
	.clk          (clk),
	.wr_en        (vif.wr_en),
	.rd_en        (vif.rd_en),
	.chip_sel     (vif.chip_sel),
	.output_ready (vif.output_ready),
	.output_bit   (vif.output_bit),
	.mac_result   (vif.mac_result)
  );

  // Driver sends stimulus to bus
  driver drv (
	.vif         (vif.TB),
	.bus_drv     (bus_drv),
	.bus_drv_en  (bus_drv_en)
  );

  // Monitor samples DUT behavior
  monitor mon (
	.vif      (vif.TB),
	.bus_line (bus_line)
  );

  // Scoreboard checks results
  scoreboard sc (
	.vif (vif.TB)
  );

endmodule : top_tb
