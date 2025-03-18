module clock_generator (
    input  wire clk_in,
    output wire clk_out
);
    // For a simple pass-through
    assign clk_out = clk_in;
endmodule
