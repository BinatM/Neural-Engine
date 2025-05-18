`timescale 1ns/1ps

module tb_reset_and_start;
  logic clk = 0;
  logic db_button_in;         // Debounced button (simulate KEY_0)
  logic reset_n_out;
  logic start_pulse;

  // Clock generation: 50 MHz (20ns period)
  always #10 clk = ~clk;

  // DUT instantiation
  reset_and_start dut (
    .clk(clk),
    .db_button_in(db_button_in),
    .reset_n_out(reset_n_out),
    .start_pulse(start_pulse)
  );

  initial begin
    // Initialize input
    db_button_in = 1; // Released state (active-low input)
   
    // Wait a few cycles
    repeat (5) @(posedge clk);
   
    // Simulate button press (active-low)
    db_button_in = 0;
    repeat (5) @(posedge clk);

    // Simulate button release -> should cause start_pulse
    db_button_in = 1;
    repeat (5) @(posedge clk);

    // Simulate another press-release later
    db_button_in = 0;
    repeat (5) @(posedge clk);
    db_button_in = 1;
    repeat (5) @(posedge clk);

    // Finish
    $stop;
  end
endmodule