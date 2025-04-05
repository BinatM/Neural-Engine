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
    output reg [15:0]            data_to_mem,

    input  wire                  gen_wr_en,
    output reg                   val_done
);

    typedef enum logic [3:0] {
        VAL_IDLE               = 4'd0,
        VAL_READ_EXPECTED1     = 4'd1,
        VAL_WAIT_DATA1         = 4'd2,
        VAL_READ_EXPECTED2     = 4'd3,
        VAL_WAIT_DATA2         = 4'd4,
        VAL_WAIT_AFTER_GEN_WR  = 4'd5,
        VAL_CAPTURE1           = 4'd6,
        VAL_CAPTURE2           = 4'd7,
        VAL_WAIT_AFTER_CAPTURE = 4'd8,
        VAL_COMPARE            = 4'd9,
        VAL_WAIT_AFTER_COMPARE = 4'd10,
        VAL_WRITE_RESULT       = 4'd11,
        VAL_DONE               = 4'd12
    } val_state_t;

    val_state_t state, next_state;

    localparam [ADDR_WIDTH-1:0] EXPECTED_BASE_ADDR = 11'd512;
    localparam [ADDR_WIDTH-1:0] RESULT_ADDR        = 11'd1000;

    reg [7:0] gen_wr_count;
    reg wr_count_done;

    reg [15:0] expected_word1;
    reg [15:0] expected_word2;
    reg [21:0] expected_mac_output;
    reg        expected_single_out;

    reg [15:0] mac_lower;
    reg [5:0]  mac_upper;
    reg [21:0] actual_mac;
    reg        actual_single_out;

    reg        result_mac_match;
    reg        result_single_match;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            gen_wr_count  <= 8'd0;
            wr_count_done <= 1'b0;
        end else if (!wr_count_done && gen_wr_en) begin
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
            VAL_IDLE:                  next_state = VAL_READ_EXPECTED1;
            VAL_READ_EXPECTED1:        next_state = VAL_WAIT_DATA1;
            VAL_WAIT_DATA1:            next_state = VAL_READ_EXPECTED2;
            VAL_READ_EXPECTED2:        next_state = VAL_WAIT_DATA2;
            VAL_WAIT_DATA2:            next_state = wr_count_done ? VAL_WAIT_AFTER_GEN_WR : VAL_WAIT_DATA2;
            VAL_WAIT_AFTER_GEN_WR:     next_state = output_ready ? VAL_CAPTURE1 : VAL_WAIT_AFTER_GEN_WR;
            VAL_CAPTURE1:              next_state = VAL_CAPTURE2;
            VAL_CAPTURE2:              next_state = VAL_WAIT_AFTER_CAPTURE;
            VAL_WAIT_AFTER_CAPTURE:    next_state = VAL_COMPARE;
            VAL_COMPARE:               next_state = VAL_WAIT_AFTER_COMPARE;
            VAL_WAIT_AFTER_COMPARE:    next_state = VAL_WRITE_RESULT;
            VAL_WRITE_RESULT:          next_state = VAL_DONE;
            VAL_DONE:                  next_state = VAL_DONE;
            default:                   next_state = VAL_IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            address_out         <= '0;
            rd_en               <= 1'b0;
            wr_en               <= 1'b0;
            data_to_mem         <= 16'b0;
            val_done            <= 1'b0;

            expected_word1      <= 16'b0;
            expected_word2      <= 16'b0;
            expected_mac_output <= 22'b0;
            expected_single_out <= 1'b0;

            mac_lower           <= 16'b0;
            mac_upper           <= 6'b0;
            actual_mac          <= 22'b0;
            actual_single_out   <= 1'b0;

            result_mac_match    <= 1'b0;
            result_single_match <= 1'b0;
        end else begin
            rd_en <= 1'b0;
            wr_en <= 1'b0;

            case (state)
                VAL_IDLE: begin
                    val_done <= 1'b0;
                end

                VAL_READ_EXPECTED1: begin
                    rd_en       <= 1'b1;
                    address_out <= EXPECTED_BASE_ADDR;
                end

                VAL_WAIT_DATA1: begin
                    expected_word1 <= mem_data_out;
                end

                VAL_READ_EXPECTED2: begin
                    rd_en       <= 1'b1;
                    address_out <= EXPECTED_BASE_ADDR + 1;
                end

                VAL_WAIT_DATA2: begin
                    expected_word2      <= mem_data_out;
                    expected_mac_output <= {mem_data_out[5:0], expected_word1};
                    expected_single_out <= mem_data_out[6];
                end

                VAL_CAPTURE1: begin
                    mac_lower <= dut_data_out;
                end

                VAL_CAPTURE2: begin
                    mac_upper <= dut_data_out[5:0];
                    actual_single_out <= dut_single_out;
                end

                VAL_WAIT_AFTER_CAPTURE: begin
                    actual_mac <= {mac_upper, mac_lower};
                end

                VAL_COMPARE: begin
                    result_mac_match    <= (actual_mac == expected_mac_output);
                    result_single_match <= (actual_single_out == expected_single_out);
                end

                VAL_WAIT_AFTER_COMPARE: begin
                    // Wait one cycle
                end

                VAL_WRITE_RESULT: begin
                    wr_en       <= 1'b1;
                    address_out <= RESULT_ADDR;
                    data_to_mem <= {14'b0, result_single_match, result_mac_match};
                end

                VAL_DONE: begin
                    val_done <= 1'b1;
                end
            endcase
        end
    end

endmodule