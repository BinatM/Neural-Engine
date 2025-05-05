// File: verification/env/monitor.sv
`timescale 1ns/1ps
import trans_pkg::*;

module monitor (
  input  logic            clk,
  tb_if.DUT              vif,
  ref mailbox #(trans_item) m2mon,
  ref mailbox #(result_item) m2sb
);
  trans_item   item;
  result_item  r;
  int unsigned cycle_cnt;

  always_ff @(posedge clk)
	cycle_cnt <= cycle_cnt + 1;

  initial begin
	int timeout;
	bit decision; 
	bit [21:0] mac;	
	// 1) Grab the transaction
	m2mon.get(item);
	
	decision = vif.output_bit;
	timeout  = 70000;
	// 2) Wait (with timeout) for the DUT to signal the 1-bit result

//	while (!vif.output_ready && timeout--) @(posedge clk);
//	if (!vif.output_ready) begin
//	  $error("MON-TIMEOUT: no output_ready within 1000 cycles @%0t", $time);
//	  $finish;
//	end

	// 3) Capture the 1-bit decision (always valid at output_ready)

	mac = '0;

	// 4) If the test *did* assert rd_en, grab the raw MAC from the bus
	//    over two cycles; otherwise leave it at zero or flag ?not read.?
	if (vif.rd_en) begin
	  @(posedge clk);
	  mac[15:0] = vif.bus;
	  @(posedge clk);
	  mac[21:16] = vif.bus[5:0];
	end

	// 5) Build result_item
	r = new(item);
	r.mac_result = mac;
	r.decision   = decision;
	r.cycle      = cycle_cnt;
	r.delay_sum  = 0;
	foreach (item.wr_en_delay[i]) r.delay_sum += item.wr_en_delay[i];

	$display("MON: mac=%0d, decision=%b @cycle=%0d (+%0d delay)",
			 r.mac_result, r.decision, r.cycle, r.delay_sum);

	// 6) Forward to scoreboard
	m2sb.put(r);
  end
endmodule : monitor
