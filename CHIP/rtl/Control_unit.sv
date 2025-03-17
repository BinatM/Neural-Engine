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

	//-------------------------------------------------------------------------
	// STATE MACHINE DEFINITIONS
	//-------------------------------------------------------------------------
	typedef enum logic [2:0] {
		IDLE, 
		WRITE_DATA, 
		WRITE_THRESHOLD, 
		COMPUTE, 
		WAIT_OUTPUT, 
		READ_OUTPUT
	} state_t;
	
	state_t state, next_state;

	//-------------------------------------------------------------------------
	// INTERNAL SIGNALS
	//-------------------------------------------------------------------------
	logic [5:0] wr_ptr, rd_ptr;
	logic [1:0] thresh_counter;      // Counter for threshold_ready (2 cycles)
	logic [1:0] output_delay_counter; // Counter for output_ready delay

	// For generating a one-cycle reset pulse:
	logic chip_sel_d;
	always_ff @(posedge clk) begin
		chip_sel_d <= chip_sel;
		if (chip_sel && !chip_sel_d)
			rst_mem <= 1'b1;  // Generate one-cycle pulse on rising edge
		else
			rst_mem <= 1'b0;
	end

	//-------------------------------------------------------------------------
	// INITIALIZATION: Force known startup values (state = IDLE, pointers = 0)
	//-------------------------------------------------------------------------
	initial begin
		state = IDLE;
		wr_ptr = 6'd0;
		rd_ptr = 6'd0;
		thresh_counter = 2'd0;
		output_delay_counter = 2'd0;
	end

	//-------------------------------------------------------------------------
	// STATE REGISTER: Transition logic and pointer updates
	//-------------------------------------------------------------------------
	always_ff @(posedge clk) begin
		// Force state to IDLE if chip_sel goes low
		if (!chip_sel)
			state <= IDLE;
		else
			state <= next_state;

		// Increment write pointer during WRITE_DATA when wr_en is high
		if (state == WRITE_DATA && wr_en)
			wr_ptr <= wr_ptr + 1;

		// Increment read pointer during COMPUTE state
		if (state == COMPUTE)
			rd_ptr <= rd_ptr + 1;
	end

	//-------------------------------------------------------------------------
	// FSM NEXT STATE AND CONTROL SIGNAL LOGIC
	//-------------------------------------------------------------------------
	always_ff @(posedge clk) begin
		next_state = state;
		// Default control signal assignments
		mul_mem_en = 1'b0;
		ac_mem_en  = 1'b0;
		// Default threshold_ready is 0
		threshold_ready = 1'b0;

		case (state)
			IDLE: begin
				// Wait until wr_en goes high while chip_sel is active
				if (chip_sel && wr_en)
					next_state = WRITE_DATA;
			end

			WRITE_DATA: begin
				// After 64 cycles of data+weight writing, move to threshold write
				if (wr_ptr == 6'd63)
					next_state = WRITE_THRESHOLD;
				else if (!wr_en)
					next_state = IDLE;  // If wr_en goes low, wait in IDLE
			end

			WRITE_THRESHOLD: begin
				// When wr_en remains high, assert threshold_ready for 2 cycles
				if (wr_en) begin
					threshold_ready = 1'b1;
					thresh_counter = thresh_counter + 1;
					if (thresh_counter == 2)
						next_state = COMPUTE;
				end
				else begin
					// If wr_en drops, abort threshold write and return to IDLE
					thresh_counter = 2'd0;
					next_state = IDLE;
				end
			end

			COMPUTE: begin
				// During computation, enable MAC signals
				mul_mem_en = 1'b1;
				ac_mem_en  = 1'b1;
				if (rd_ptr == 6'd63)
					next_state = WAIT_OUTPUT;
			end

			WAIT_OUTPUT: begin
				// Wait a couple of cycles for pipeline settling
				output_delay_counter = output_delay_counter + 1;
				if (output_delay_counter == 2)
					next_state = READ_OUTPUT;
			end

			READ_OUTPUT: begin
				// Remain in READ_OUTPUT until chip_sel goes low
				if (!chip_sel)
					next_state = IDLE;
			end
		endcase
	end

	//-------------------------------------------------------------------------
	// OUTPUT READY SIGNAL LOGIC
	//-------------------------------------------------------------------------
	always_ff @(posedge clk) begin
		if (state == COMPUTE) begin
			output_delay_counter <= 2'd0;
			output_ready         <= 1'b0;
		end
		else if (state == WAIT_OUTPUT) begin
			// output_delay_counter is incremented in the FSM block above
			// When the delay is satisfied, output_ready will be enabled in READ_OUTPUT.
			output_ready <= 1'b0;
		end
		else if (state == READ_OUTPUT && output_delay_counter == 2'd2) begin
			output_ready <= 1'b1;
		end
		else if (!chip_sel) begin
			output_ready <= 1'b0;
		end
	end

	//-------------------------------------------------------------------------
	// ASSIGN OUTPUT POINTERS
	//-------------------------------------------------------------------------
	assign wr_data_ptr = wr_ptr;
	assign rd_data_ptr = rd_ptr;

endmodule
