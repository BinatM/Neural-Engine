`timescale 1ns/1ps

module top (
  inout  tri   [15:0] bus,           // bidir pixel/weight & MAC result
  input  logic       clk,
  input  logic       wr_en,
  input  logic       rd_en,
  input  logic       chip_sel,
  output logic       output_ready,
  output logic       output_bit,
  output logic [21:0] mac_result,

  // for coverage / monitor
  output logic [5:0]  wr_data_ptr,
  output logic [5:0]  rd_data_ptr,
  output logic [2:0]  ctrl_state
);

  //------------------------------------------------------------------------
  // Neuron I/O decode
  //------------------------------------------------------------------------
  logic [7:0]  img_data, weight_data;
  logic [15:0] threshold_data;
  neuron_io io_inst (
	.clk            (clk),
	.bus            (bus),
	.wr_en          (wr_en),
	.rd_en          (rd_en),
	.chip_sel       (chip_sel),
	.output_ready   (output_ready),
	.output_bit     (output_bit),
	.mac_result     (mac_result),
	.img_data       (img_data),
	.weight_data    (weight_data),
	.threshold_data (threshold_data)
  );

  //------------------------------------------------------------------------
  // Replace SRAM macros with your simple input_memory
  //------------------------------------------------------------------------
  logic [7:0] image_mem_out, weight_mem_out;

  // Image pixels memory
  input_memory image_mem (
	.clk           (clk),
	.data_in       (img_data),
	.data_out      (image_mem_out),
	.wr_data_ptr   (wr_data_ptr),
	.rd_data_ptr   (rd_data_ptr)
  );

   //Weight memory
  input_memory weight_mem (
	.clk           (clk),
	.data_in       (weight_data),
	.data_out      (weight_mem_out),
	.wr_data_ptr   (wr_data_ptr),
	.rd_data_ptr   (rd_data_ptr)
  );

  
//  ------------------------------------------------------------------------
//   Pixel SRAM (Image)
//  ------------------------------------------------------------------------
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
//	.AMA  (wr_data_ptr), .DM    (img_data),
//	.BWEBM(8'b0), .WEBM  (1'b0),
//	.AMB  (rd_data_ptr), .REBM  (1'b0),
//	.BIST (1'b1),
//
//	.Q    (image_mem_out)      // read data
//  );
//////
//////  //------------------------------------------------------------------------
//////  // Pixel SRAM (Weight)
//////  //------------------------------------------------------------------------
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
//	.AMA  (wr_data_ptr), .DM    (weight_data),
//	.BWEBM(8'b0), .WEBM  (1'b0),
//	.AMB  (rd_data_ptr), .REBM  (1'b0),
//	.BIST (1'b1),
//
//	.Q    (weight_mem_out)
//  );

  //------------------------------------------------------------------------
  // MAC Unit
  //------------------------------------------------------------------------
  logic rst_mem, mul_mem_en, ac_mem_en, threshold_ready;
  mac mac_inst (
	.clk        (clk),
	.rst_mem    (rst_mem),
	.mul_mem_en (mul_mem_en),
	.ac_mem_en  (ac_mem_en),
	.img_in     (image_mem_out),
	.weight_in  (weight_mem_out),
	.mac_out    (mac_result)
  );

  //------------------------------------------------------------------------
  // Activation Function
  //------------------------------------------------------------------------
  activation_function activation_inst (
	.clk             (clk),
	.threshold_ready (threshold_ready),
	.mac_output      (mac_result),
	.input_bus       (threshold_data),
	.output_memory   (output_bit)
  );

  //------------------------------------------------------------------------
  // Control FSM (exposes pointers & state)
  //------------------------------------------------------------------------
  Control_unit ctrl_inst (
	.clk            (clk),
	.chip_sel       (chip_sel),
	.wr_en          (wr_en),
	.rst_mem        (rst_mem),
	.mul_mem_en     (mul_mem_en),
	.ac_mem_en      (ac_mem_en),
	.output_ready   (output_ready),
	.wr_data_ptr    (wr_data_ptr),
	.rd_data_ptr    (rd_data_ptr),
	.threshold_ready(threshold_ready),
	.ctrl_state     (ctrl_state),
	.rd_en			(rd_en)
  );

endmodule : top
