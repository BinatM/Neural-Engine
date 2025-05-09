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
  
   // Functional coverage
   covergroup cg_result ;
     coverpoint item.threshold;
     coverpoint r.mac_result;
     coverpoint r.decision;
     coverpoint cycle_cnt; // max = 100;
   endgroup
   cg_result cg = new();

  always_ff @(posedge clk) begin 
	  cycle_cnt <= cycle_cnt + 1;

  end

  initial begin
	int timeout;
	bit decision; 
	bit [21:0] mac;	
	// 3) Fork off the two-cycle read so initial never stalls
	mac = '0;
	fork
	  begin
		wait (vif.rd_en);           // wait non?blocking
		$display("MON rd_en asserted @%0t", $time);
		@(posedge clk);
		mac[15:0] = vif.bus;
		@(posedge clk);
		mac[21:16] = vif.bus[5:0];
		$display("MON: sampled mac=%0d", mac);
	  end
	join_none                      // let that thread run off by itself
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


    wait (vif.output_ready);


	// 5) Build result_item
	r = new(item);
	r.mac_result = mac;
	r.decision   = decision;
	r.cycle      = cycle_cnt;
	r.delay_sum  = 0;
	foreach (item.wr_en_delay[i]) r.delay_sum += item.wr_en_delay[i];

	$display("MON: mac=%0d, decision=%b @cycle=%0d (+%0d delay)",
			 r.mac_result, r.decision, r.cycle, r.delay_sum);

	cg.sample();


	// 6) Forward to scoreboard
	m2sb.put(r);
  end
endmodule : monitor
