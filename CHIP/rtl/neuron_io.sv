// File: rtl/neuron_io.sv
`timescale 1ns/1ps

module neuron_io (
	input  logic        clk_in,            // system clock
	input  logic   [15:0] bus,            

	// control from top-level FSM
	input  logic        wr_en_in,
	input  logic        chip_sel_in,

	// internal signals from MAC & Activation
	input  logic        output_ready_in,
	input  logic        output_bit_in,

	// outputs into the datapath
	output logic [7:0]  img_data,
	output logic [7:0]  weight_data,
	output logic [15:0] threshold_data,
	
	// routing signals from input to output (pass-through)
	output logic output_ready_out,
	output logic output_bit_out,
	output logic wr_en_pass,
	output logic chip_sel_pass,
	output logic clk_pass
);

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


assign clk_pass = clk_in;
assign wr_en_pass = wr_en_in;
assign output_ready_out = output_ready_in;
assign output_bit_out = output_bit_in;
assign chip_sel_pass = chip_sel_in;

endmodule : neuron_io
