`timescale 1ns / 1ps

module tb_control_unit;

    // Parameters
    parameter LOAD_DEPTH = 69;
    parameter BLOCK_SIZE = 70;

    // Clock + reset
    reg clk = 0;
    reg reset_n = 0;
    reg start = 0;

    // SDRAM mock interface
    reg  [15:0] sdram_dout;
    reg         sdram_ready;
    wire        sdram_rd_en;
    wire [23:0] sdram_address;

    // On-chip memory interface
    wire        mem_wr_en;
    wire [9:0]  mem_address;

    // Control signals
    wire        output_ready;
    wire        start_run;
    wire        all_done;

    // Memory content mirror
    reg [15:0] mem_model [0:68];

    // DUT connection
    control_unit #(
        .LOAD_DEPTH(LOAD_DEPTH),
        .BLOCK_SIZE(BLOCK_SIZE)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .sdram_rd_en(sdram_rd_en),
        .sdram_address(sdram_address),
        .sdram_dout(sdram_dout),
        .sdram_ready(sdram_ready),
        .mem_wr_en(mem_wr_en),
        .mem_address(mem_address),
        .output_ready(output_ready),
        .start_run(start_run),
        .all_done(all_done),
        .val_result_bits(2'b10)
    );

    // Clock generation
    always #5 clk = ~clk;

    // SDRAM memory contents
    reg [15:0] sdram_mem [0:255];

    // Provide START pulse
    task trigger_start;
    begin
        @(negedge clk);
        start <= 1;
        repeat (3) @(negedge clk);
        start <= 0;
    end
    endtask

    // Initialize test and run simulation
    initial begin
        // SDRAM image: 1 test + 69 data words
        sdram_mem[0] = 16'd1;        // test count
        sdram_mem[1] = 16'hABCD;     // header
        for (int i = 0; i < LOAD_DEPTH; i++)
            sdram_mem[2 + i] = 16'h1000 + i;  // test data

        // Reset + start
        #20 reset_n = 1;
        #40 trigger_start();

        // Wait for process to complete
        wait (all_done);
        #20;

        $display("----- Final On-Chip Memory Dump -----");
        for (int i = 0; i < LOAD_DEPTH; i++) begin
            $display("mem_model[%02d] = 0x%04h", i, mem_model[i]);
        end

        $display("----- Memory Verification -----");
        for (int i = 0; i < LOAD_DEPTH; i++) begin
            if (mem_model[i] !== (16'h1000 + i)) begin
                $display(" ERROR: mem_model[%0d] = 0x%04h, expected 0x%04h", i, mem_model[i], 16'h1000 + i);
            end else begin
                $display("mem_model[%0d] OK: 0x%04h", i, mem_model[i]);
            end
        end

        $finish;
    end

    // SDRAM response simulation
    always @(posedge clk) begin
        sdram_ready <= 0;
        if (sdram_rd_en) begin
            sdram_dout  <= sdram_mem[sdram_address];
            sdram_ready <= 1;
        end
    end

    // Monitor on-chip memory writes
    always @(posedge clk) begin
        if (mem_wr_en) begin
            mem_model[mem_address] <= dut.current_word;
            $display("[WRITE] mem[%0d] <= 0x%04h", mem_address, dut.current_word);
        end
    end

endmodule
