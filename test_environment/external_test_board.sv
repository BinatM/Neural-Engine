module external_test_board (
    input  logic        clk_in,
    input  logic [15:0] bus,
    input  logic        wr_en,
    input  logic        chip_sel,
    output logic        output_ready,
    output logic        output_bit
);
endmodule