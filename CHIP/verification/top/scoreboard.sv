`timescale 1ns/1ps
import trans_pkg::*;

module scoreboard (
  input  logic                clk,
  ref mailbox #(result_item) m2sb
);
  result_item r;
  bit [21:0]  golden_mac;
  bit         golden_dec;

  initial begin
	// 1) Consume exactly one result
	m2sb.get(r);
	$display("SB: DUT mac_result = %0d, threshold = %0d", r.mac_result, r.threshold);

	// 2) Compute golden MAC & decision
	golden_mac = 0;
	for (int i = 0; i < 64; i++) begin
	  golden_mac += r.data[i][7:0] * r.data[i][15:8];
	end
	golden_dec = (golden_mac >= r.threshold);

	// 3) Compare & report
	if (r.mac_result !== golden_mac)
	  $error("SB: MAC MISMATCH ? got %0d, expected %0d", r.mac_result, golden_mac);
	else
	  $display("SB: MAC match: %0d", golden_mac);

	if (r.decision !== golden_dec)
	  $error("SB: DECISION MISMATCH ? got %b, expected %b", r.decision, golden_dec);
	else
	  $display("SB: DECISION match: %b", golden_dec);

	// 4) End simulation
  end
endmodule
