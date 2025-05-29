module test_generator #(
    // Address width for on-chip memory
parameter ADDR_WIDTH = 16,
    // Number of words to stream per test (64 data + 2 threshold)
    parameter LOAD_DEPTH = 66,
parameter TOTAL_TESTS = 500

)(
    input  wire                    clk,        // system clock
    input  wire                    reset,      // active-low reset
    input  wire                    start,      // start pulse from control_unit

    output reg [ADDR_WIDTH-1:0]    address_BUS,// address to on-chip memory
    output reg                     rd_en,      // read enable for on-chip memory
    output reg                     wr_en,      // write enable to DUT bus
    output reg                     chip_sel,   // chip select for DUT
    output reg [8:0]               tests_count,
    input  wire                    val_done    // validation complete from validator
);

    // FSM states
    typedef enum logic [2:0] {
        GEN_IDLE      = 3'd0,  // waiting for start
        GEN_READ      = 3'd1,  // assert rd_en to fetch next word
        GEN_READ_WAIT = 3'd2,  // wait one cycle for memory output
        GEN_WRITE     = 3'd3,  // assert wr_en to drive DUT bus
        GEN_INC       = 3'd4,  // increment address counter
        GEN_WAIT_VAL  = 3'd5   // wait for validator to finish
    } gen_state_t;

    gen_state_t               state;          // current FSM state

    reg [ADDR_WIDTH-1:0]      addr_counter;   // memory address counter
    reg                       chip_sel_hold; // holds chip select high
    reg [TOTAL_TESTS-1:0]     Row_counter;


    // single clocked process for state and outputs
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            // reset all registers
            state           <= GEN_IDLE;
            addr_counter    <= '0;
            chip_sel_hold   <= 1'b0;
            address_BUS     <= '0;
            rd_en           <= 1'b0;
            wr_en           <= 1'b0;
            chip_sel        <= 1'b0;
            Row_counter     <= '0;
            tests_count     <= '0;
        end else begin
            // default deassertions
            rd_en <= 1'b0;
            wr_en <= 1'b0;

            // state transitions and output assertions
            case (state)
                GEN_IDLE: begin
                    if (start) begin
                        chip_sel_hold <= 1'b1;      // select DUT
                        addr_counter  <= '0;        // start at address
                        state         <= GEN_READ;
                    end
                end

                GEN_READ: begin
                    rd_en        <= 1'b1;           // read from on-chip memory
                    address_BUS  <= addr_counter + Row_counter*tests_count ;
                    state        <= GEN_READ_WAIT;
                end

                GEN_READ_WAIT: begin
                    state <= GEN_WRITE;
                end

                GEN_WRITE: begin
                    wr_en <= 1'b1;                  // drive data onto DUT bus
                    state <= GEN_INC;
                end

                GEN_INC: begin
                    if (addr_counter == LOAD_DEPTH - 1)
                        state <= GEN_WAIT_VAL;
                    else begin
                        addr_counter <= addr_counter + 1;
                        Row_counter<=Row_counter+1;
                        state        <= GEN_READ;
                    end
                end

                GEN_WAIT_VAL: begin
                    if (val_done) begin
                        chip_sel_hold <= 1'b0;      // deselect DUT after validation
                        state         <= GEN_IDLE;
                        tests_count<=tests_count+1;
                    end
                end

                default: state <= GEN_IDLE;
            endcase

            // update chip select output each cycle
            chip_sel <= chip_sel_hold;
        end
    end

endmodule