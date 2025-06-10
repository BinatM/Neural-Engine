module test_generator #(
  parameter ADDR_WIDTH   = 16,
  parameter LOAD_DEPTH   = 66,
  parameter TOTAL_TESTS  = 500    // ← total number of tests
)(
  input  wire                   clk,
  input  wire                   reset,
  input  wire                   start,
  output reg  [ADDR_WIDTH-1:0]  address_BUS,
  output reg                    wr_en,
  output reg                    chip_sel,
  output reg  [8:0]             tests_count,
  input  wire                   val_done
);


  // simplified FSM: no more rd_en, always-combinational memory
  typedef enum logic [1:0] {
    IDLE     = 2'd0,
    WRITE    = 2'd1,
    WAIT_VAL = 2'd2,
    DONE     = 2'd3
  } state_t;

  state_t                   state;
  reg [ADDR_WIDTH-1:0]      addr_counter;
  reg                        chip_sel_hold;

  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // reset all registers
      state         <= IDLE;
      addr_counter  <= '0;
      chip_sel_hold <= 1'b0;
      address_BUS   <= '0;
      wr_en         <= 1'b0;
      chip_sel      <= 1'b0;
      tests_count   <= '0;
     end else begin
      // default: deassert write enable
      wr_en <= 1'b0;

      case (state)
        IDLE: begin
          // start next test when 'start' pulse arrives
          if (start && tests_count < TOTAL_TESTS) begin
            chip_sel_hold <= 1'b1;         // assert chip select for entire block
            addr_counter  <= '0;           // start at first word of test
            state         <= WRITE;
          end
        end

        WRITE: begin
          // every cycle: drive address
          address_BUS <= addr_counter + LOAD_DEPTH * tests_count;
          if (addr_counter == LOAD_DEPTH)
            state <= WAIT_VAL;            // finished writing 66 words
          else
            addr_counter <= addr_counter + 1;
        end

        WAIT_VAL: begin
          // wait for validator to finish, keep chip select high
          if (val_done) begin
            chip_sel_hold <= 1'b0;         // deassert chip select
            tests_count   <= tests_count + 1;
            if (tests_count == TOTAL_TESTS - 1)
              state <= DONE;               // all tests done
            else
              state <= IDLE;               // prepare for next test
          end
        end

        DONE: chip_sel_hold <= 1'b0;

        default: state <= IDLE;
      endcase

      // single-cycle delayed write strobe
      wr_en      <= (state == WRITE);

      // update chip select
      chip_sel   <= chip_sel_hold;
end
  end

endmodule