module on_chip_memory(
    input wire clk,
    input wire reset_n,
    input wire wr_en,
    input wire rd_en,
    input wire [15:0] data_in,
    output wire [15:0] data_out,
    input wire multi_cycle_mode,
    input wire [3:0] cycle_count
);
endmodule