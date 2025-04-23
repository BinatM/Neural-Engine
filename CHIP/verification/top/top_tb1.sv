`timescale 1ns/1ps
module top_tb;
  import uvm_pkg::*;
  `uvm_component_utils(top_test)

  logic clk, chip_sel, wr_en, rd_en;
  tri [15:0] bus;
  bus_if bus_if_i (.*);

  top dut (.*);

  initial begin
	clk = 0;
	forever #5 clk = ~clk;
  end

  initial begin
	uvm_config_db#(virtual bus_if.DRIVER)::set(null,"*","vif",bus_if_i);
	uvm_config_db#(virtual bus_if.MONITOR)::set(null,"*","vif",bus_if_i);
	uvm_root::run_test();
  end
endmodule
