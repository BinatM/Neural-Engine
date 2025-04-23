`timescale 1ns/1ps
import trans_pkg::*;

module scoreboard ( tb_if.TB vif );
  logic [21:0] golden_mac = 0;
  logic [21:0] golden_th;
  int          write_count = 0;
  trans_t      t;

  initial begin
	// Build golden result by draining the monitor mailbox
	for (int i = 0; i < 66; i++) begin
	  mon_mbx.get(t);
	  if (!t.is_threshold) begin
		golden_mac += t.pixel * t.weight;
	  end else if (i == 65) begin
		golden_th = t.threshold;
	  end
	end

	// Wait until DUT signals ready
	wait (vif.output_ready);

	// Check raw MAC
	if (vif.mac_result !== golden_mac) begin
	  $error("MAC MISMATCH: expected %0d, got %0d",
			 golden_mac, vif.mac_result);
	end else $display("  MAC OK: %0d", golden_mac);

	// Check final output bit
	if (vif.output_bit !== (golden_mac >= golden_th)) begin
	  $error("OUT BIT MISMATCH: golden %0b, DUT %0b",
			 (golden_mac >= golden_th), vif.output_bit);
	end else $display("  OUTPUT BIT OK: %0b", vif.output_bit);

	$display("=== TEST COMPLETE ===");
	$finish;
  end
  initial begin
	  fork
		begin
		  wait (vif.output_ready);
		  $display("Output ready received.");
		end
		begin
		  #10000; // Timeout after 10us sim time
		  $fatal(1, "Timeout: output_ready never asserted.");
		end
	  join_any
	end

endmodule : scoreboard
