module validator #(
parameter ADDR_WIDTH = 11
)(
input  wire                  clk,
input  wire                  reset_n,

input  wire [15:0]           dut_data_out,
input  wire                  dut_single_out,
input  wire                  output_ready,

output reg  [ADDR_WIDTH-1:0] address_out,
output reg                   rd_en,
output reg                   wr_en,
input  wire [15:0]           mem_data_out,
output reg  [15:0]           data_to_mem,

input  wire                  gen_wr_en,
output reg                   val_done,

input  wire [15:0]           expected_word1,
input  wire [21:0]           expected_mac_output,
input  wire                  expected_single_out

);

typedef enum logic [3:0] {
    VAL_IDLE               = 4'd0,
    VAL_WAIT_AFTER_GEN_WR  = 4'd1,
    VAL_CAPTURE1           = 4'd2,
    VAL_CAPTURE2           = 4'd3,
    VAL_COMPARE            = 4'd4,
    VAL_WAIT_AFTER_COMPARE = 4'd5,
    VAL_WRITE_RESULT       = 4'd6,
    VAL_DONE               = 4'd7
} val_state_t;

val_state_t state, next_state;

localparam [ADDR_WIDTH-1:0] RESULT_ADDR = 11'd1000;

reg [7:0]  gen_wr_count;
reg        wr_count_done;
reg [21:0] actual_mac;
reg        actual_single_out;

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        gen_wr_count  <= 8'd0;
        wr_count_done <= 1'b0;
    end
    else if (!wr_count_done && gen_wr_en) begin
        gen_wr_count <= gen_wr_count + 1;
        if (gen_wr_count == 8'd65)
            wr_count_done <= 1'b1;
    end
end

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        state <= VAL_IDLE;
    else
        state <= next_state;
end

always_comb begin
    next_state = state;
    case (state)
        VAL_IDLE:               next_state = wr_count_done ? VAL_CAPTURE1 : VAL_IDLE;
        VAL_WAIT_AFTER_GEN_WR:  next_state = output_ready ? VAL_CAPTURE1 : VAL_WAIT_AFTER_GEN_WR;
        VAL_CAPTURE1:           next_state = VAL_CAPTURE2;
        VAL_CAPTURE2:           next_state = VAL_COMPARE;
        VAL_COMPARE:            next_state = VAL_WAIT_AFTER_COMPARE;
        VAL_WAIT_AFTER_COMPARE: next_state = VAL_WRITE_RESULT;
        VAL_WRITE_RESULT:       next_state = VAL_DONE;
        VAL_DONE:               next_state = VAL_DONE;
        default:                next_state = VAL_IDLE;
    endcase
end

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        address_out         <= '0;
        rd_en               <= 1'b0;
        wr_en               <= 1'b0;
        data_to_mem         <= 16'b0;
        val_done            <= 1'b0;
        actual_mac          <= 22'b0;
        actual_single_out   <= 1'b0;
    end else begin
        rd_en <= 1'b0;
        wr_en <= 1'b0;

        case (state)
            VAL_CAPTURE1: actual_mac[15:0] <= dut_data_out;
            VAL_CAPTURE2: begin
                actual_mac[21:16]  <= dut_data_out[5:0];
                actual_single_out  <= dut_single_out;
            end
            VAL_WRITE_RESULT: begin
                wr_en       <= 1'b1;
                address_out <= RESULT_ADDR;
                data_to_mem <= {14'b0, (actual_single_out == expected_single_out), (actual_mac == expected_mac_output)};
            end
            VAL_DONE: val_done <= 1'b1;
        endcase
    end
end

endmodule
