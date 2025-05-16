// File: verification/env/tb_if.sv
`timescale 1ns/1ps
import trans_pkg::*;

interface tb_if(input logic clk);
  // Physical lines
  logic [15:0]   bus;


  // Control
  logic wr_en, chip_sel;

  // DUT outputs
  logic        output_ready, output_bit;

  // Exposed for coverage
  logic [5:0]  wr_data_ptr, rd_data_ptr;
  logic [2:0]  ctrl_state;

  // -------------------------------------------------------------------
  // Simulation-only timer from Control_unit
  // -------------------------------------------------------------------

  // Modport for driving from TB (driver)
  modport TB (
	input  clk,
	inout  bus,
	output wr_en, chip_sel,
	input  output_ready, output_bit,
	input  wr_data_ptr, rd_data_ptr, ctrl_state
  );

  // Modport for connecting to DUT & Monitor
  modport DUT (
	input  clk, wr_en, chip_sel,
	inout  bus,
	output output_ready, output_bit,
	output wr_data_ptr, rd_data_ptr, ctrl_state
  );

endinterface : tb_if
