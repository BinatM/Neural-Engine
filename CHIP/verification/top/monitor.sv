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
     coverpoint r.decision;
     coverpoint cycle_cnt; // max = 100;
   endgroup
   cg_result cg = new();

  always_ff @(posedge clk) begin 
	  cycle_cnt <= cycle_cnt + 1;

  end

  initial begin
	bit decision; 
	m2mon.get(item);
	
	decision = vif.output_bit;


    wait (vif.output_ready);


	// 5) Build result_item
	r = new(item);
	r.decision   = decision;
	r.cycle      = cycle_cnt;
	r.delay_sum  = 0;
	foreach (item.wr_en_delay[i]) r.delay_sum += item.wr_en_delay[i];

	$display("MON: decision=%b @cycle=%0d (+%0d delay)",
			 r.decision, r.cycle, r.delay_sum);

	cg.sample();


	// 6) Forward to scoreboard
	m2sb.put(r);
  end
endmodule : monitor
