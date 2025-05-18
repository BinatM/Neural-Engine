`timescale 1ns/1ps

module tb_debounce;

  logic clk = 0;
  logic rst_n = 0;
  logic noisy_button;
  logic debounced_button;

  // Clock generation: 50MHz
  always #10 clk = ~clk;

  debounce_button #(.DELAY_MAX(8)) db_inst (  // small for tb
    .clk(clk),
    .rst_n(rst_n),
    .noisy_in(noisy_button),
    .clean_out(debounced_button)
  );

  initial begin
    // Reset
    rst_n = 0;
    noisy_button = 1;
    #50;
    rst_n = 1;

    // Bouncing press
    noisy_button = 0; @(posedge clk);
    noisy_button = 1; @(posedge clk);
    noisy_button = 0; @(posedge clk);
    noisy_button = 0; repeat (10) @(posedge clk); // stable press

    // Bouncing release
    noisy_button = 1; @(posedge clk);
    noisy_button = 0; @(posedge clk);
    noisy_button = 1; @(posedge clk);
    noisy_button = 1; repeat (10) @(posedge clk); // stable release

    $stop;
  end
endmodule