// File: rtl/neuron_io.sv
`timescale 1ns/1ps

module neuron_io (
	input  logic        clk_in,            // system clock
	inout  tri   [15:0] bus,            // 16-bit bidirectional I/O

	// control from top-level FSM
	input  logic        wr_en_in,
	input  logic        rd_en_in,
	input  logic        chip_sel_in,
	input  logic [1:0]  calc_finish_timer,

	// internal signals from MAC & Activation
	input  logic        output_ready_in,
	input  logic        output_bit_in,
	input  logic [21:0] mac_result,

	// outputs into the datapath
	output logic [7:0]  img_data,
	output logic [7:0]  weight_data,
	output logic [15:0] threshold_data,
	
	// routing signals from input to output (pass-through)
	output logic output_ready_out,
	output logic output_bit_out,
	output logic wr_en_pass,
	output logic rd_en_pass,
	output logic chip_sel_pass,
	output logic clk_pass
);

  //? tri-state driver signals
  logic [15:0] bus_out;
  logic        bus_oe;

  // continuous tri-state connection
  assign bus = bus_oe ? bus_out : 16'bz;

  //? latch writes on rising clk when wr_en 
  always_comb begin
	  img_data       = 8'h00;
	  weight_data    = 8'h00;
	  threshold_data = 16'h0000;

	  if (chip_sel_in && wr_en_in) begin
		img_data       = bus[7:0];
		weight_data    = bus[15:8];
		threshold_data = bus;
	  end
  end

  //? two-cycle read FSM
  logic read_phase;
  always_ff @(posedge clk_in) begin
	if (!chip_sel_in || !rd_en_in || (calc_finish_timer == 2'd1 || calc_finish_timer == 2'd2))  
	  read_phase <= 1'b0;
	else
	  read_phase <= ~read_phase;
  end

  //? drive the bus_out when output_ready & rd_en
  always_comb begin
	bus_oe  = 1'b0;
	bus_out = 16'h0000;
	if (chip_sel_in && rd_en_in && (calc_finish_timer == 2'd3 || (bus_oe = 1'b1))) begin // && output_ready_in) begin
	  bus_oe = 1'b1;
	  if (!read_phase)
		bus_out = mac_result[15:0];            // lower 16
	  else
		bus_out = {10'b0, mac_result[21:16]};  // upper 6 in LSB
	end
  end

assign clk_pass = clk_in;
assign rd_en_pass = (rd_en_in && !wr_en_in);
assign wr_en_pass = wr_en_in;
assign output_ready_out = output_ready_in;
assign output_bit_out = output_bit_in;
assign chip_sel_pass = chip_sel_in;

endmodule : neuron_io
