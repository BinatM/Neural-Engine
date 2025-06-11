//------------------------------------------------------------------------------
// 16-bit LFSR: maximal-length pseudo-random generator (fixed for synthesis)
//------------------------------------------------------------------------------
module lfsr16 (
    input  logic        clk,
    input  logic        reset_n,
    output logic [15:0] random_value
);
    // Internal state register
    logic [15:0] state;
    // Feedback bit must be declared here (no initializer)
    logic         feedback;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Initialize with a non-zero seed
            state <= 16'hBEEF;
        end else begin
            // Compute feedback = XOR of taps (bits 15, 13, 12, 10)
            feedback = state[15] ^ state[13] ^ state[12] ^ state[10];
            // Shift left and insert feedback into LSB
            state <= {state[14:0], feedback};
        end
    end

    // Drive the LFSR output
    assign random_value = state;
endmodule

//------------------------------------------------------------------------------
// test_generator with a single random chip_sel drop per test
//------------------------------------------------------------------------------
module test_generator #(
  parameter ADDR_WIDTH   = 16,
  parameter LOAD_DEPTH   = 66,
  parameter TOTAL_TESTS  = 10   // total number of tests
)(
  input  wire                   clk,
  input  wire                   reset,       // active-low reset
  input  wire                   start,       // start pulse
  output reg  [ADDR_WIDTH-1:0]  address_BUS,
  output reg                    wr_en,       // single-cycle write strobe
  output reg                    chip_sel,    // chip select
  output reg  [8:0]             tests_count, // completed tests
  input  wire                   val_done     // validator done pulse
);

  // Instantiate LFSR for randomness
  logic [15:0] lfsr_out;
  lfsr16 u_lfsr (
    .clk         (clk),
    .reset_n     (reset),
    .random_value(lfsr_out)
  );

  // State encoding: IDLE, WRITE, RESET_CHIP, WAIT_VAL, DONE
  typedef enum logic [2:0] {
    IDLE        = 3'd0,
    WRITE       = 3'd1,
    RESET_CHIP  = 3'd2,
    WAIT_VAL    = 3'd3,
    DONE        = 3'd4
  } state_t;

  state_t                   state;
  reg [ADDR_WIDTH-1:0]      addr_counter;
  reg                        chip_sel_hold;
  reg                        drop_done;    // flag to allow one drop per test

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
      drop_done     <= 1'b0;
    end else begin
      // default: deassert write strobe
      wr_en <= 1'b0;

      case (state)
        IDLE: begin
          // start next test when 'start' arrives
          if (start && tests_count < TOTAL_TESTS) begin
            chip_sel_hold <= 1'b1;  // assert chip select
            addr_counter  <= '0;    // reset address counter
            drop_done     <= 1'b0;  // allow one drop this test
            state         <= WRITE;
          end
        end

        WRITE: begin
          // perform one-time random drop
          if (!drop_done && lfsr_out[0]) begin
            chip_sel_hold <= 1'b0;  // deassert chip select
            drop_done     <= 1'b1;  // mark drop done
            state         <= RESET_CHIP;
          end else begin
            // drive address for this cycle
            address_BUS <= addr_counter + LOAD_DEPTH * tests_count;
            if (addr_counter == LOAD_DEPTH)
              state <= WAIT_VAL;    // all words written
            else
              addr_counter <= addr_counter + 1;
          end
        end

        RESET_CHIP: begin
          // reassert chip select and restart the same test
          chip_sel_hold <= 1'b1;
          addr_counter  <= '0;
          state         <= WRITE;
        end

        WAIT_VAL: begin
          // wait for validator to finish
          if (val_done) begin
            chip_sel_hold <= 1'b0;  // deassert chip select
            tests_count   <= tests_count + 1;
            if (tests_count == TOTAL_TESTS-1)
              state <= DONE;
            else
              state <= IDLE;
          end
        end

        DONE: begin
          chip_sel_hold <= 1'b0;    // ensure chip select low
        end

        default: state <= IDLE;
      endcase

      // single-cycle delayed write strobe
      wr_en <= (state == WRITE);

      // update chip select output
      chip_sel <= chip_sel_hold;
    end
  end

endmodule