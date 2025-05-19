`timescale 1ns/1ps

module tb_test_generator;

  logic clk = 0;
  logic reset = 0;
  logic start = 0;
  logic val_done;

  logic [10:0] address_BUS;
  logic rd_en, wr_en, chip_sel;

  // Internal counter for checking write activity
  int write_count = 0;

  // Clock generation (50 MHz)
  always #10 clk = ~clk;

  // Instantiate the DUT (Device Under Test)
  test_generator dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .val_done(val_done),
    .address_BUS(address_BUS),
    .rd_en(rd_en),
    .wr_en(wr_en),
    .chip_sel(chip_sel)
  );

  // Stimulus and monitoring process
  initial begin
    // Step 1: Reset system
    reset = 0;
    start = 0;
    val_done = 0;
    #40;
    reset = 1;

    // Step 2: Raise START for one clock cycle
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;

    // Step 3: Monitor wr_en and raise val_done after the 66th write
    forever begin
      @(posedge clk);

      if (wr_en) begin
        write_count++;

        $display("📌 Write #%0d at time %t (addr=%0d, chip_sel=%b)",
                 write_count, $time, address_BUS, chip_sel);

        // After the 66th write, simulate validator finishing
        if (write_count == 66) begin
          repeat (2) @(posedge clk);
          val_done = 1;
          @(posedge clk);
          val_done = 0;

          $display("✅ Generator performed 66 writes as expected.");
          repeat (10) @(posedge clk);
          $stop;
        end
      end
    end
  end

endmodule