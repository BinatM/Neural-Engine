module validator #(
    parameter ADDR_WIDTH = 11
)(
    input  wire                  clk,
    input  wire                  reset_n,

    // DUT signals
    input  wire                  output_ready, // DUT finished
    input  wire [15:0]           dut_output,

    // Memory interface
    output reg  [ADDR_WIDTH-1:0] address_out,
    output reg                   rd_en,
    output reg                   wr_en,
    input  wire [15:0]           mem_data_out,   // expected data read from on_chip_memory

    // Writing result back
    // data_to_mem will be used, 15:0
    output reg [15:0]           data_to_mem,

    // Validation done signal for top-level (optional)
    output reg                  val_done
);

    // States
    typedef enum logic [2:0] {
        VAL_IDLE,
        VAL_WAIT_DUT,
        VAL_READ_EXPECTED,
        VAL_WAIT_DATA,
        VAL_COMPARE,
        VAL_WRITE_RESULT,
        VAL_DONE
    } val_state_t;

    val_state_t state, next_state;

    reg [15:0] compare_result;
    reg [ADDR_WIDTH-1:0] expected_addr; // Address of the expected_output

    // Address where expected data is stored (example)
    localparam [ADDR_WIDTH-1:0] EXPECTED_BASE_ADDR = 11'd512;

    // State transitions
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= VAL_IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            VAL_IDLE: begin
                // Wait for trigger
                next_state = VAL_WAIT_DUT;
            end

            VAL_WAIT_DUT: begin
                // Waiting for output_ready from DUT
                if (output_ready)
                    next_state = VAL_READ_EXPECTED;
            end

            VAL_READ_EXPECTED: begin
                // Activating rd_en to on_chip_memory
                next_state = VAL_WAIT_DATA;
            end

            VAL_WAIT_DATA: begin
                // Wait one cycle for mem_data_out to stabilize
                next_state = VAL_COMPARE;
            end

            VAL_COMPARE: begin
                // Comparison
                next_state = VAL_WRITE_RESULT;
            end

            VAL_WRITE_RESULT: begin
                // Write Pass/Fail to on_chip_memory
                next_state = VAL_DONE;
            end

            VAL_DONE: begin
                // val_done = 1 for one cycle, then return to IDLE
                next_state = VAL_IDLE;
            end
        endcase
    end

    // Actions in each state
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            address_out    <= {ADDR_WIDTH{1'b0}};
            rd_en          <= 1'b0;
            wr_en          <= 1'b0;
            data_to_mem    <= 16'b0;
            compare_result <= 16'b0;
            val_done       <= 1'b0;

            expected_addr  <= EXPECTED_BASE_ADDR;

        end else begin
            // Defaults
            rd_en    <= 1'b0;
            wr_en    <= 1'b0;
            val_done <= 1'b0;

            case (state)
                VAL_IDLE: begin
                    // Reset expected_addr between cycles
                    expected_addr <= EXPECTED_BASE_ADDR;
                end

                VAL_WAIT_DUT: begin
                    // Waiting for output_ready
                end

                VAL_READ_EXPECTED: begin
                    // Set rd_en = 1 and address
                    rd_en      <= 1'b1;
                    address_out <= expected_addr; // Expected data address
                end

                VAL_WAIT_DATA: begin
                    // Next cycle mem_data_out is valid
                end

                VAL_COMPARE: begin
                    // Compare dut_output with mem_data_out
                    if (dut_output == mem_data_out)
                        compare_result <= 16'h55AA;  // pass
                    else
                        compare_result <= 16'hDEAD;  // fail
                end

                VAL_WRITE_RESULT: begin
                    // Write compare_result to on_chip_memory at a different address
                    wr_en       <= 1'b1;
                    address_out <= 11'd1000; // Example
                    data_to_mem <= compare_result;
                end

                VAL_DONE: begin
                    val_done <= 1'b1;
                end
            endcase
        end
    end
endmodule
