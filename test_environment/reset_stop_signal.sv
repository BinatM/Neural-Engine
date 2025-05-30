module reset_stop_signal (
    input  wire clk,             // system clock
    input  wire db_button_in,    // debounced button input (active-low)
    output reg  stop_reset       // one-cycle stop pulse on release
);

    // Register to hold previous button state for edge detection
    reg prev_button;

    // Initialize registers for simulation
    initial begin
        prev_button  = 1'b1;     // assume button released at start
        stop_reset  = 1'b0;     // no pulse at start
    end

    always @(posedge clk) begin

        // Detect rising edge of db_button_in (release)  
        // and generate a one-cycle pulse
        stop_reset <= (prev_button == 1'b0 && db_button_in == 1'b1)
                       ? 1'b1
                       : 1'b0;

        // Update previous button state for next cycle
        prev_button <= db_button_in;
    end

endmodule
