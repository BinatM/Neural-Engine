module validator(
    input wire clk,
    input wire reset_n,
    input wire [15:0] data_in,
    input wire [10:0] address,
    output wire [15:0] output,
    output wire output_ready,
    input wire wr_en,
    input wire rd_en
);
endmodule