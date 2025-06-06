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




module test_generator #(
  parameter ADDR_WIDTH = 16,
  parameter LOAD_DEPTH = 66,
  parameter TOTAL_TESTS = 500,    // ← total number of tests
  parameter MAX_RANDOM_GAP = 7    // max random gap between data words (0..7)
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

  typedef enum logic [3:0] {
    GEN_IDLE        = 4'd0,
GEN_WAIT_RANDOM = 4'd1,
    GEN_READ        = 4'd2,
    GEN_READ_WAIT   = 4'd3,
    GEN_WRITE       = 4'd4,
    GEN_INC         = 4'd5,
GEN_CHIP_RESET  = 4'd6,
    GEN_WAIT_VAL    = 4'd7,
    GEN_DONE        = 4'd8      // ← terminal state
  } gen_state_t;

 
  // Instantiate LFSR
  logic [15:0] lfsr_out;
  lfsr16 u_lfsr (
    .clk        (clk),
    .reset_n    (reset),
    .random_value(lfsr_out)
  );
 
 
  gen_state_t state;
  reg [ADDR_WIDTH-1:0] addr_counter;
  reg [2:0]            gap_counter;    
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
    gap_counter   <= '0;
  end else begin
    // default pins for this clock cycle
    rd_en <= 1'b0;
    wr_en <= 1'b0;

    // 1) Random‐reset takes priority: if we are in GEN_READ or GEN_WRITE AND lfsr_out[0]==1,
    //    immediately jump to GEN_CHIP_RESET and skip all other state logic.
    if ((state == GEN_READ || state == GEN_WRITE) && lfsr_out[0]) begin
      state <= GEN_CHIP_RESET;
    end else begin
      // 2) Otherwise, run the normal FSM transitions:
      case (state)
        GEN_IDLE: begin
          if (start && tests_count < TOTAL_TESTS) begin
            chip_sel_hold <= 1'b1;
            addr_counter  <= '0;
            // sample random gap (0..MAX_RANDOM_GAP)
            gap_counter   <= lfsr_out[2:0] % (MAX_RANDOM_GAP + 1);
            state         <= GEN_WAIT_RANDOM;
          end
        end

        GEN_WAIT_RANDOM: begin
          chip_sel_hold <= 1'b1;
          if (gap_counter != 0) begin
            gap_counter <= gap_counter - 1;
            state       <= GEN_WAIT_RANDOM;
          end else begin
            state <= GEN_READ;
          end
        end

        GEN_READ: begin
          rd_en       <= 1'b1;
          address_BUS <= addr_counter + LOAD_DEPTH * tests_count;
          state       <= GEN_READ_WAIT;
        end

        GEN_READ_WAIT: state <= GEN_WRITE;

        GEN_WRITE: begin
          wr_en <= 1'b1;
          state <= GEN_INC;
        end

        GEN_INC: begin
          if (addr_counter == LOAD_DEPTH - 1) begin
            state <= GEN_WAIT_VAL;
          end else begin
            addr_counter <= addr_counter + 1;
            // sample new random gap
            gap_counter  <= lfsr_out[2:0] % (MAX_RANDOM_GAP + 1);
            state        <= GEN_WAIT_RANDOM;
          end
        end

        GEN_CHIP_RESET: begin
          // drop chip_sel for one cycle, then restart this test from GEN_IDLE
          chip_sel_hold <= 1'b0;
          state         <= GEN_IDLE;
        end

        GEN_WAIT_VAL: begin
          if (val_done) begin
            chip_sel_hold <= 1'b0;
            tests_count   <= tests_count + 1;
            if (tests_count == TOTAL_TESTS - 1)
              state <= GEN_DONE;
            else
              state <= GEN_IDLE;
          end
        end

        GEN_DONE: begin
          chip_sel_hold <= 1'b0;
          // no further rd_en or wr_en
        end

        default: state <= GEN_IDLE;
      endcase
    end

    // drive chip_sel pin this cycle
    chip_sel <= chip_sel_hold;
  end
end

 
 
  endmodule