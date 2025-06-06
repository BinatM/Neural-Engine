//------------------------------------------------------------------------------
// 16-bit LFSR: maximal-length pseudo-random generator
//------------------------------------------------------------------------------
module lfsr16 (
    input  logic        clk,
    input  logic        reset_n,
    output logic [15:0] random_value
);
    // Internal state register for LFSR
    logic [15:0] state;

        // Declare feedback separately (do NOT assign here)
    logic feedback;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Initialize with a non-zero seed
            state <= 16'hBEEF;
        end else begin
            // Compute feedback = XOR of taps (bits 15,13,12,10)
            feedback = state[15] ^ state[13] ^ state[12] ^ state[10];
            // Shift left and insert feedback into LSB
            state <= {state[14:0], feedback};
        end
    end


    assign random_value = state;
endmodule


//------------------------------------------------------------------------------
// Validator with random sampling delay after output_ready
//------------------------------------------------------------------------------
 
module validator (
    input  wire                  clk,
    input  wire                  reset_n,
    input  wire                  dut_single_out,
    input  wire                  output_ready,
input  wire                  chip_sel,
    output reg                   result_out,
    output reg                   val_done,
    input  wire                  expected_single_out
);

// Instantiate LFSR for random delay generation
    logic [15:0] lfsr_out;
    lfsr16 u_lfsr (
        .clk          (clk),
        .reset_n      (reset_n),
        .random_value (lfsr_out)
    );

// State encoding
typedef enum logic [2:0] {
    VAL_IDLE            = 3'd0,
VAL_WAIT_RANDOM     = 3'd1,
    VAL_READ_SINGLE_BIT = 3'd2,
    VAL_WRITE_RESULT    = 3'd3,
    VAL_DONE            = 3'd4
} val_state_t;

val_state_t state, next_state;


// Counter for random delay (0..7 cycles)
reg [2:0] gap_counter;


// Registers to latch DUT and expected values
reg actual_single_out;
reg actual_expected_out;


// FSM state register
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        state <= VAL_IDLE;
    else
        state <= next_state;
end

// FSM next state logic
always_comb begin
        next_state = state;

        case (state)
            // In IDLE, detect rising output_ready and move to VAL_WAIT_RANDOM
            VAL_IDLE: begin
                if (output_ready)
                    next_state = VAL_WAIT_RANDOM;  
                else
                    next_state = VAL_IDLE;
            end

            // In VAL_WAIT_RANDOM, remain until gap_counter == 0, then sample
            VAL_WAIT_RANDOM: begin
                if (gap_counter == 0)
                    next_state = VAL_READ_SINGLE_BIT;
                else
                    next_state = VAL_WAIT_RANDOM;
            end

            // Once gap has elapsed, sample DUT output
            VAL_READ_SINGLE_BIT: begin
                next_state = VAL_WRITE_RESULT;
            end

            // Compute comparison result and move to DONE
            VAL_WRITE_RESULT: begin
                next_state = VAL_DONE;
            end

            // Stay in DONE until output_ready de-asserts, then go to IDLE
            VAL_DONE: begin
                if (!output_ready)
                    next_state = VAL_IDLE;
                else
                    next_state = VAL_DONE;
            end

            default: next_state = VAL_IDLE;
        endcase
    end

//=======================================================================
//              Random delay counter logic
//=======================================================================
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            gap_counter <= '0;
        end else begin
            // When in IDLE and output_ready just asserted, load a random gap 0..7
            if (state == VAL_IDLE && output_ready) begin
                gap_counter <= lfsr_out[2:0] % 8;
            end
            // While waiting, decrement until zero
            else if (state == VAL_WAIT_RANDOM && gap_counter != 0) begin
                gap_counter <= gap_counter - 1;
            end
        end
    end



// Output and data capture logic
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        result_out           <= 1'b0;
        val_done             <= 1'b0;
        actual_single_out    <= 1'b0;
        actual_expected_out  <= 1'b0;
    end else begin
        // pulse high in the DONE state
        val_done <= (state == VAL_DONE);

        case (state)
            VAL_READ_SINGLE_BIT: begin
                // latch both sides of the comparison
                actual_single_out   <= dut_single_out;
                actual_expected_out <= expected_single_out;
            end

            VAL_WRITE_RESULT: begin
                // compare the two latched values
                result_out <= (actual_single_out == actual_expected_out);
            end

            default: begin
                // nothing else changes here
            end
        endcase
    end
end


endmodule 