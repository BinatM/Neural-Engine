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
	logic [1:0] thresh_counter;       // Counter for threshold_ready (2 cycles)
	logic [1:0] output_delay_counter; // Counter for output_ready delay

	//-------------------------------------------------------------------------
	// CHIP SEL EDGE DETECTOR FOR RESET PULSE
	//-------------------------------------------------------------------------
	logic chip_sel_d;
	always_ff @(posedge clk) begin
		chip_sel_d <= chip_sel;
		// Generate one-cycle pulse on rising edge of chip_sel.
		rst_mem <= (chip_sel && !chip_sel_d);
	end

	//-------------------------------------------------------------------------
	// NEXT STATE COMBINATIONAL LOGIC
	//-------------------------------------------------------------------------
	always_comb begin
		// Default assignments
		next_state = state;
		case (state)
			IDLE: begin
				// In IDLE, wait for wr_en (with chip_sel high and rst_mem low) to begin writing.
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
					// Remain in WRITE_THRESHOLD until 2 threshold cycles occur.
					if (thresh_counter == 2)
						next_state = COMPUTE;
					else
						next_state = WRITE_THRESHOLD;
				end else begin
					next_state = IDLE;
				end
			end

			COMPUTE: begin
				if (rd_ptr == 6'd63)
					next_state = WAIT_OUTPUT;
				else
					next_state = COMPUTE;
			end

			WAIT_OUTPUT: begin
				if (output_delay_counter == 2)
					next_state = READ_OUTPUT;
				else
					next_state = WAIT_OUTPUT;
			end

			READ_OUTPUT: begin
				if (!chip_sel)
					next_state = IDLE;
				else
					next_state = READ_OUTPUT;
			end

			default: next_state = IDLE;
		endcase
	end

	//-------------------------------------------------------------------------
	// SEQUENTIAL LOGIC: Update State, Pointers, Counters, and Control Signals
	// All signals updated here are assigned in this block only.
	//-------------------------------------------------------------------------
	always_ff @(posedge clk) begin
		if (!chip_sel) begin
			// When chip_sel is low, reset everything to known values.
			state <= IDLE;
			wr_ptr <= 6'd0;
			rd_ptr <= 6'd0;
			thresh_counter <= 2'd0;
			output_delay_counter <= 2'd0;
			threshold_ready <= 1'b0;
			mul_mem_en <= 1'b0;
			ac_mem_en <= 1'b0;
			output_ready <= 1'b0;
		end else begin
			// Update state
			state <= next_state;

			// Pointer Updates (pipeline behavior):
			// During WRITE_DATA:
			if (state == WRITE_DATA && wr_en) begin
				// On first write cycle, only wr_ptr increments (no read)
				if (wr_ptr != 6'd0 && wr_ptr < 6'd63)
					rd_ptr <= rd_ptr + 1;
				wr_ptr <= wr_ptr + 1;
			end
			// During COMPUTE, increment rd_ptr
			else if (state == COMPUTE) begin
				rd_ptr <= rd_ptr + 1;
			end

			// In WRITE_THRESHOLD, if wr_en is high, update threshold counter and assert threshold_ready.
			if (state == WRITE_THRESHOLD && wr_en) begin
				thresh_counter <= thresh_counter + 1;
				threshold_ready <= 1'b1;
			end else if (state == WRITE_THRESHOLD && !wr_en) begin
				thresh_counter <= 2'd0;
				threshold_ready <= 1'b0;
			end else if (state != WRITE_THRESHOLD) begin
				// Ensure threshold_ready is deasserted outside WRITE_THRESHOLD.
				threshold_ready <= 1'b0;
			end

			// In WAIT_OUTPUT, update the output delay counter.
			if (state == WAIT_OUTPUT) begin
				output_delay_counter <= output_delay_counter + 1;
			end else if (state != WAIT_OUTPUT) begin
				output_delay_counter <= 2'd0;
			end

			// Control signals during COMPUTE: enable MAC operations.
			if (state == COMPUTE) begin
				mul_mem_en <= 1'b1;
				ac_mem_en  <= 1'b1;
			end else begin
				mul_mem_en <= 1'b0;
				ac_mem_en  <= 1'b0;
			end

			// In READ_OUTPUT, assert output_ready when delay counter is satisfied.
			if (state == READ_OUTPUT && output_delay_counter == 2)
				output_ready <= 1'b1;
			else if (state != READ_OUTPUT)
				output_ready <= 1'b0;
		end
	end

	//-------------------------------------------------------------------------
	// ASSIGN OUTPUT POINTERS
	//-------------------------------------------------------------------------
	assign wr_data_ptr = wr_ptr;
	assign rd_data_ptr = rd_ptr;

endmodule
