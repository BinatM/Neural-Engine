module control_unit (
	input  logic        clk,
	input  logic        chip_sel,         // Chip select signal
	input  logic        wr_en,            // Write enable
	input  logic        threshold_ready,  // Indicates threshold value is ready
	output logic        rst_mem,          // Reset for memory and MAC
	output logic        mul_mem_en,       // Enable multiplier memory
	output logic        ac_mem_en,        // Enable accumulator memory
	output logic        output_ready,     // Output signal enabled after pipeline delay
	output logic [5:0]  wr_data_ptr,      // Write pointer
	output logic [5:0]  rd_data_ptr       // Read pointer
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
	logic       rst_mem_reg;          // One-cycle delayed reset
	logic [1:0] output_delay_counter; // Counter for output_ready delay

	//-------------------------------------------------------------------------
	// STATE REGISTERS + POINTER LOGIC
	//-------------------------------------------------------------------------
	always_ff @(posedge clk) begin
		state <= next_state;

		case (state)
			// Increment write pointer during WRITE_DATA
			WRITE_DATA: 
				wr_ptr <= (wr_ptr == 6'd63) ? wr_ptr : wr_ptr + 1;

			// Increment read pointer during COMPUTE
			COMPUTE:
				rd_ptr <= (rd_ptr == 6'd63) ? rd_ptr : rd_ptr + 1;

			// Reset pointers on IDLE entry
			IDLE: begin
				wr_ptr <= 6'd0;
				rd_ptr <= 6'd0;
			end
		endcase
	end

	//-------------------------------------------------------------------------
	// GENERATE RST_MEM (ONE-CYCLE DELAY AFTER CHIP_SEL GOES HIGH)
	//-------------------------------------------------------------------------
	always_ff @(posedge clk) begin
		rst_mem_reg <= chip_sel;
		rst_mem     <= rst_mem_reg;
	end

	//-------------------------------------------------------------------------
	// NEXT STATE + CONTROL SIGNAL LOGIC
	//-------------------------------------------------------------------------
	always_comb begin
		next_state   = state;
		mul_mem_en   = 1'b0;
		ac_mem_en    = 1'b0;

		case (state)
			// ---------------------------------------------------
			IDLE: begin
				// If chip_sel is asserted and wr_en is high,
				// start writing data to memory.
				if (chip_sel && wr_en) 
					next_state = WRITE_DATA;
			end

			// ---------------------------------------------------
			WRITE_DATA: begin
				// Once we've written all 64 pairs, move on
				// to threshold writing.
				if (wr_ptr == 6'd63)
					next_state = WRITE_THRESHOLD;
			end

			// ---------------------------------------------------
			WRITE_THRESHOLD: begin
				// When threshold is ready, transition to compute.
				if (threshold_ready)
					next_state = COMPUTE;
			end

			// ---------------------------------------------------
			COMPUTE: begin
				// Read + MAC accumulate for 64 cycles
				// (rd_ptr goes from 0 to 63).
				mul_mem_en = 1'b1;
				ac_mem_en  = 1'b1;
				// If we've read/processed all 64, move to WAIT_OUTPUT.
				if (rd_ptr == 6'd63)
					next_state = WAIT_OUTPUT;
			end

			// ---------------------------------------------------
			WAIT_OUTPUT: begin
				// A short delay for final pipeline stages
				// or activation function.
				// After a couple cycles, go to READ_OUTPUT.
			end

			// ---------------------------------------------------
			READ_OUTPUT: begin
				// Once user drops chip_sel, go back to IDLE.
				// Typically, output_ready is asserted here.
			end
		endcase
	end

	//-------------------------------------------------------------------------
	// OUTPUT READY + DELAY COUNTER
	//-------------------------------------------------------------------------
	always_ff @(posedge clk) begin
		if (state == COMPUTE) begin
			// Reset the delay counter when we enter WAIT_OUTPUT next
			output_delay_counter <= 2'b00;
			output_ready         <= 1'b0;
		end
		else if (state == WAIT_OUTPUT) begin
			// Increment the counter
			output_delay_counter <= output_delay_counter + 1;
			// Once we've waited 2 cycles, transition to READ_OUTPUT
			if (output_delay_counter == 2'b10) begin
				output_ready <= 1'b1;
				next_state   <= READ_OUTPUT;
			end
		end
		else if (state == READ_OUTPUT) begin
			// Keep output_ready high until chip_sel goes low
			if (!chip_sel) begin
				output_ready <= 1'b0;
			end
		end
	end

	//-------------------------------------------------------------------------
	// RETURN TO IDLE
	//-------------------------------------------------------------------------
	always_ff @(posedge clk) begin
		if (state == READ_OUTPUT && !chip_sel) begin
			next_state <= IDLE;
		end
	end

	//-------------------------------------------------------------------------
	// ASSIGN OUTPUT POINTERS
	//-------------------------------------------------------------------------
	assign wr_data_ptr = wr_ptr;
	assign rd_data_ptr = rd_ptr;

endmodule
