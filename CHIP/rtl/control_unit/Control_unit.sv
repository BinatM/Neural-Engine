module control_unit (
	input  logic        clk,
	input  logic        rst,
	input  logic        chip_sel,
	input  logic        wr_en,
	input  logic        threshold_ready,
	output logic        rst_mem,
	output logic        mul_mem_en,
	output logic        ac_mem_en,
	output logic [5:0]  wr_data_ptr,
	output logic [5:0]  rd_data_ptr
);

	typedef enum logic [2:0] {
		IDLE, WRITE_DATA, WRITE_THRESHOLD, COMPUTE, READ_OUTPUT
	} state_t;
	
	state_t state, next_state;
	logic [5:0] wr_ptr, rd_ptr;
	logic computation_done;
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= IDLE;
			wr_ptr <= 6'd0;
			rd_ptr <= 6'd0;
			computation_done <= 1'b0;
		end else begin
			state <= next_state;
			if (state == WRITE_DATA) wr_ptr <= wr_ptr + 1;
			if (state == COMPUTE) rd_ptr <= rd_ptr + 1;
		end
	end

	always_comb begin
		next_state = state;
		rst_mem = 1'b0;
		mul_mem_en = 1'b0;
		ac_mem_en = 1'b0;

		case (state)
			IDLE: 
				if (chip_sel && wr_en) next_state = WRITE_DATA;
				
			WRITE_DATA: 
				if (wr_ptr == 6'd63) next_state = WRITE_THRESHOLD;
				
			WRITE_THRESHOLD:
				if (threshold_ready) next_state = COMPUTE;
				
			COMPUTE:
				if (rd_ptr == 6'd63) begin
					computation_done = 1'b1;
					next_state = READ_OUTPUT;
				end else begin
					mul_mem_en = 1'b1;
					ac_mem_en = 1'b1;
				end
				
			READ_OUTPUT:
				if (!chip_sel) next_state = IDLE;
		endcase
	end

	assign wr_data_ptr = wr_ptr;
	assign rd_data_ptr = rd_ptr;

endmodule
