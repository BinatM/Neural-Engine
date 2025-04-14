module external_test_board(
    input wire clk,
    input wire reset_n,
    inout wire [15:0] gpio_data,
    output wire [10:0] gpio_addr,
    output wire gpio_wr_en,
    output wire gpio_rd_en,
    output wire output_ready
);
endmodule