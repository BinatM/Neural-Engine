module debounce_button #(
    parameter DELAY_MAX = 100_000  // Number of clock cycles required for input to be considered stable
)(
    input  wire clk,
    input  wire rst_n,
    input  wire noisy_in,    // Raw (possibly bouncing) input signal
    output reg  clean_out    // Debounced and stable output signal
);

    // Double-flop synchronizer to avoid metastability
    reg sync_reg1, sync_reg2;

    // Debounce state and counter
    reg [31:0] counter;
    reg stable_in;

    // Input synchronization to clk domain
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg1 <= 1'b1;
            sync_reg2 <= 1'b1;
        end else begin
            sync_reg1 <= noisy_in;
            sync_reg2 <= sync_reg1;
        end
    end

    // Debounce filtering logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter    <= 0;
            stable_in  <= 1'b1;
            clean_out  <= 1'b1;
        end else begin
            if (sync_reg2 != stable_in) begin
                // Input differs from current stable state → count duration
                counter <= counter + 1;

                if (counter >= DELAY_MAX - 1) begin
                    // Input remained different long enough → accept as new stable value
                    stable_in <= sync_reg2;
                    clean_out <= sync_reg2;
                    counter   <= 0;
                end
            end else begin
                // Input is same as stable state → reset counter
                counter <= 0;
            end
        end
    end

endmodule