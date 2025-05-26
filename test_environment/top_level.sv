module top_level (
    //input wire         MAX10_CLK1_50,
	 input wire         ADC_CLK_10,
	 input wire KEY_0,   // Reset button (active-low)
	 
    output wire [9:0]   LEDR,
	 output wire [8:0]  GPIO_
);


	// Clock generator for internal logic
	//    wire clk_internal;
	//    clock_generator clkgen(
	//        .clk_in  (MAX10_CLK1_50),
	//        .clk_out (clk_internal)
	//    );

    wire clk_internal;
    clock_generator clkgen(
        .clk_in  (ADC_CLK_10),
        .clk_out (clk_internal)
    );

	// Debounced KEY_0
	wire db_key0;
	debounce_button #(.DELAY_MAX(100_000)) debounce_inst (
	.clk       (clk_internal),
	.rst_n     (1'b1),
	.noisy_in  (KEY_0),
	.clean_out (db_key0)
	);

	// Reset and Start logic
	wire reset_n_sys;
	wire start_sig;

	reset_and_start rs (
	.clk             (clk_internal),
	.db_button_in    (db_key0),          // db_key0 = 0 when pressed
	.reset_n_out     (reset_n_sys),
	.start_pulse     (start_sig)
	);


	// On-chip memory signals
	 wire        expected_res;
	 reg [15:0] current_mem_word;


// On-chip memory instance
    on_chip_memory onchip_mem (
        .clk              (clk_internal),
        .reset_n          (reset_n_sys),
        .rd_en            (gen_rd_en),
        .data_out         (current_mem_word),
		  .expected_out     (expected_res),
        .address_in       (gen_address)
    );


	// Control unit that coordinates SDRAM load and signals start of test

    wire ctrl_start_run;

     control_unit ctrl (
    .clk               (clk_internal),
    .reset_n           (reset_n_sys),
    .start             (start_sig),
    .start_run         (ctrl_start_run)
);

	// Test generator to provide inputs to DUT from on-chip memory

	 wire gen_wr_en, gen_chip_sel;
	 reg [6:0] gen_address;

    
	 test_generator #(
		  .ADDR_WIDTH (7),
		  .LOAD_DEPTH (66)
		) gen (
        .clk         (clk_internal),
        .reset       (reset_n_sys),
        .start       (ctrl_start_run),
        .address_BUS (gen_address),
        .rd_en       (gen_rd_en),
        .wr_en       (gen_wr_en),
        .val_done    (val_done),
        .chip_sel    (gen_chip_sel)
    );

    wire        mac_ready;
    wire        mac_single_output;


	// DUT instantiation
    top u_dut (
        .clk_in(clk_internal),
        .bus(current_mem_word),
        .wr_en(gen_wr_en),
        .chip_sel(gen_chip_sel),
        .output_ready(mac_ready),
        .output_bit(mac_single_output),
        .wr_data_ptr(),
        .rd_data_ptr(),
        .ctrl_state(),
		  .rst_mem(rst_mem),
		  .threshold_register(threshold_register)
    );


	// Validator compares DUT output with expected and returns result
    wire         result;

	validator val (
		 .clk           (clk_internal),
		 .reset_n       (reset_n_sys),
		 .dut_single_out(mac_single_output),
		 .output_ready  (mac_ready),
		 .data_to_LED   (result),
		 .val_done      (val_done),
		 .expected_single_out(expected_res)
	);

	
	
	//// LEDR[9] lights when the test passes (result == 1); LEDR[8] lights when the test fails (result == 0)
	// Capture the test result in flip-flops so the LEDs remain lit until the next test
	// led_pass: will light if the test passes (result == 1)
	// led_fail: will light if the test fails (result == 0)

//	reg led_pass, led_fail;
//
//	always_ff @(posedge clk_internal or negedge reset_n_sys) begin
//		 if (!reset_n_sys) begin
//			  // Asynchronous reset: clear both LEDs
//			  led_pass <= 1'b0;
//			  led_fail <= 1'b0;
//		 end else begin
//			  if (start_sig) begin
//					// At the start of a new test, clear previous LED indicators
//					led_pass <= 1'b0;
//					led_fail <= 1'b0;
//			  end else if (val_done) begin
//					// Once validation is done, latch the result into the flip-flops
//					led_pass <= result;
//					led_fail <= ~result;
//			  end
//		 end
//	end
//
//	// Drive the physical LEDs:
//	// LEDR[9] lights when the test passed,
//	// LEDR[8] lights when the test failed.
//	assign LEDR[8] = led_fail;
//	assign LEDR[9] = led_pass;

	
	
	 
	///////////////////////////////////////////////////////
	/////////////////////////DEBUG/////////////////////////
	///////////////////////////////////////////////////////



//	assign GPIO_[0] = current_mem_word[0];
//	assign GPIO_[1] = current_mem_word[1];
//	assign GPIO_[2] = current_mem_word[2];
//	assign GPIO_[3] = gen_address[0];
//	assign GPIO_[4] = gen_address[1];
//	assign GPIO_[5] = gen_address[2];
//
//	assign GPIO_[7] = gen_wr_en;
//	assign GPIO_[8] = clk_internal;
	
	assign GPIO_[0] = mac_single_output;
	assign GPIO_[1] = expected_res;
	assign GPIO_[2] = threshold_register;
	assign GPIO_[3] = gen_chip_sel;
	assign GPIO_[4] = gen_wr_en;
	assign GPIO_[5] = mac_ready;
	assign GPIO_[6] = val_done;
	assign GPIO_[7] = result;
	assign GPIO_[8] = clk_internal;
	



endmodule
