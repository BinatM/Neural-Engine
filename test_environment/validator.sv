
module validator (
    input  wire                  clk,
    input  wire                  reset_n,
    input  wire                  dut_single_out,
    input  wire                  output_ready,
    output reg                   data_to_LED,
    output reg                   val_done,
    input  wire                  expected_single_out
);

// State encoding
typedef enum logic [1:0] {
    VAL_IDLE            = 2'd0,
    VAL_READ_SINGLE_BIT = 2'd1,
    VAL_WRITE_RESULT    = 2'd2,
    VAL_DONE            = 2'd3
} val_state_t;

val_state_t state, next_state;

reg actual_single_out;

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
        VAL_IDLE:            next_state = output_ready ? VAL_READ_SINGLE_BIT : VAL_IDLE;
        VAL_READ_SINGLE_BIT: next_state = VAL_WRITE_RESULT;
        VAL_WRITE_RESULT:    next_state = VAL_DONE;
        VAL_DONE:            next_state = VAL_DONE;
        default:             next_state = VAL_IDLE;
    endcase
end

// Output and data capture logic
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_to_LED       <= 1'b0;
        val_done          <= 1'b0;
        actual_single_out <= 1'b0;
    end else begin
        val_done <= (state == VAL_DONE);

        case (state)
            VAL_READ_SINGLE_BIT: begin
                actual_single_out <= dut_single_out;
            end
            VAL_WRITE_RESULT: begin
                data_to_LED <= (actual_single_out == expected_single_out);
            end
        endcase
    end
end

endmodule 
