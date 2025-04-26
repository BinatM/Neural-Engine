`timescale 1ns/1ps
import trans_pkg::*;

module monitor (
  input  logic            clk,
  tb_if.DUT              vif,
  ref mailbox #(trans_item) m2mon,
  ref mailbox #(result_item) m2sb
);
  trans_item  item;
  result_item r;
  int unsigned cycle_cnt;

  always_ff @(posedge clk)
	cycle_cnt <= cycle_cnt + 1;

  initial begin
	// 1) Grab the transaction
	m2mon.get(item);

	// 2) Wait for DUT?s output_ready
	wait (vif.output_ready);

	// 3) Sample what you see
	r = new(item);
	r.mac_result = vif.mac_result;
	r.decision   = vif.output_bit;
	r.cycle      = cycle_cnt;
	r.delay_sum  = 0;
	foreach (item.wr_en_delay[i])
	  r.delay_sum += item.wr_en_delay[i];

	// 4) Forward to scoreboard
	m2sb.put(r);
  end
endmodule
