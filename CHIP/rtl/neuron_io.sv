// File: rtl/neuron_io.sv
`timescale 1ns/1ps

module neuron_io (
	input  logic        clk,            // system clock
	inout  tri   [15:0] bus,            // 16-bit bidirectional I/O

	// control from top-level FSM
	input  logic        wr_en,
	input  logic        rd_en,
	input  logic        chip_sel,

	// internal signals from MAC & Activation
	input  logic        output_ready,
	input  logic        output_bit,
	input  logic [21:0] mac_result,

	// outputs into the datapath
	output logic [7:0]  img_data,
	output logic [7:0]  weight_data,
	output logic [15:0] threshold_data
);

  //? tri-state driver signals
  logic [15:0] bus_out;
  logic        bus_oe;

  // continuous tri-state connection
  assign bus = bus_oe ? bus_out : 16'bz;

  //? latch writes on rising clk when wr_en
  always_ff @(posedge clk) begin
	if (chip_sel && wr_en) begin
	  // pixel+weight pairs
	  img_data       <= bus[7:0];
	  weight_data    <= bus[15:8];
	  // threshold (during the 2 threshold cycles)
	  threshold_data <= bus;
	end
  end

  //? two-cycle read FSM
  logic read_phase;
  always_ff @(posedge clk) begin
	if (!chip_sel || !rd_en)  
	  read_phase <= 1'b0;
	else
	  read_phase <= ~read_phase;
  end

  //? drive the bus_out when output_ready & rd_en
  always_comb begin
	bus_oe  = 1'b0;
	bus_out = 16'h0000;
	if (chip_sel && rd_en && output_ready) begin
	  bus_oe = 1'b1;
	  if (!read_phase)
		bus_out = mac_result[15:0];            // lower 16
	  else
		bus_out = {10'b0, mac_result[21:16]};  // upper 6 in LSB
	end
  end

endmodule : neuron_io
