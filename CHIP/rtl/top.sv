// File: rtl/top.sv
`timescale 1ns/1ps

module top (
	inout  tri         [15:0] bus,           // 16-bit bidirectional I/O
	input  logic             clk,           // system clock
	input  logic             wr_en,         // write-enable (data & threshold)
	input  logic             rd_en,         // read-enable (MAC result)
	input  logic             chip_sel,      // chip-select / reset
	//? debug / TB ports ?
	output logic             output_ready,  // pulses when 1-bit decision valid
	output logic             output_bit,    // final perceptron output
	output logic      [21:0] mac_result     // raw 22-bit accumulator value
);

  //------------------------------------------------------------------------
  // Internal control & datapath signals
  //------------------------------------------------------------------------
  logic        rst_mem, mul_mem_en, ac_mem_en, threshold_ready;
  logic [5:0]  wr_data_ptr, rd_data_ptr;

  logic [7:0]  img_data, weight_data;
  logic [15:0] threshold_data;

  logic [7:0]  image_mem_out, weight_mem_out;

  // full-width accumulator & decision
  logic [21:0] mac_out_int;
  logic        output_bit_int, output_ready_int;

  // generate a gated write-enable for SRAM: only during pixel/weight loads
  //wire mem_we = wr_en && !threshold_ready;

  //------------------------------------------------------------------------
  // Neuron I/O: bus mux, decode, tri-state control
  //------------------------------------------------------------------------
  neuron_io io_inst (
	.clk            (clk),
	.bus            (bus),
	.wr_en          (wr_en),
	.rd_en          (rd_en),
	.chip_sel       (chip_sel),
	.output_ready   (output_ready_int),
	.output_bit     (output_bit_int),
	.mac_result     (mac_out_int),
	.img_data       (img_data),
	.weight_data    (weight_data),
	.threshold_data (threshold_data)
  );

  //------------------------------------------------------------------------
  // Control FSM
  //------------------------------------------------------------------------
  Control_unit ctrl_inst (
	.clk             (clk),
	.chip_sel        (chip_sel),
	.wr_en           (wr_en),
	.rst_mem         (rst_mem),
	.mul_mem_en      (mul_mem_en),
	.ac_mem_en       (ac_mem_en),
	.output_ready    (output_ready_int),
	.wr_data_ptr     (wr_data_ptr),
	.rd_data_ptr     (rd_data_ptr),
	.threshold_ready (threshold_ready)
  );
  
//  input_memory image_mem (
//	  .clk   (clk),
//	  .D     (img_data),
//	  .Q     (image_mem_out),
//	  .AA    (wr_data_ptr),
//	  .AB    (rd_data_ptr),
//	  .CLKW  (clk),
//	  .CLKR  (clk),
//	  .WEB   (!mem_we),      // convert active-high mem_we to active-low
//	  .REB   (1'b0),         // always enable read
//	  .BWEB  (8'b0),
//	  .SLP   (1'b0),
//	  .SD    (1'b0),
//	  .AMA   (6'b0),
//	  .AMB   (6'b0),
//	  .DM    (8'b0),
//	  .BWEBM (8'b0),
//	  .WEBM  (1'b1),
//	  .REBM  (1'b1),
//	  .BIST  (1'b0)
//  );
//  
//  input_memory weight_mem (
//	  .clk   (clk),
//	  .D     (img_data),
//	  .Q     (image_mem_out),
//	  .AA    (wr_data_ptr),
//	  .AB    (rd_data_ptr),
//	  .CLKW  (clk),
//	  .CLKR  (clk),
//	  .WEB   (!mem_we),      // convert active-high mem_we to active-low
//	  .REB   (1'b0),         // always enable read
//	  .BWEB  (8'b0),
//	  .SLP   (1'b0),
//	  .SD    (1'b0),
//	  .AMA   (6'b0),
//	  .AMB   (6'b0),
//	  .DM    (8'b0),
//	  .BWEBM (8'b0),
//	  .WEBM  (1'b1),
//	  .REBM  (1'b1),
//	  .BIST  (1'b0)
//  );
//  //------------------------------------------------------------------------
//  // Pixel SRAM (Image)
//  //------------------------------------------------------------------------
//  TS6N28HPCPHVTA64X8M4FWBSO image_mem (
//	.AA   (wr_data_ptr),       // write address
//	.D    (img_data),          // write data
//	.BWEB (8'b0),              // bit-write enable (active low)
//	.WEB  (1'b0),           // write enable (active low)
//	.CLKW (clk),               // write clock
//
//	.AB   (rd_data_ptr),       // read address
//	.REB  (1'b0),              // read enable (active low)
//	.CLKR (clk),               // read clock
//
//	.SLP  (1'b0),              // sleep off
//	.SD   (1'b0),              // shutdown off
//
//	.AMA  (6'b0), .DM    (8'b0),
//	.BWEBM(8'b0), .WEBM  (1'b1),
//	.AMB  (6'b0), .REBM  (1'b1),
//	.BIST (1'b0),
//
//	.Q    (image_mem_out)      // read data
//  );
//
//  //------------------------------------------------------------------------
//  // Pixel SRAM (Weight)
//  //------------------------------------------------------------------------
//  TS6N28HPCPHVTA64X8M4FWBSO weight_mem (
//	.AA   (wr_data_ptr),
//	.D    (weight_data),
//	.BWEB (8'b0),
//	.WEB  (1'b0),
//	.CLKW (clk),
//
//	.AB   (rd_data_ptr),
//	.REB  (1'b0),
//	.CLKR (clk),
//
//	.SLP  (1'b0),
//	.SD   (1'b0),
//
//	.AMA  (6'b0), .DM    (8'b0),
//	.BWEBM(8'b0), .WEBM  (1'b1),
//	.AMB  (6'b0), .REBM  (1'b1),
//	.BIST (1'b0),
//
//	.Q    (weight_mem_out)
//  );

  //------------------------------------------------------------------------
  // MAC Unit: two-stage pipelined multiply & accumulate
  //------------------------------------------------------------------------
  mac #(
	.IN_WIDTH  (8),
	.OUT_WIDTH (22)
  ) mac_inst (
	.clk         (clk),
	.rst_mem     (rst_mem),
	.mul_mem_en  (mul_mem_en),
	.ac_mem_en   (ac_mem_en),
	.img_in      (image_mem_out),
	.weight_in   (weight_mem_out),
	.mac_out     (mac_out_int)
  );

  //------------------------------------------------------------------------
  // Activation Function: threshold compare ? 1-bit decision
  //------------------------------------------------------------------------
  activation_function #(
	.WIDTH     (22),
	.BUS_WIDTH (16)
  ) activation_inst (
	.clk             (clk),
	.threshold_ready (threshold_ready),
	.mac_output      (mac_out_int),
	.input_bus       (threshold_data),
	.output_memory   (output_bit_int)
  );

  //------------------------------------------------------------------------
  // Drive debug / TB ports from internal signals
  //------------------------------------------------------------------------
  assign output_ready = output_ready_int;
  assign output_bit   = output_bit_int;
  assign mac_result   = mac_out_int;

endmodule : top
