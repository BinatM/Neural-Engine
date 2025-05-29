// -----------------------------------------------------------------------------
// Simple SR flip-flop, asynchronous reset-dominant
// -----------------------------------------------------------------------------
module sr_ff (
    input  logic clk,          // any clock, used only for simulation stability
    input  logic rst_n,        // async clear  (active-low)
    input  logic set_pulse,    // one-clock pulse to latch Q = 1
    output logic Q             // latched flag
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            Q <= 1'b0;
        else if (set_pulse)
            Q <= 1'b1;
    end
endmodule
