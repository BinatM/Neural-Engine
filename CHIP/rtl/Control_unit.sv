module control_unit (
	input  logic        clk,
	input  logic        chip_sel,         // Chip select signal
	input  logic        wr_en,            // Write enable
	output logic        rst_mem,          // Reset for memory and MAC (one-cycle pulse)
	output logic        mul_mem_en,       // Enable multiplier memory
	output logic        ac_mem_en,        // Enable accumulator memory
	output logic        output_ready,     // Output signal enabled after pipeline delay
	output logic [5:0]  wr_data_ptr,      // Write pointer
	output logic [5:0]  rd_data_ptr,      // Read pointer
	output logic        threshold_ready   // Generated threshold ready signal (asserted for 2 cycles)
);

	typedef enum logic [2:0] {
		IDLE, 
		WRITE_DATA, 
		WRITE_THRESHOLD, 
		COMPUTE, 
		WAIT_OUTPUT, 
		READ_OUTPUT
	} state_t;
	
	state_t state, next_state;
	logic [5:0] wr_ptr, rd_ptr;
	logic [1:0] thresh_counter;      // Counter for threshold_ready (2 cycles)
	logic [1:0] output_delay_counter; // Counter for output_ready delay

	// One-cycle reset pulse
	logic chip_sel_d;
	always_ff @(posedge clk) begin
		chip_sel_d <= chip_sel;
		rst_mem    <= (chip_sel && !chip_sel_d);  // Generate one-cycle pulse on rising edge
	end

	// **Initialize state & pointers**
	initial begin
		state = IDLE;
		wr_ptr = 6'd0;
		rd_ptr = 6'd0;
		thresh_counter = 2'd0;
		output_delay_counter = 2'd0;
	end

	// **FSM State Register & Pointer Updates**
	always_ff @(posedge clk) begin
		if (!chip_sel) begin
			// Reset state, pointers, and control signals when chip_sel goes LOW
			state <= IDLE;
			wr_ptr <= 6'd0;
			rd_ptr <= 6'd0;
			thresh_counter <= 2'd0;
			output_delay_counter <= 2'd0;
			threshold_ready <= 1'b0;
		end else begin
			state <= next_state;
		end

		// **Pipeline-Accurate Pointer Control**
		if (state == WRITE_DATA && wr_en) begin
			if (wr_ptr > 6'd0 && wr_ptr < 6'd64)  // **Skip first read cycle**
				rd_ptr <= rd_ptr + 1;
			wr_ptr <= wr_ptr + 1;
		end else if (state == COMPUTE) begin
			rd_ptr <= rd_ptr + 1;
		end
	end

	// **FSM Logic**
	always_ff @(posedge clk) begin
		next_state = state;
		mul_mem_en = 1'b0;
		ac_mem_en  = 1'b0;
		threshold_ready = 1'b0;

		case (state)
			IDLE: begin
				if (chip_sel && wr_en && !rst_mem)
					next_state = WRITE_DATA;
			end

			WRITE_DATA: begin
				if (wr_ptr == 6'd63)
					next_state = WRITE_THRESHOLD;
				else if (!wr_en)
					next_state = IDLE;
			end

			WRITE_THRESHOLD: begin
				if (wr_en) begin
					threshold_ready = 1'b1;
					thresh_counter <= thresh_counter + 1;
					if (thresh_counter == 2) begin
						threshold_ready <= 1'b0;
						next_state = COMPUTE; // **Move to COMPUTE instead of WAIT_OUTPUT**
					end
				end else begin
					thresh_counter <= 2'd0;
					next_state = IDLE;
				end
			end

			COMPUTE: begin
				mul_mem_en = 1'b1;
				ac_mem_en  = 1'b1;
				if (rd_ptr == 6'd63)
					next_state = WAIT_OUTPUT;
			end

			WAIT_OUTPUT: begin
				output_delay_counter <= output_delay_counter + 1;
				if (output_delay_counter == 2)
					next_state = READ_OUTPUT;
			end

			READ_OUTPUT: begin
				if (!chip_sel)
					next_state = IDLE;
			end
		endcase
	end

	// **Output Ready Logic**
	always_ff @(posedge clk) begin
		if (state == COMPUTE) begin
			output_delay_counter <= 2'd0;
			output_ready         <= 1'b0;
		end else if (state == WAIT_OUTPUT) begin
			output_ready <= 1'b0;
		end else if (state == READ_OUTPUT && output_delay_counter == 2'd2) begin
			output_ready <= 1'b1;
		end else if (!chip_sel) begin
			output_ready <= 1'b0;
		end
	end

	// **Assign Output Pointers**
	assign wr_data_ptr = wr_ptr;
	assign rd_data_ptr = rd_ptr;

endmodule
