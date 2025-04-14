module debounce_button #(
    parameter DELAY_MAX = 100_000  // ~2ms if clock=50MHz; adjust as needed
)(
    input  wire clk,
    input  wire rst_n,
    input  wire noisy_in,    // raw push-button, active-low
    output reg  clean_out    // stable, active-low
);

    reg [16:0] counter;
    reg sync_reg1, sync_reg2, stable_in;

    // Synchronize input to the clk domain
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg1 <= 1'b0;
            sync_reg2 <= 1'b0;
        end
        else begin
            sync_reg1 <= noisy_in;
            sync_reg2 <= sync_reg1;
        end
    end

    // Debounce logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= 0;
            stable_in <= 1'b1;  // default to 'not pressed' if active-low
            clean_out <= 1'b1; 
        end
        else begin
            if (sync_reg2 != stable_in) begin
                // input changed -> reset counter
                counter   <= 0;
                stable_in <= sync_reg2;
            end
            else if (counter < DELAY_MAX) begin
                counter <= counter + 1;
            end

            if (counter == DELAY_MAX) begin
                clean_out <= stable_in;  // stable version of active-low
            end
        end
    end
endmodule
