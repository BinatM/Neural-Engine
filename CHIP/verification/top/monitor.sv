// File: verification/monitor.sv
`timescale 1ns/1ps
import trans_pkg::*;

module monitor (
  tb_if.TB vif,
  input logic [15:0] bus_line
);

  int write_count;
  logic [21:0] captured_threshold;
  trans_t txn;

  always_ff @(posedge vif.clk) begin
	if (vif.wr_en) begin
	  write_count++;
	  if (write_count <= 64) begin
		txn.is_threshold = 0;
		txn.pixel        = bus_line[7:0];
		txn.weight       = bus_line[15:8];
	  end else begin
		txn.is_threshold = 1;
		if (write_count == 65)
		  captured_threshold[15:0] = bus_line;
		else begin
		  captured_threshold[21:16] = bus_line[5:0];
		  txn.threshold = captured_threshold;
		end
	  end
	  mon_mbx.put(txn);
	end
  end

endmodule : monitor
