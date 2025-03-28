module test_generator #(
    parameter ADDR_WIDTH = 11
)(
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    start,

    // Address bus output for on_chip_memory
    output reg  [ADDR_WIDTH-1:0]   address_BUS,

    // Data bus to DUT
    output reg  [15:0]             DATA_BUS,

    // Control signals
    output reg                     rd_en,     // Read from on_chip
    output reg                     wr_en,     // Write to DUT
    output reg                     chip_sel,  // DUT select

    // Data input from on_chip_memory
    input  wire [15:0]             mem_data_in,
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

            reg [7:0] chip_sel_duration;
// Internal control
    reg chip_sel_hold;
    reg output_ready_d;

// Address counter
    reg [ADDR_WIDTH-1:0] addr_counter;

    // State update logic
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            state <= GEN_IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            GEN_IDLE: begin
                // Wait for start signal
                if (start)
                    next_state = GEN_READ_REQ;
            end

            GEN_READ_REQ: begin
                // Issue read request to memory
                next_state = GEN_WAIT_READ;
            end

            GEN_WAIT_READ: begin
                // Wait one cycle for memory data to become available
                next_state = GEN_WRITE_DUT;
            end

            GEN_WRITE_DUT: begin
                // Send data to DUT with control signals
                next_state = GEN_INC_ADDR;
            end

            GEN_INC_ADDR: begin
                // Increment address counter, check if done
                if (addr_counter == 66 - 1)  // 64 inputs/weights + 2 threshold words
                    next_state = GEN_DONE;
                else
                    next_state = GEN_READ_REQ;
            end

            GEN_DONE: begin
                // Transfer complete, go back to idle
                next_state = GEN_IDLE;
            end
        endcase
    end

    // State actions
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin

            chip_sel_hold <= 1'b0;
            output_ready_d <= 1'b0;
            address_BUS  <= '0;
            DATA_BUS     <= 16'b0;
            rd_en        <= 1'b0;
            wr_en        <= 1'b0;
            chip_sel     <= 1'b0;
            addr_counter <= '0;
        end
        else begin
            // Default signal values
            rd_en    <= 1'b0;
            wr_en    <= 1'b0;
            // chip_sel is now controlled by chip_sel_hold logic
            chip_sel <= chip_sel_hold;

            case (state)
                GEN_IDLE: begin
                    // Reset counters and buses
                    address_BUS  <= 0;
                    DATA_BUS     <= 16'b0;
                    addr_counter <= 0;
                end

                GEN_READ_REQ: begin
                    // Send memory address and trigger read
                    address_BUS <= addr_counter;
                    rd_en       <= 1'b1;
                end

                GEN_WAIT_READ: begin
                    // Latch memory data into DATA_BUS
                    DATA_BUS <= mem_data_in;
                end

                GEN_WRITE_DUT: begin
                    // Send data and control signals to DUT
                    wr_en    <= 1'b1;
                end

                GEN_INC_ADDR: begin
                    // Move to next address
                    addr_counter <= addr_counter + 1;
                end

                GEN_DONE: begin
                    // Remain idle until next start
                end
            endcase
        end
    end


   
    // Manage chip_sel_hold: assert once generator starts, deassert after output_ready
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            chip_sel_hold <= 1'b0;
            output_ready_d <= 1'b0;
            chip_sel_duration <= 8'd0;
        end else begin
            output_ready_d <= output_ready;

            // Raise chip_sel_hold once we leave IDLE
            if (!chip_sel_hold && state != GEN_IDLE && state != GEN_DONE)
                chip_sel_hold <= 1;

            // Stop holding chip_sel one cycle after output_ready is high
            if (chip_sel_hold && output_ready_d)
                chip_sel_hold <= 0;

            // Track how long chip_sel is held high
            if (chip_sel)
                chip_sel_duration <= chip_sel_duration + 1;
        end
    end

endmodule
