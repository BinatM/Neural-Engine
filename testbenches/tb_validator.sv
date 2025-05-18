`timescale 1ns/1ps

module tb_validator;

  logic clk = 0;
  logic reset_n = 0;
  logic dut_single_out;
  logic output_ready;
  logic expected_single_out;
  logic [15:0] data_to_mem;
  logic val_done;

  // Instantiate DUT
  validator dut (
    .clk(clk),
    .reset_n(reset_n),
    .dut_single_out(dut_single_out),
    .output_ready(output_ready),
    .expected_single_out(expected_single_out),
    .data_to_mem(data_to_mem),
    .val_done(val_done)
  );

  // Clock: 50 MHz
  always #10 clk = ~clk;

  initial begin
    // Reset
    reset_n = 0;
    output_ready = 0;
    dut_single_out = 0;
    expected_single_out = 0;
    #50;
    reset_n = 1;

    // Wait a bit, then simulate valid output from DUT
    repeat (5) @(posedge clk);
    expected_single_out = 1;
    dut_single_out = 1;
    output_ready = 1; // triggers state machine

    @(posedge clk); // VAL_READ_SINGLE_BIT
    output_ready = 0;

    @(posedge clk); // VAL_WRITE_RESULT
    @(posedge clk); // VAL_DONE

    // Wait to observe val_done
    repeat (2) @(posedge clk);
    $stop;
  end

endmodule