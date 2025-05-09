// File: verification/env/tb_if.sv
`timescale 1ns/1ps
import trans_pkg::*;

interface tb_if(input logic clk);
  // Physical lines
  tri [15:0]   bus;
  logic [15:0] bus_drv;
  logic        bus_drv_en;
  // auto-tri-state:
  assign bus = bus_drv_en ? bus_drv : 16'bz;

  // Control
  logic wr_en, rd_en, chip_sel;

  // DUT outputs
  logic        output_ready, output_bit;

  // Exposed for coverage
  logic [5:0]  wr_data_ptr, rd_data_ptr;
  logic [2:0]  ctrl_state;

  // -------------------------------------------------------------------
  // Simulation-only timer from Control_unit
  // -------------------------------------------------------------------
  logic [1:0]  calc_finish_timer;

  // Modport for driving from TB (driver)
  modport TB (
	input  clk,
	inout  bus,
	output bus_drv, bus_drv_en,
	output wr_en, rd_en, chip_sel,
	input  output_ready, output_bit,
	input  wr_data_ptr, rd_data_ptr, ctrl_state,
	input  calc_finish_timer
  );

  // Modport for connecting to DUT & Monitor
  modport DUT (
	input  clk, wr_en, rd_en, chip_sel,
	inout  bus,
	output output_ready, output_bit,
	output wr_data_ptr, rd_data_ptr, ctrl_state,
	output calc_finish_timer
  );

endinterface : tb_if
