`timescale 1ns/1ps

module Control_unit (
	input  logic        clk,
	input  logic        chip_sel,
	input  logic        wr_en,
	output logic        rst_mem,
	output logic        mul_mem_en,
	output logic        ac_mem_en,
	output logic        output_ready,
	output logic [5:0]  wr_data_ptr,
	output logic [5:0]  rd_data_ptr,
	output wire        threshold_ready,
	output logic [2:0]  ctrl_state
  );


  // FSM states
  typedef enum logic [2:0] {
	IDLE,
	WRITE_DATA,
	WRITE_THRESHOLD,
	WAIT_AND_READ_OUTPUT
  } state_t;

  state_t      state, next_state;
  logic [5:0]  wr_ptr, rd_ptr;
  //logic [1:0]  calc_finish_timer;
  logic [1:0]  thresh_cnt;
  logic        chip_sel_d;
  // in your FSM Comb block:
  assign threshold_ready = (state == WRITE_THRESHOLD) && wr_en && (thresh_cnt < 2);

  // rst_mem: one-cycle pulse when chip_sel rises //checking if we finished reading all data
  always_ff @(posedge clk) begin
	chip_sel_d <= chip_sel;
	rst_mem    <= (chip_sel && !chip_sel_d);
  end

  // Next?state logic
  always_comb begin
	next_state = state;
	case (state)
	  IDLE:
		if ((chip_sel && wr_en) || rst_mem)
		  next_state = WRITE_DATA;

	  WRITE_DATA:
		if (wr_ptr == 6'd63 && wr_en) 
		  next_state = WRITE_THRESHOLD;

	  WRITE_THRESHOLD:
		if (thresh_cnt == 1)
		  next_state = WAIT_AND_READ_OUTPUT;


	  WAIT_AND_READ_OUTPUT:		  
		  next_state = WAIT_AND_READ_OUTPUT;

	  default:
		next_state = IDLE;
	endcase
  end

  // Sequential logic
  always_ff @(posedge clk) begin
	if (!chip_sel) begin
	  // full reset
	  state         	  <= IDLE;
	  wr_ptr        	  <= 6'd0;
	  rd_ptr        	  <= 6'd0;
	  thresh_cnt    	  <= 2'd0;
	  mul_mem_en    	  <= 1'b0;
	  ac_mem_en      	  <= 1'b0;
	  output_ready  	  <= 1'b0;
	  ctrl_state      	  <= IDLE;
	end else begin
	  state      <= next_state;
	  ctrl_state <= next_state;   // expose for coverage
	  if (wr_en) begin 
	  	if (((rd_ptr == 6'd0) && (wr_ptr == 6'd1)) || (rd_ptr > 6'd0 && rd_ptr < 6'd63)) begin 
			mul_mem_en      <= 1'b1;
		end else if (rd_ptr == 6'd63) begin
			mul_mem_en <= 1'b1;
			rd_ptr     <= rd_ptr + 1;
		end else begin
			mul_mem_en      <= 1'b0;
		end
	  end else begin 
		  mul_mem_en      <= 1'b0;
	  end
	  ac_mem_en       <= mul_mem_en;
	  output_ready    <= 1'b0;

	  case (state)
		WRITE_DATA: begin
		  // 64 cycles of pixel+weight
		  if (wr_en) begin
			wr_ptr <= wr_ptr + 1;
			if (wr_ptr != 6'd0) begin
			  rd_ptr <= rd_ptr + 1;
			end
		  end
		end

		WRITE_THRESHOLD: begin
		  // latch first half, then second; must see wr_en high twice
		  if (wr_en && (thresh_cnt < 1)) begin
			thresh_cnt      <= thresh_cnt + 1;
		  end
		end

		WAIT_AND_READ_OUTPUT: begin
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