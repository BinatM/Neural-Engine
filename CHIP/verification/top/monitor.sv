// File: verification/env/monitor.sv
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

	// 2) Wait for DUT's output_ready with timeout
	$display("MON: waiting for output_ready @%0t", $time);
	fork
	  begin : wait_ready
		//wait (vif.output_ready);
	  end
	  begin : timeout
		#1000;
		$error("MON-TIMEOUT: no output_ready within 1000ns @%0t", $time);
		disable wait_ready;
	  end
	join_any
	disable timeout;

	// 3) Sample what you see
	r = new(item);
	r.mac_result = vif.mac_result;
	r.decision   = vif.output_bit;
	r.cycle      = cycle_cnt;
	r.delay_sum  = 0;
	foreach (item.wr_en_delay[i])
	  r.delay_sum += item.wr_en_delay[i];

	$display("MON: captured mac=%0d, decision=%b @cycle=%0d, delay_sum=%0d", 
			 r.mac_result, r.decision, r.cycle, r.delay_sum);

	// 4) Forward to scoreboard
	m2sb.put(r);
  end
endmodule