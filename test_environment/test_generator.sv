module test_generator #(
    parameter ADDR_WIDTH = 11
)(
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    start,

    // Address bus output for on_chip_memory
    output reg  [ADDR_WIDTH-1:0]   address_BUS,


    // Control signals
    output reg                     rd_en,     // Read from on_chip
    output reg                     wr_en,     // Write to DUT
    output reg                     chip_sel,  // DUT select

    // Data input from DUT
    input  wire                    output_ready
);

    // State machine definition
    typedef enum logic [2:0] {
        GEN_IDLE,
        GEN_READ_REQ,  
        GEN_WAIT_READ,
        GEN_WRITE_DUT,
        GEN_INC_ADDR,  
        GEN_DONE
    } gen_state_t;

    gen_state_t state, next_state;

    // Internal registers
    reg chip_sel_hold;
    reg output_ready_d;
    reg [ADDR_WIDTH-1:0] addr_counter;

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            GEN_IDLE: begin
                if (start)
                    next_state = GEN_READ_REQ;
            end
            GEN_READ_REQ: begin
                next_state = GEN_WAIT_READ;
            end
            GEN_WAIT_READ: begin
                next_state = GEN_WRITE_DUT;
            end
            GEN_WRITE_DUT: begin
                next_state = GEN_INC_ADDR;
            end
            GEN_INC_ADDR: begin
                if (addr_counter == 66 - 1)  // 64 inputs + 2 threshold
                    next_state = GEN_DONE;
                else
                    next_state = GEN_READ_REQ;
            end
            GEN_DONE: begin
                next_state = GEN_IDLE;
            end
        endcase
    end

    // Unified sequential block
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            // State machine
            state             <= GEN_IDLE;


            // Control and data signals
            chip_sel_hold     <= 1'b0;
            output_ready_d    <= 1'b0;
            addr_counter      <= '0;
            address_BUS       <= '0;
            rd_en             <= 1'b0;
            wr_en             <= 1'b0;
            chip_sel          <= 1'b0;
        end else begin
            // State transition
            state <= next_state;

            // Default signals each cycle
            rd_en    <= 1'b0;
            wr_en    <= 1'b0;

            // Latch and process output_ready
            output_ready_d <= output_ready;

            // Raise chip_sel_hold once we leave IDLE or DONE
            if (!chip_sel_hold && state != GEN_IDLE && state != GEN_DONE)
                chip_sel_hold <= 1;

            // Drop chip_sel_hold once DUT signals it's done
            if (chip_sel_hold && output_ready_d)
                chip_sel_hold <= 0;

            // Assign chip_sel output
            chip_sel <= chip_sel_hold;

            // FSM actions
            case (state)
                GEN_IDLE: begin
                    address_BUS  <= 0;
                    addr_counter <= 0;
                end
                GEN_READ_REQ: begin
                    address_BUS <= addr_counter;
                    rd_en       <= 1'b1;
                end
                GEN_WAIT_READ: begin
                end
                GEN_WRITE_DUT: begin
                    wr_en <= 1'b1;
                end
                GEN_INC_ADDR: begin
                    addr_counter <= addr_counter + 1;
                end
                GEN_DONE: begin
                    // stay idle
                end
            endcase
        end
    end

endmodule