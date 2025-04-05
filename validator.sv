module validator #(
    parameter ADDR_WIDTH = 11
)(
    input  wire                  clk,
    input  wire                  reset_n,

    //---------------------------------------------------------
    // DUT signals
    //---------------------------------------------------------
    input  wire [15:0]           dut_data_out,  // partial MAC (two cycles)
    input  wire                  dut_single_out,// single line from DUT
    input  wire                  output_ready,  // asserts when new data is valid

    //---------------------------------------------------------
    // Memory interface
    //---------------------------------------------------------
    output reg  [ADDR_WIDTH-1:0] address_out,
    output reg                   rd_en,
    output reg                   wr_en,
    input  wire [15:0]           mem_data_out,
    output reg [15:0]            data_to_mem,

    //---------------------------------------------------------
    // Generator control
    //---------------------------------------------------------
    input  wire                  gen_wr_en,    // high while generator writes 66 inputs
    output reg                   val_done      // high when validation completes
);

    // -------------------------------------------------------
    // FSM states — 4 bits wide
    // -------------------------------------------------------
    typedef enum logic [3:0] {
        VAL_IDLE               = 4'd0,

        // read expected 22-bit MAC + 1-bit from memory
        VAL_READ_EXPECTED1     = 4'd1,   // read lower 16 bits
        VAL_WAIT_DATA1         = 4'd2,
        VAL_READ_EXPECTED2     = 4'd3,   // read upper 6 bits + 1-bit output (in memory)
        VAL_WAIT_DATA2         = 4'd4,

        // wait for generator writes to finish
        VAL_WAIT_AFTER_GEN_WR  = 4'd5,

        // two-cycle capture from the DUT
        VAL_CAPTURE1           = 4'd6,
        VAL_CAPTURE2           = 4'd7,

        // comparison
        VAL_COMPARE            = 4'd8,
        VAL_WAIT_AFTER_COMPARE = 4'd9,
        VAL_WRITE_RESULT       = 4'd10,
        VAL_DONE               = 4'd11
    } val_state_t;

    val_state_t state, next_state;

    // -------------------------------------------------------
    // Memory addresses for expected data
    // -------------------------------------------------------
    localparam [ADDR_WIDTH-1:0] EXPECTED_BASE_ADDR = 11'd512;
    localparam [ADDR_WIDTH-1:0] RESULT_ADDR        = 11'd1000;

    // -------------------------------------------------------
    // track gen_wr_en cycles
    // -------------------------------------------------------
    reg [7:0]  gen_wr_count;
    reg        wr_count_done;

    // -------------------------------------------------------
    // expected data from memory
    // -------------------------------------------------------
    reg [15:0] expected_word1;      // lower 16 bits of MAC
    reg [15:0] expected_word2;      // upper 6 bits in [5:0], single_out in [6]
    reg [21:0] expected_mac_output; // 22-bit MAC
    reg        expected_single_out; // 1-bit from memory

    // -------------------------------------------------------
    // actual data from DUT
    // -------------------------------------------------------
    reg [21:0] actual_mac;
    reg        actual_single_out;

    // -------------------------------------------------------
    // Count generator write cycles
    // -------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            gen_wr_count  <= 8'd0;
            wr_count_done <= 1'b0;
        end
        else if (!wr_count_done && gen_wr_en) begin
            gen_wr_count <= gen_wr_count + 1;
            if (gen_wr_count == 8'd65)
                wr_count_done <= 1'b1; // done after 66 writes
        end
    end

    // -------------------------------------------------------
    // FSM register
    // -------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= VAL_IDLE;
        else
            state <= next_state;
    end

    // -------------------------------------------------------
    // FSM next-state logic
    // -------------------------------------------------------
    always_comb begin
        next_state = state;
        case (state)
            VAL_IDLE: 
                next_state = VAL_READ_EXPECTED1;

            VAL_READ_EXPECTED1:
                next_state = VAL_WAIT_DATA1;

            VAL_WAIT_DATA1:
                next_state = VAL_READ_EXPECTED2;

            VAL_READ_EXPECTED2:
                next_state = VAL_WAIT_DATA2;

            VAL_WAIT_DATA2:
                next_state = wr_count_done ? VAL_CAPTURE1: : VAL_WAIT_DATA2;

            VAL_CAPTURE1:
                next_state = VAL_CAPTURE2;

            VAL_CAPTURE2:
                next_state = VAL_COMPARE;

            VAL_COMPARE:
                next_state = VAL_WAIT_AFTER_COMPARE;

            VAL_WAIT_AFTER_COMPARE:
                next_state = VAL_WRITE_RESULT;

            VAL_WRITE_RESULT:
                next_state = VAL_DONE;

            VAL_DONE:
                next_state = VAL_DONE; // remain

            default: 
                next_state = VAL_IDLE;
        endcase
    end

    // -------------------------------------------------------
    // FSM output & memory interaction
    // -------------------------------------------------------
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

            actual_mac          <= 22'b0;
            actual_single_out   <= 1'b0;
        end 
        else begin
            // Defaults each cycle
            rd_en <= 1'b0;
            wr_en <= 1'b0;

            case (state)
                VAL_IDLE: begin
                    val_done <= 1'b0;
                end

                // read the expected 22-bit MAC from memory
                VAL_READ_EXPECTED1: begin
                    rd_en       <= 1'b1;
                    address_out <= EXPECTED_BASE_ADDR;
                end

                VAL_WAIT_DATA1: begin
                    expected_word1 <= mem_data_out; // lower 16 bits
                end

                VAL_READ_EXPECTED2: begin
                    rd_en       <= 1'b1;
                    address_out <= EXPECTED_BASE_ADDR + 1;
                end

                VAL_WAIT_DATA2: begin
                    expected_word2      <= mem_data_out;
                    // bits [5:0] => upper MAC
                    // bit  [6]   => single_out
                    expected_mac_output <= {mem_data_out[5:0], expected_word1};
                    expected_single_out <= mem_data_out[6];
                end

                // wait for generator writes to be done
                // then wait for DUT output_ready
                VAL_WAIT_AFTER_GEN_WR: begin
                    // no action; waiting for output_ready => next_state = VAL_CAPTURE1
                end

                // 2-cycle capture
                VAL_CAPTURE1: begin
                    // lower 16 bits from DUT
                    actual_mac[15:0] <= dut_data_out;
                end

                VAL_CAPTURE2: begin
                    // upper 6 bits in dut_data_out[5:0]
                    actual_mac[21:16]  <= dut_data_out[5:0];
                    // single_out is direct from separate line
                    actual_single_out  <= dut_single_out;
                end

                VAL_COMPARE: begin
                    // Delay 1 cycle
                end

                VAL_WAIT_AFTER_COMPARE: begin
                    // stable
                end

                VAL_WRITE_RESULT: begin
                    wr_en       <= 1'b1;
                    address_out <= RESULT_ADDR;

                    // Compare 2 bits => single_out match + MAC match
                    data_to_mem <= {
                        14'b0,
                        (actual_single_out == expected_single_out),
                        (actual_mac        == expected_mac_output)
                    };
                end

                VAL_DONE: begin
                    val_done <= 1'b1; // remain high
                end
            endcase
        end
    end

endmodule
