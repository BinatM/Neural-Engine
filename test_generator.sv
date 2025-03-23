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
    output reg                     chip_sel   // DUT select
);

    // State machine
    typedef enum logic [2:0] {
        GEN_IDLE,
        GEN_READ_REQ,   
        GEN_WAIT_READ,  
        GEN_WRITE_DUT,  
        GEN_INC_ADDR,   
        GEN_DONE
    } gen_state_t;

    gen_state_t state, next_state;

    // Address counter
    reg [ADDR_WIDTH-1:0] addr_counter;

    // State update
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
                if (addr_counter == 8 - 1)
                    next_state = GEN_DONE;
                else
                    next_state = GEN_READ_REQ;
            end

            GEN_DONE: begin
                next_state = GEN_IDLE;
            end
        endcase
    end

    // State actions
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            address_BUS  <= '0;
            DATA_BUS     <= 16'b0;
            rd_en        <= 1'b0;
            wr_en        <= 1'b0;
            chip_sel     <= 1'b0;
            addr_counter <= '0;
        end
        else begin
            rd_en    <= 1'b0;
            wr_en    <= 1'b0;
            chip_sel <= 1'b0;

            case (state)
                GEN_IDLE: begin
                    address_BUS  <= 0;
                    DATA_BUS     <= 16'b0;
                    addr_counter <= 0;
                end

                GEN_READ_REQ: begin
                    address_BUS <= addr_counter;
                    rd_en       <= 1'b1;
                end

                GEN_WAIT_READ: begin
                    // Wait one cycle
                end

                GEN_WRITE_DUT: begin
                    chip_sel <= 1'b1;
                    wr_en    <= 1'b1;
                end

                GEN_INC_ADDR: begin
                    addr_counter <= addr_counter + 1;
                end

                GEN_DONE: begin
                    // Idle
                end
            endcase
        end
    end

endmodule
