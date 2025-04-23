// File: verification/tb_if.sv
`timescale 1ns/1ps

interface tb_if (input logic clk);
  // Control signals driven by the TB
  logic        wr_en;
  logic        rd_en;
  logic        chip_sel;

  // The inout bus, now a variable so the TB can drive it
  logic [15:0] bus;

  // Debug outputs from the DUT
  logic        output_ready;
  logic        output_bit;
  logic [21:0] mac_result;

  // Modport for the DUT instance: it sees the bus as inout
  modport DUT (
	inout  bus,
	input  clk,
	input  wr_en,
	input  rd_en,
	input  chip_sel,
	output output_ready,
	output output_bit,
	output mac_result
  );

  // Modport for the TB: it also drives/reads the bus
  modport TB (
	inout  bus,
	input  clk,
	output wr_en,
	output rd_en,
	output chip_sel,
	input  output_ready,
	input  output_bit,
	input  mac_result
  );
endinterface : tb_if
