module validator #(
    parameter ADDR_WIDTH = 11
)(
    input  wire                  clk,
    input  wire                  reset_n,

    // DUT signals
    input  wire                  output_ready,     // Indicates that DUT has valid outputs
    input  wire [21:0]           Mac_output,       // 22-bit output from DUT (MAC result)
    input  wire                  single_output,    // 1-bit output from DUT (e.g., pass/fail)

    // Memory interface
    output reg  [ADDR_WIDTH-1:0] address_out,      // Address to read from/write to memory
    output reg                   rd_en,            // Memory read enable
    output reg                   wr_en,            // Memory write enable
    input  wire [15:0]           mem_data_out,     // Data read from memory
    output reg [15:0]            data_to_mem,      // Data to write back to memory

    // Generator control
    input  wire                  gen_wr_en,        // High while generator writes 66 inputs to DUT
    output reg                   val_done          // High when validation completes (latched)
);

    // FSM states
    typedef enum logic [3:0] {
        VAL_IDLE,                  // Reset/initial state
        VAL_READ_EXPECTED1,       // Read lower 16 bits of expected MAC result
        VAL_WAIT_DATA1,           // Wait for memory output (word1)
        VAL_READ_EXPECTED2,       // Read upper 6 bits of MAC + expected single output
        VAL_WAIT_DATA2,           // Wait for memory output (word2)
        VAL_WAIT_AFTER_GEN_WR,    // Wait for generator to finish (66 cycles)
        VAL_CAPTURE_OUTPUTS,      // Outputs from DUT are stable and ready to compare
        VAL_COMPARE,              // Perform comparison between actual and expected
        VAL_WAIT_AFTER_COMPARE,   // Wait one cycle to allow comparison result to stabilize
        VAL_WRITE_RESULT,         // Write comparison result to memory
        VAL_DONE                  // Validation complete, val_done will remain high
    } val_state_t;

    val_state_t state, next_state;

    // Base addresses
    localparam [ADDR_WIDTH-1:0] EXPECTED_BASE_ADDR = 11'd512;   // Where expected data is stored
    localparam [ADDR_WIDTH-1:0] RESULT_ADDR        = 11'd1000;  // Where to write validation result

    // Counter to detect 66 cycles of gen_wr_en = 1
    reg [7:0]  gen_wr_count;
    reg        wr_count_done;

    // Expected data read from memory
    reg [15:0] expected_word1;       // Lower 16 bits of MAC output
    reg [15:0] expected_word2;       // Upper 6 bits of MAC (bits [5:0]) + expected 1-bit output (bit [6])
    reg [21:0] expected_mac_output;  // Full expected MAC result
    reg        expected_output;      // Expected 1-bit output from DUT

    // Count generator write enable cycles
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            gen_wr_count  <= 8'd0;
            wr_count_done <= 1'b0;
        end else if (!wr_count_done && gen_wr_en) begin
            gen_wr_count <= gen_wr_count + 1;
            if (gen_wr_count == 8'd65)
                wr_count_done <= 1'b1;  // Mark done when 66 cycles observed
        end
    end

    // FSM state transition
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
            VAL_IDLE:                  next_state = VAL_READ_EXPECTED1;
            VAL_READ_EXPECTED1:        next_state = VAL_WAIT_DATA1;
            VAL_WAIT_DATA1:            next_state = VAL_READ_EXPECTED2;
            VAL_READ_EXPECTED2:        next_state = VAL_WAIT_DATA2;
            VAL_WAIT_DATA2:            next_state = wr_count_done ? VAL_WAIT_AFTER_GEN_WR : VAL_WAIT_DATA2;
            VAL_WAIT_AFTER_GEN_WR:     next_state = output_ready ? VAL_CAPTURE_OUTPUTS : VAL_WAIT_AFTER_GEN_WR;
            VAL_CAPTURE_OUTPUTS:       next_state = VAL_COMPARE;
            VAL_COMPARE:               next_state = VAL_WAIT_AFTER_COMPARE;
            VAL_WAIT_AFTER_COMPARE:    next_state = VAL_WRITE_RESULT;
            VAL_WRITE_RESULT:          next_state = VAL_DONE;
            VAL_DONE:                  next_state = VAL_DONE;  // Remain here until reset
            default:                   next_state = VAL_IDLE;
        endcase
    end

    // FSM output and memory interaction logic
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
            expected_output     <= 1'b0;
        end else begin
            // Default signal values every clock
            rd_en    <= 1'b0;
            wr_en    <= 1'b0;

            case (state)
                VAL_IDLE: begin
                    val_done <= 1'b0;  // Reset val_done when starting over
                end

                VAL_READ_EXPECTED1: begin
                    rd_en       <= 1'b1;
                    address_out <= EXPECTED_BASE_ADDR;
                end

                VAL_WAIT_DATA1: begin
                    expected_word1 <= mem_data_out;  // Capture lower 16 bits
                end

                VAL_READ_EXPECTED2: begin
                    rd_en       <= 1'b1;
                    address_out <= EXPECTED_BASE_ADDR + 1;
                end

                VAL_WAIT_DATA2: begin
                    expected_word2      <= mem_data_out;
                    expected_mac_output <= {mem_data_out[5:0], expected_word1}; // Combine for 22-bit MAC
                    expected_output     <= mem_data_out[6];  // 1-bit expected output
                end

                VAL_WAIT_AFTER_GEN_WR: begin
                    // Wait here until DUT signals output_ready
                end

                VAL_CAPTURE_OUTPUTS: begin
                    // No need to capture – will compare directly from DUT signals
                end

                VAL_COMPARE: begin
                    // Delay 1 cycle to allow stable comparison
                end

                VAL_WAIT_AFTER_COMPARE: begin
                    // Nothing to do – comparison is stable now
                end

                VAL_WRITE_RESULT: begin
                    wr_en       <= 1'b1;
                    address_out <= RESULT_ADDR;
                    // Compare DUT vs expected and pack result:
                    // Bit 1 = match on single_output, Bit 0 = match on MAC
                    data_to_mem <= {
                        14'b0,
                        (single_output == expected_output),
                        (Mac_output     == expected_mac_output)
                    };
                end

                VAL_DONE: begin
                    val_done <= 1'b1;  // Remains high until reset
                end
            endcase
        end
    end

endmodule
