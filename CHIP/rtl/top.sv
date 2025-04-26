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

  // Weight memory
  input_memory weight_mem (
	.clk           (clk),
	.data_in       (weight_data),
	.data_out      (weight_mem_out),
	.wr_data_ptr   (wr_data_ptr),
	.rd_data_ptr   (rd_data_ptr)
  );

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
