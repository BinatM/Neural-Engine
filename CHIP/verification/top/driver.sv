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
	vif.rd_en      = 0;
	vif.bus_drv_en = 0;
	repeat (2) @(posedge clk);
	vif.chip_sel   = 1;
  end

  // 2) Main stimulus loop
  initial begin
	// wait until chip_sel is up
	wait (vif.chip_sel);
	repeat (2) @(posedge clk);

	forever begin
	  // grab next transaction
	  m2drv.get(item);

	  // Debug: start of write phase
	  $display("DRV: START write phase @%0t, threshold=%0d", $time, item.threshold);

	  // WRITE PHASE (66 cycles: 64 data + 2 threshold)
	  vif.wr_en = 1;
	  // 64 pixel/weight pairs
	  for (cycle = 0; cycle < 64; cycle++) begin
		// optional stalls
		if (item.wr_en_delay[cycle] > 0) begin
		  $display("DRV: stall for %0d cycles at idx %0d @%0t", item.wr_en_delay[cycle], cycle, $time);
		  vif.wr_en      = 0;
		  vif.bus_drv_en = 0;
		  repeat (item.wr_en_delay[cycle]) @(posedge clk);
		  vif.wr_en      = 1;
		end
		// drive data
		vif.bus_drv    = item.data[cycle];
		vif.bus_drv_en = 1;
		$display("DRV[%0d @%0t]: sending data[%0d]=16'h%0h  (w=%0d,p=%0d)", 
				 cycle, $time, cycle, item.data[cycle], item.data[cycle][15:8], item.data[cycle][7:0]);
		@(posedge clk);
	  end
//stall thresh
//	  $display("DRV: stall for 2 cycles at  @%0t", $time);
//	  vif.wr_en      = 0;
//	  vif.bus_drv_en = 0;
//	  repeat (2) @(posedge clk);
//	  vif.wr_en      = 1;
	  
	  // threshold low half
	  vif.bus_drv    = item.threshold[15:0];
	  vif.bus_drv_en = 1;
	  $display("DRV: sending threshold low half = 16'h%0h @%0t", item.threshold[15:0], $time);
	  @(posedge clk);

	  // threshold high half
	  vif.bus_drv    = {4'b0, item.threshold[21:16]};
	  vif.bus_drv_en = 1;
	  $display("DRV: sending threshold high half = 16'h%0h @%0t", item.threshold[21:16], $time);	 
	  @(posedge clk);
	  // end write
	  vif.wr_en      = 0;
	  vif.bus_drv_en = 0;
	  $display("DRV: end write phase @%0t", $time);

	  // one idle cycle
	  @(posedge clk);

	  // READ PHASE (2 cycles)
//	  if (item.wr_en_delay[64] == 0) begin
//		  wait (vif.calc_finish_timer == 2'd3);
//	  end
	  vif.rd_en = 1;
	  $display("DRV: start read phase @%0t", $time);
	  @(posedge clk);
	  @(posedge clk);
	  vif.rd_en = 0;
	  $display("DRV: end read phase @%0t", $time);



	  // hand off to monitor
	  m2mon.put(item);
	  repeat (25) @(posedge clk);
	  vif.chip_sel = 0;
	  $display("DRV: deasserted chip_sel @%0t, waiting then finish.", $time);
	  repeat (20000) @(posedge clk);
	  $finish;
	end
  end
endmodule : driver