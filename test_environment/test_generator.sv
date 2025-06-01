module test_generator #(
  parameter ADDR_WIDTH = 16,
  parameter LOAD_DEPTH = 66,
  parameter TOTAL_TESTS = 500    // ← total number of tests
)(
  input  wire           clk,
  input  wire           reset,
  input  wire           start,
  output reg  [ADDR_WIDTH-1:0] address_BUS,
  output reg            rd_en,
  output reg            wr_en,
  output reg            chip_sel,
  output reg  [8:0]     tests_count,
  input  wire           val_done
);

  typedef enum logic [2:0] {
    GEN_IDLE      = 3'd0,
    GEN_READ      = 3'd1,
    GEN_READ_WAIT = 3'd2,
    GEN_WRITE     = 3'd3,
    GEN_INC       = 3'd4,
    GEN_WAIT_VAL  = 3'd5,
    GEN_DONE      = 3'd6      // ← terminal state
  } gen_state_t;

  gen_state_t state;
  reg [ADDR_WIDTH-1:0] addr_counter;
  reg chip_sel_hold;

  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      state         <= GEN_IDLE;
      addr_counter  <= '0;
      chip_sel_hold <= 1'b0;
      address_BUS   <= '0;
      rd_en         <= 1'b0;
      wr_en         <= 1'b0;
      chip_sel      <= 1'b0;
      tests_count   <= '0;
    end else begin
      // default outputs
      rd_en <= 1'b0;
      wr_en <= 1'b0;

      case(state)
        GEN_IDLE: begin
          // only start if we haven’t done all tests yet
          if (start && tests_count < TOTAL_TESTS) begin
            chip_sel_hold <= 1'b1;
            addr_counter  <= '0;
            state         <= GEN_READ;
          end
        end

        GEN_READ: begin
          rd_en       <= 1'b1;
          address_BUS <= addr_counter + LOAD_DEPTH*tests_count;
          state       <= GEN_READ_WAIT;
        end

        GEN_READ_WAIT: state <= GEN_WRITE;

        GEN_WRITE: begin
          wr_en <= 1'b1;
          state <= GEN_INC;
        end

        GEN_INC: begin
          if (addr_counter == LOAD_DEPTH - 1)
            state <= GEN_WAIT_VAL;
          else begin
            addr_counter <= addr_counter + 1;
            state        <= GEN_READ;
          end
        end

        GEN_WAIT_VAL: begin
          if (val_done) begin
            chip_sel_hold <= 1'b0;
            tests_count   <= tests_count + 1;
            // if that was the last test, go to DONE
            if (tests_count == TOTAL_TESTS - 1)
              state <= GEN_DONE;
            else
              state <= GEN_IDLE;
          end
        end

        // once here, never drive anything else
        GEN_DONE: begin
          chip_sel_hold <= 1'b0;
          // rd_en, wr_en stay at 0 forever
        end

        default: state <= GEN_IDLE;
      endcase

      chip_sel <= chip_sel_hold;
    end
  end
endmodule
