module reset_and_start (
    input  wire clk,
    input  wire db_button_in,
    output reg  reset_n_out,
    output reg  start_pulse
);

    reg prev_button;
    reg ready_to_start;

    always @(posedge clk) begin
        // Update system reset: active-low when button is pressed
        reset_n_out <= db_button_in;

        // Default no pulse
        start_pulse <= 1'b0;

        // Enable start generation only after first press
        if (!ready_to_start && db_button_in == 1'b0)
            ready_to_start <= 1'b1;

        // Generate start pulse on release
        if (ready_to_start && prev_button == 1'b0 && db_button_in == 1'b1)
            start_pulse <= 1'b1;

        // Update previous state (must be after using it!)
        prev_button <= db_button_in;
    end
endmodule