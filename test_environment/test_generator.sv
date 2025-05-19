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

    input  wire                    val_done   // signal from validator indicating write is done
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

    gen_state_t state;

    // Internal registers
    reg chip_sel_hold;
    reg [ADDR_WIDTH-1:0] addr_counter;

    // FSM + logic
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            state         <= GEN_IDLE;
            chip_sel_hold <= 1'b0;
            addr_counter  <= '0;
            address_BUS   <= '0;
            rd_en         <= 1'b0;
            wr_en         <= 1'b0;
            chip_sel      <= 1'b0;
        end else begin
            // Default control signals
            rd_en    <= 1'b0;
            wr_en    <= 1'b0;

            // FSM transitions and control logic
            case (state)
                GEN_IDLE: begin
                    if (start) begin
                        addr_counter  <= 0;
                        address_BUS   <= 0;
                        chip_sel_hold <= 1'b1;
                        state         <= GEN_READ_REQ;
                    end
                end

                GEN_READ_REQ: begin
                    rd_en       <= 1'b1;
                    address_BUS <= addr_counter;
                    state       <= GEN_WAIT_READ;
                end

                GEN_WAIT_READ: begin
                    state <= GEN_WRITE_DUT;
                end

                GEN_WRITE_DUT: begin
                    wr_en <= 1'b1;
                    state <= GEN_INC_ADDR;
                end

                GEN_INC_ADDR: begin
                    addr_counter <= addr_counter + 1;
                    if (addr_counter == 66 - 1)
                        state <= GEN_DONE;
                    else
                        state <= GEN_READ_REQ;
                end

                GEN_DONE: begin
                    if (val_done)
                        chip_sel_hold <= 1'b0;
                    if (!chip_sel_hold)
                        state <= GEN_IDLE;
                end

                default: state <= GEN_IDLE;
            endcase

            // chip_sel stays high until val_done is received in GEN_DONE
            chip_sel <= chip_sel_hold;
        end
    end

endmodule