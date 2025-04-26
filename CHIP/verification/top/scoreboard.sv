`timescale 1ns/1ps
import trans_pkg::*;

module scoreboard (
  input  logic                clk,
  ref mailbox #(result_item) m2sb
);
  result_item        r;
  int unsigned       golden_mac;
  bit                golden_dec;
  int unsigned       p, w, prod;

  initial begin
	// 1) Consume the result transaction
	m2sb.get(r);
	$display("SB: comparing DUT vs GOLD @%0t", $time);

	// 2) Compute golden MAC with full-width products
	golden_mac = 0;
	for (int i = 0; i < 64; i++) begin
	  // widen pixel & weight to int
	  p    = r.data[i][7:0];
	  w    = r.data[i][15:8];
	  prod = p * w;          // 32-bit product
	  golden_mac += prod;
	  $display("SB: term[%0d]: %0d*%0d = %0d, sum=%0d",
			   i, p, w, prod, golden_mac);
	end

	// 3) Determine golden decision
	golden_dec = (golden_mac >= r.threshold);

	// 4) Compare & report
	if (r.mac_result !== golden_mac)
	  $error("SB: MAC MISMATCH ? got=%0d, exp=%0d @%0t", 
			 r.mac_result, golden_mac, $time);
	else
	  $display("SB: MAC OK = %0d", golden_mac);

	if (r.decision !== golden_dec)
	  $error("SB: DECISION MISMATCH ? got=%b, exp=%b @%0t", 
			 r.decision, golden_dec, $time);
	else
	  $display("SB: DECISION OK = %b", golden_dec);

	// 5) Finish simulation
	$finish;
  end
endmodule : scoreboard
