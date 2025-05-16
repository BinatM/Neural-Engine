// File: verification/env/generator.sv
`timescale 1ns/1ps
import trans_pkg::*;

module generator (
 // input  logic            clk,
  // mailbox to driver
  ref mailbox #(trans_item) m2drv
);
  initial begin
	trans_item item;
	item = new();
	if (!item.randomize()) $fatal("trans_item randomization failed");
	$display("GEN: pixel[0]=%0d, ?, pixel[63]=%0d", item.pixel[0], item.pixel[63]);
	$display("GEN: weight[0]=%0d, ?, weight[63]=%0d", item.weight[0], item.weight[63]);
	$display("GEN: threshold=%0d, wr_en_delay_sum=%0d", 
			 item.threshold,  item.wr_en_delay.sum());

	m2drv.put(item);
	$display("GEN: pushed item with threshold=%0d", item.threshold);
  end
endmodule : generator
