module reset_and_start (
    input  wire clk,             // system clock
    input  wire db_button_in,    // debounced button input (active-low)
    output reg  reset_n_out,     // system reset output (active-low)
    output reg  start_pulse      // one-cycle start pulse on release
);

    // Register to hold previous button state for edge detection
    reg prev_button;

    // Initialize registers for simulation
    initial begin
        prev_button  = 1'b1;     // assume button released at start
        start_pulse  = 1'b0;     // no pulse at start
    end

    always @(posedge clk) begin
        // Drive reset_n_out directly from the button:
        // reset is asserted (0) when button is pressed (db_button_in == 0)
        reset_n_out <= db_button_in;

        // Detect rising edge of db_button_in (release)  
        // and generate a one-cycle start pulse
        start_pulse <= (prev_button == 1'b0 && db_button_in == 1'b1)
                       ? 1'b1
                       : 1'b0;

        // Update previous button state for next cycle
        prev_button <= db_button_in;
    end

endmodule