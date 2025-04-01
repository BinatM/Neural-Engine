// SDRAM_CONTROLLER_wrapper.sv
// Wrapper module to connect VHDL SDRAM controller with SystemVerilog top_level

module SDRAM_CONTROLLER_wrapper (
    input  logic         clk,
    input  logic         reset_n,
    input  logic [23:0]  address,
    input  logic [15:0]  data_in,
    input  logic         read_en,
    output logic [15:0]  data_out,
    output logic         initialized,

    // SDRAM physical interface
    output logic [12:0]  sdram_addr,
    output logic [1:0]   sdram_ba,
    output logic         sdram_cke,
    output logic         sdram_cs_n,
    output logic         sdram_ras_n,
    output logic         sdram_cas_n,
    output logic         sdram_we_n,
    output logic         sdram_ldqm,
    output logic         sdram_udqm,
    inout  wire  [15:0]  sdram_dq
);

  // Bind VHDL entity (this assumes Quartus or ModelSim will link it)
  SDRAM_CONTROLLER #(
    .G_CLK_FREQ(50.0),
    .G_CAS_LATENCY(2),
    .G_WRITE_BURST_MODE('1),
    .G_BURST_LENGTH(1),
    .G_USE_AUTO_PRECHARGE('0),
    .G_BURST_TYPE('0),

    .G_ADDR_WIDTH(24),
    .G_SDRAM_ADDR_WIDTH(13),
    .G_SDRAM_DATA_WIDTH(16),
    .G_SDRAM_COL_WIDTH(9),
    .G_SDRAM_ROW_WIDTH(13),
    .G_SDRAM_BANK_WIDTH(2),

    .G_T_DESL(200.0),
    .G_T_MRD(14.0),
    .G_T_RC(60.0),
    .G_T_RCD(20.0),
    .G_T_RP(20.0),
    .G_T_WR(14.0),
    .G_T_REFI(7800.0)
  ) sdram_inst (
    .I_RESET_N(reset_n),
    .I_CLOCK(clk),
    .I_ADDRESS(address),
    .I_DATA(data_in),
    .I_REQUEST(read_en),
    .I_WRITE_ENABLE(1'b0),
    .O_ACKNOWLEDGE(),
    .O_VALID(),
    .O_Q(data_out),
    .O_SDRAM_A(sdram_addr),
    .O_SDRAM_BA(sdram_ba),
    .IO_SDRAM_DQ(sdram_dq),
    .O_SDRAM_CKE(sdram_cke),
    .O_SDRAM_CS(sdram_cs_n),
    .O_SDRAM_RAS(sdram_ras_n),
    .O_SDRAM_CAS(sdram_cas_n),
    .O_SDRAM_WE(sdram_we_n),
    .O_SDRAM_DQML(sdram_ldqm),
    .O_SDRAM_DQMH(sdram_udqm),
    .O_SDRAM_INITIALIZED(initialized)
  );

endmodule
