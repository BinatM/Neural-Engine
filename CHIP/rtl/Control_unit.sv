`timescale 1ns/1ps

module Control_unit (
  input  logic        clk,
  input  logic        chip_sel,         // Chip select signal
  input  logic        wr_en,            // Write enable
  output logic        rst_mem,          // Reset for memory/MAC (one?cycle pulse)
  output logic        mul_mem_en,       // Enable multiplier stage
  output logic        ac_mem_en,        // Enable accumulator stage
  output logic        output_ready,     // Output valid
  output logic [5:0]  wr_data_ptr,      // Write pointer (0?63)
  output logic [5:0]  rd_data_ptr,      // Read pointer  (0?63)
  output logic        threshold_ready   // Asserted during threshold cycles
);

  typedef enum logic [2:0] {
	IDLE, WRITE_DATA, WRITE_THRESHOLD, COMPUTE, WAIT_OUTPUT, READ_OUTPUT
  } state_t;

  state_t         state, next_state;
  logic [5:0]     wr_ptr, rd_ptr;
  logic [1:0]     thresh_cnt;
  logic [1:0]     out_delay_cnt;

  // Generate a one?cycle pulse when chip_sel goes 0?1
  logic chip_sel_d1, chip_sel_d2;
  always_ff @(posedge clk) begin
	// Stage the raw input
	chip_sel_d1 <= chip_sel;
	// Delay it one more cycle
	chip_sel_d2 <= chip_sel_d1;
	// Now rst_mem = ?chip_sel was high one cycle ago, but wasn't high two cycles ago?
	rst_mem     <= chip_sel_d1 && !chip_sel_d2;
  end


  // Next?state logic
  always_comb begin
	next_state = state;
	case (state)
	  IDLE:            if (chip_sel && wr_en && !rst_mem) next_state = WRITE_DATA;
	  WRITE_DATA:      if (!wr_en)         next_state = IDLE;
					   else if (wr_ptr==6'd63) next_state = WRITE_THRESHOLD;
	  WRITE_THRESHOLD: if (!wr_en)         next_state = COMPUTE;
	  COMPUTE:         if (rd_ptr == 6'd63) next_state = WAIT_OUTPUT;
	  WAIT_OUTPUT:     if (out_delay_cnt==2) next_state = READ_OUTPUT;
	  READ_OUTPUT:     if (!chip_sel)      next_state = IDLE;
	  default:         next_state = IDLE;
	endcase
  end

  // State, pointers, and control signals
  always_ff @(posedge clk) begin
	if (!chip_sel) begin
	  // full reset
	  state            <= IDLE;
	  wr_ptr           <= 6'd0;
	  rd_ptr           <= 6'd0;
	  thresh_cnt       <= 2'd0;
	  out_delay_cnt    <= 2'd0;
	  mul_mem_en       <= 1'b0;
	  ac_mem_en        <= 1'b0;
	  threshold_ready  <= 1'b0;
	  output_ready     <= 1'b0;
	end else begin
	  state <= next_state;

	  // WRITE_DATA: advance write pointer each cycle wr_en=1
	  if (state==WRITE_DATA && wr_en) begin
		wr_ptr <= wr_ptr + 6'd1;
		// start reading from the very first multiply result
		if (wr_ptr != 6'd0) rd_ptr <= rd_ptr + 6'd1;
	  end

	  // WRITE_THRESHOLD: count two cycles, assert threshold_ready
	  if (state==WRITE_THRESHOLD && wr_en) begin
		thresh_cnt      <= thresh_cnt + 2'd1;
		threshold_ready <= 1'b1;
	  end

	  // COMPUTE: enable MAC stages
	  mul_mem_en <= (state==COMPUTE);
	  ac_mem_en  <= (state==COMPUTE);

	  // COMPUTE: keep advancing rd_ptr each cycle
	  if (state==COMPUTE) rd_ptr <= rd_ptr + 6'd1;

	  // WAIT_OUTPUT: simple two?cycle delay
	  if (state==WAIT_OUTPUT) out_delay_cnt <= out_delay_cnt + 2'd1;
	  else                    out_delay_cnt <= 2'd0;

	  // READ_OUTPUT: assert output_ready
	  output_ready <= (state==READ_OUTPUT && out_delay_cnt==2);
	end
  end

  // Expose pointers
  assign wr_data_ptr = wr_ptr;
  assign rd_data_ptr = rd_ptr;

endmodule
