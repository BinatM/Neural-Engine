// File: verification/env/driver.sv
`timescale 1ns/1ps
import trans_pkg::*;

module driver (
  input  logic          clk,
  tb_if.TB              vif,
  ref mailbox #(trans_item) m2drv,
  ref mailbox #(trans_item) m2mon
);
  trans_item item;
  int        cycle;

  // 1) One-time reset: chip_sel=0 for 2 clocks, then 1 forever
  initial begin
	vif.chip_sel   = 0;
	vif.wr_en      = 0;
	vif.bus_drv_en = 0;
	repeat (2) @(posedge clk);
	vif.chip_sel   = 1;
  end

  // 2) Main stimulus loop
  initial begin
	// wait until chip_sel is up
	wait (vif.chip_sel);

	forever begin
	  // grab next transaction
	  m2drv.get(item);

	  // WRITE PHASE (66 cycles: 64 data + 2 threshold)
	  vif.wr_en = 1;
	  // 64 pixel/weight pairs
	  for (cycle = 0; cycle < 64; cycle++) begin
		// optional stalls
		if (item.wr_en_delay[cycle] > 0) begin
		  vif.wr_en      = 0;
		  vif.bus_drv_en = 0;
		  repeat (item.wr_en_delay[cycle]) @(posedge clk);
		  vif.wr_en      = 1;
		end
		vif.bus_drv    = item.data[cycle];
		vif.bus_drv_en = 1;
		@(posedge clk);
		@(posedge clk);

	  end

	  // threshold low half
	  vif.bus_drv    = item.threshold[15:0];
	  vif.bus_drv_en = 1;
	  @(posedge clk);

	  // threshold high half
	  vif.bus_drv    = {4'b0, item.threshold[21:16]};
	  vif.bus_drv_en = 1;
	  @(posedge clk);

	  // end write
	  vif.wr_en      = 0;
	  vif.bus_drv_en = 0;

	  // one idle cycle
	  @(posedge clk);

	  // READ PHASE (2 cycles)
	  vif.rd_en = 1;
	  @(posedge clk);
	  @(posedge clk);
	  vif.rd_en = 0;

	  // hand off to monitor
	  m2mon.put(item);
	  repeat (25) @(posedge clk);
	  vif.chip_sel = 0;
	  $display("Driver: deasserted chip_sel, wait than finish.");
	  repeat (15) @(posedge clk);
	  $finish;
	end
  end

endmodule : driver
