module sdram_controller(
    input wire clk,
    input wire reset_n,
    output wire [12:0] addr,
    output wire [1:0] ba,
    output wire cas_n,
    output wire ras_n,
    output wire we_n,
    output wire clk_out,
    output wire cke,
    output wire cs_n,
    inout wire [15:0] dq,
    output wire ldqm,
    output wire udqm,
    input wire [15:0] data_in,
    output wire [15:0] data_out,
    input wire wr_en,
    input wire rd_en,
    input wire chip_sel
);
endmodule