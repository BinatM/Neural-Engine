`timescale 1ns / 1ps

module tb_control_unit;

  logic clk;
  logic reset_n;
  logic start;
  logic val_done;

  logic sdram_rd_en;
  logic sdram_wr_en;
  logic [15:0] sdram_data_out;
  logic [23:0] sdram_address;
  logic [15:0] sdram_dout;
  logic sdram_ready;

  logic [9:0] mem_address;
  logic mem_wr_en;

  logic start_run;
  logic led_done;

  logic [15:0] val_result_bits;

  // Clock generation
  always #10 clk = ~clk;

  // Instantiate DUT
  control_unit #(.LOAD_DEPTH(68)) dut (
    .clk(clk),
    .reset_n(reset_n),
    .start(start),
    .val_done(val_done),
    .sdram_rd_en(sdram_rd_en),
    .sdram_wr_en(sdram_wr_en),
    .sdram_data_out(sdram_data_out),
    .sdram_address(sdram_address),
    .sdram_dout(sdram_dout),
    .sdram_ready(sdram_ready),
    .mem_address(mem_address),
    .mem_wr_en(mem_wr_en),
    .start_run(start_run),
    .led_done(led_done),
    .val_result_bits(val_result_bits)
  );

  // LED Done Watch
  always @(posedge clk) begin
    if (led_done) begin
      $display("✅ LED_DONE is HIGH at time %t", $time);
      $stop;
    end
  end

  initial begin
    // Initial values
    clk = 0;
    reset_n = 0;
    start = 0;
    val_done = 0;
    sdram_dout = 16'd0;
    sdram_ready = 0;
    val_result_bits = 16'hBEEF;

    // Apply reset
    #25 reset_n = 1;

    // Simulate test case
    fork
      begin
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
      end

      // SDRAM response simulation
      begin
        wait(sdram_rd_en);
        @(posedge clk);
        sdram_ready = 1;
        sdram_dout = 16'd2;  // test count = 2
        @(posedge clk);
        sdram_ready = 0;

        repeat (2) begin
          wait(sdram_rd_en);
          @(posedge clk);
          sdram_ready = 1;
          sdram_dout = 16'hABCD; // HEADER
          @(posedge clk);
          sdram_ready = 0;

          for (int i = 0; i < 68; i++) begin
            wait(sdram_rd_en);
            @(posedge clk);
            sdram_ready = 1;
            sdram_dout = 16'h1000 + i;
            @(posedge clk);
            sdram_ready = 0;
          end

          wait(start_run);
          @(posedge clk);
          val_done = 1;
          @(posedge clk);
          val_done = 0;
        end
      end
    join_none
  end

endmodule