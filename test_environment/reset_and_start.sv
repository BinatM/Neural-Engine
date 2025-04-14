module reset_and_start(
    input  wire clk,
    input  wire db_button_in, // debounced KEY_0, active-low
    output reg  reset_n_out,  // final system reset (active-low)
    output reg  start_pulse   // single-cycle active-high on reset release
);
    reg prev_button;
    reg [3:0] release_counter;
    reg       state_reset;

    always @(posedge clk) begin
        prev_button <= db_button_in;

        // If button is pressed (db_button_in=0), hold system in reset
        // Once button is released (db_button_in=1), wait a few cycles, then un-reset
        if (db_button_in == 1'b0) begin
            reset_n_out <= 1'b0;
            release_counter <= 0;
            state_reset <= 1'b1;
        end 
        else begin // db_button_in=1 => button not pressed
            if (state_reset) begin
                if (release_counter < 4) begin
                    release_counter <= release_counter + 1;
                    reset_n_out     <= 1'b0;
                end
                else begin
                    reset_n_out     <= 1'b1;
                    state_reset     <= 1'b0;
                end
            end 
            else begin
                reset_n_out <= 1'b1; // remain out of reset
            end
        end
    end

    // Generate a 1-cycle pulse on the rising edge of reset_n_out
    reg prev_reset_n;
    always @(posedge clk) begin
        prev_reset_n <= reset_n_out;
        if (!prev_reset_n && reset_n_out) begin
            // rising edge of reset_n_out => start
            start_pulse <= 1'b1;
        end else begin
            start_pulse <= 1'b0;
        end
    end

endmodule
