
`timescale 1ns/1ps

module tb_on_chip_memory;

    reg clk = 0;
    reg reset_n = 0;
    reg wr_en = 0;
    reg rd_en = 0;
    reg [15:0] data_in = 0;
    reg [9:0] address = 0;
    wire [15:0] data_out;

    // Instantiate DUT with fixed settings
    on_chip_memory dut (
        .clk              (clk),
        .reset_n          (reset_n),
        .wr_en            (wr_en),
        .rd_en            (rd_en),
        .data_in          (data_in),
        .data_out         (data_out),
        .multi_cycle_mode (1'b0),
        .cycle_count      (2'd1),
        .address_in       (address),
        .use_external_addr(1'b1)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Step 1: Reset
        #5 reset_n = 0;
        #10 reset_n = 1;

        // Step 2: Write 0x1234 to address 5
        #10;
        address = 10'd5;
        data_in = 16'h1234;
        wr_en = 1;
        #10 wr_en = 0;

        // Step 3: Read from address 5
        #10;
        rd_en = 1;
        #10 rd_en = 0;

        // Step 4: Write 0xABCD to address 7
        #10;
        address = 10'd7;
        data_in = 16'hABCD;
        wr_en = 1;
        #10 wr_en = 0;

        // Step 5: Read from address 7
        #10;
        rd_en = 1;
        #10 rd_en = 0;

        // Done
        #20 $stop;
    end

endmodule