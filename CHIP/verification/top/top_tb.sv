// File: verification/env/top_tb.sv
`timescale 1ns/1ps

import trans_pkg::*;

module top_tb;
  // clock gen
  logic clk = 0; always #5 clk = ~clk;

  // interface instance
  tb_if vif(.clk(clk));

  // mailboxes
  mailbox #(trans_item)   m2drv = new();
  mailbox #(trans_item)   m2mon = new();
  mailbox #(result_item)  m2sb  = new();

  // DUT
  top dut (
	.bus          (vif.bus),
	.clk_in          (clk),
	.wr_en        (vif.wr_en),
	.rd_en        (vif.rd_en),
	.chip_sel     (vif.chip_sel),
	.output_ready (vif.output_ready),
	.output_bit   (vif.output_bit),
	//.mac_result   (vif.mac_result),
	.wr_data_ptr  (vif.wr_data_ptr),
	.rd_data_ptr  (vif.rd_data_ptr),
	.ctrl_state   (vif.ctrl_state),
    .calc_finish_timer(vif.calc_finish_timer)
  );

  // TB components
  generator    gen (.clk(clk),           .m2drv(m2drv));
  driver       drv (.clk(clk), .vif(vif.TB), .m2drv(m2drv), .m2mon(m2mon));
  monitor      mon (.clk(clk), .vif(vif.DUT), .m2mon(m2mon), .m2sb(m2sb));
  scoreboard   sb  (.clk(clk),            .m2sb(m2sb));

endmodule : top_tb