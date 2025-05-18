module reset_and_start (
    input  wire clk,                // system clock
    input  wire db_button_in,       // debounced KEY_0 (active-low)
    output reg  reset_n_out,        // active-low system reset
    output reg  start_pulse         // one-cycle start pulse on release
);

    reg prev_button;
    reg ready_to_start;

    always @(posedge clk) begin
        // Update system reset: active-low when button is pressed
        reset_n_out <= db_button_in;

        // Detect first actual press to enable future start pulses
        if (!ready_to_start && db_button_in == 1'b0)
            ready_to_start <= 1'b1;

        // Generate start pulse on release (0 ? 1), only after a press occurred
        if (ready_to_start && prev_button == 1'b0 && db_button_in == 1'b1)
            start_pulse <= 1'b1;
        else
            start_pulse <= 1'b0;

        // Update previous button state after using it
        prev_button <= db_button_in;
    end

endmodule