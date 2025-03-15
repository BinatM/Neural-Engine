module control_unit (
	input  logic        clk,
	input  logic        chip_sel,           // Chip select signal
	input  logic        wr_en,              // Write enable
	input  logic        threshold_ready,    // Indicates threshold value is ready
	output logic        rst_mem,            // Reset for memory and MAC
	output logic        mul_mem_en,         // Enable multiplier memory
	output logic        ac_mem_en,          // Enable accumulator memory
	output logic        output_ready,       // Output signal enabled after 2 cycles
	output logic [5:0]  wr_data_ptr,        // Write pointer
	output logic [5:0]  rd_data_ptr         // Read pointer
);

	typedef enum logic [2:0] {
		IDLE, WRITE_DATA, WRITE_THRESHOLD, COMPUTE, WAIT_OUTPUT, READ_OUTPUT
	} state_t;
	
	state_t state, next_state;
	logic [5:0] wr_ptr, rd_ptr;
	logic rst_mem_reg;
	logic [1:0] output_delay_counter;  // Counter for output_ready delay

	// FSM state transitions
	always_ff @(posedge clk) begin
		state <= next_state;

		if (state == WRITE_DATA) wr_ptr <= wr_ptr + 1;
		if (state == COMPUTE) rd_ptr <= rd_ptr + 1;
	end

	// Generate rst_mem (delayed one cycle after chip_sel goes high)
	always_ff @(posedge clk) begin
		rst_mem_reg <= chip_sel;
		rst_mem <= rst_mem_reg;
	end

	// FSM logic
	always_comb begin
		next_state = state;
		mul_mem_en = 1'b0;
		ac_mem_en = 1'b0;

		case (state)
			IDLE: 
				if (chip_sel && wr_en) 
					next_state = WRITE_DATA;
				
			WRITE_DATA: 
				if (wr_ptr == 6'd63) 
					next_state = WRITE_THRESHOLD;
				
			WRITE_THRESHOLD:
				if (threshold_ready) 
					next_state = COMPUTE;
				
			COMPUTE:
				if (rd_ptr == 6'd63) 
					next_state = WAIT_OUTPUT;
				else begin
					mul_mem_en = 1'b1;
					ac_mem_en = 1'b1;
				end
			
			WAIT_OUTPUT:
				if (output_delay_counter == 2) 
					next_state = READ_OUTPUT;

			READ_OUTPUT:
				if (!chip_sel) 
					next_state = IDLE;
		endcase
	end

	// Output ready signal is enabled 2 cycles after COMPUTE state ends
	always_ff @(posedge clk) begin
		if (state == COMPUTE) begin
			output_delay_counter <= 2'b00;  // Reset delay counter
			output_ready <= 1'b0;
		end 
		else if (state == WAIT_OUTPUT) begin
			output_delay_counter <= output_delay_counter + 1;
		end 
		else if (state == READ_OUTPUT && output_delay_counter == 2'b10) begin
			output_ready <= 1'b1;  // Enable output after 2 cycles
		end 
		else if (!chip_sel) begin
			output_ready <= 1'b0;  // Reset output when chip_sel goes low
		end
	end

	// Assign output pointers
	assign wr_data_ptr = wr_ptr;
	assign rd_data_ptr = rd_ptr;

endmodule
