`timescale 1ns/1ps

module Control_unit (
  input  logic        clk,
  input  logic        chip_sel,        // active-high
  input  logic        wr_en,           // user write enable
  input  logic        rd_en,           // user read enable
  output logic        rst_mem,         // one-cycle reset pulse
  output logic        mul_mem_en,      // pipeline stage1 enable
  output logic        ac_mem_en,       // pipeline stage2 enable
  output logic        output_ready,    // final bit valid
  output logic [5:0]  wr_data_ptr,     // write addr 0-63
  output logic [5:0]  rd_data_ptr,     // read  addr 0-63
  output logic        threshold_ready, // pulse for 2 cycles
  output logic [2:0]  ctrl_state       // DEBUG: FSM state for coverage
);

  // FSM states
  typedef enum logic [2:0] {
	IDLE,
	WRITE_DATA,
	WRITE_THRESHOLD,
	COMPUTE,
	WAIT_OUTPUT,
	READ_OUTPUT
  } state_t;

  state_t      state, next_state;
  logic [5:0]  wr_ptr, rd_ptr;
  logic [1:0]  thresh_cnt, out_cnt;
  logic        chip_sel_d;

  // rst_mem: one-cycle pulse when chip_sel rises
  always_ff @(posedge clk) begin
	chip_sel_d <= chip_sel;
	rst_mem    <= (chip_sel && !chip_sel_d);
  end

  // Next?state logic
  always_comb begin
	next_state = state;
	case (state)
	  IDLE:
		if (chip_sel && wr_en)
		  next_state = WRITE_DATA;

	  WRITE_DATA:
		if (wr_ptr == 6'd63)
		  next_state = WRITE_THRESHOLD;

	  WRITE_THRESHOLD:
		if (thresh_cnt == 2)
		  next_state = COMPUTE;

	  COMPUTE:
		if (rd_ptr == 6'd63)
		  next_state = WAIT_OUTPUT;

	  WAIT_OUTPUT:
		if (out_cnt == 2'd1)
		  next_state = READ_OUTPUT;

	  READ_OUTPUT:
		if (!rd_en)  // user must drop rd_en after reading both halves
		  next_state = IDLE;

	  default:
		next_state = IDLE;
	endcase
  end

  // Sequential logic
  always_ff @(posedge clk) begin
	if (!chip_sel) begin
	  // full reset
	  state           <= IDLE;
	  wr_ptr          <= 6'd0;
	  rd_ptr          <= 6'd0;
	  thresh_cnt      <= 2'd0;
	  out_cnt         <= 2'd0;
	  mul_mem_en      <= 1'b0;
	  ac_mem_en       <= 1'b0;
	  threshold_ready <= 1'b0;
	  output_ready    <= 1'b0;
	  ctrl_state      <= IDLE;
	end else begin
	  state      <= next_state;
	  ctrl_state <= next_state;   // expose for coverage

	  // defaults
	  mul_mem_en      <= 1'b0;
	  ac_mem_en       <= 1'b0;
	  threshold_ready <= 1'b0;
	  output_ready    <= 1'b0;

	  case (state)
		WRITE_DATA: begin
		  // 64 cycles of pixel+weight
		  if (wr_en) begin
			wr_ptr <= wr_ptr + 1;
			// pipeline starts on 2nd word
			if (wr_ptr != 6'd0) begin
			  rd_ptr     <= rd_ptr + 1;
			  mul_mem_en <= 1'b1;
			  ac_mem_en  <= 1'b1;
			end
		  end
		end

		WRITE_THRESHOLD: begin
		  // latch first half, then second; must see wr_en high twice
		  if (wr_en && (thresh_cnt < 2)) begin
			thresh_cnt      <= thresh_cnt + 1;
			threshold_ready <= 1'b1;
		  end
		end

		COMPUTE: begin
		  // finish pipeline: 64 multiplies+63 adds -> 65 clocks
		  rd_ptr     <= rd_ptr + 1;
		  mul_mem_en <= 1'b1;
		  ac_mem_en  <= 1'b1;
		end

		WAIT_OUTPUT: begin
		  // one?cycle delay before output_ready
		  out_cnt <= out_cnt + 1;
		end

		READ_OUTPUT: begin
		  // pulse the "final bit valid" flag
		  output_ready <= 1'b1;
		end

	  endcase
	end
  end

  // expose pointers
  assign wr_data_ptr = wr_ptr;
  assign rd_data_ptr = rd_ptr;

endmodule : Control_unit
