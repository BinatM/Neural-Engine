
`timescale 1ns/1ps

module tb_test_generator;

    // Parameters
    localparam ADDR_WIDTH = 11;
    localparam TOTAL_WORDS = 66;

    // Inputs
    reg clk;
    reg reset;
    reg start;
    reg [15:0] mem_data_in;
    reg output_ready;

    // Outputs
    wire [ADDR_WIDTH-1:0] address_BUS;
    wire [15:0] DATA_BUS;
    wire rd_en;
    wire wr_en;
    wire chip_sel;

    // Instantiate the DUT
    test_generator #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .address_BUS(address_BUS),
        .DATA_BUS(DATA_BUS),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .chip_sel(chip_sel),
        .mem_data_in(mem_data_in),
        .output_ready(output_ready)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $display("=== Starting Simulation ===");

        // Initial values
        reset = 0;
        start = 0;
        mem_data_in = 16'h0000;
        output_ready = 0;

        // Hold reset low briefly, then release
        #10;
        reset = 1;

        // Wait a bit and then start
        #10;
        start = 1;
        #10;
        start = 0;

        // Simulate memory output for 66 cycles
        repeat (66) begin
            @(posedge clk);
            mem_data_in = $random;
            $display("[%0t] Feeding mem_data_in = %h", $time, mem_data_in);
        end

        // Simulate DUT ready signal after a short delay
        #100;
        output_ready = 1;
        @(posedge clk);
        output_ready = 0;

        // Wait a bit longer to observe behavior
        #100;
        $display("=== Simulation Finished ===");
        $stop;
    end

endmodule