module top_level (
    //input wire         MAX10_CLK1_50,
	 input wire         ADC_CLK_10,
	 input wire KEY_0,   // Reset button (active-low)
	 input wire KEY_1,
	 
    output wire [9:0]   LEDR,
	 output wire [8:0]  GPIO_,
	 
	// seven-segment display ports (6 digits: 0-5)
    output wire [6:0]   HEX0,          // first failure, ones
    output wire [6:0]   HEX1,          // first failure, tens
    output wire [6:0]   HEX2,          // first failure, hundreds
    output wire [6:0]   HEX3,          // second failure, ones
    output wire [6:0]   HEX4,          // second failure, tens
    output wire [6:0]   HEX5           // second failure, hundreds
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
	wire db_key0, db_key1;
	
		debounce_button #(.DELAY_MAX(100_000)) debounce_inst (
	.clk       (clk_internal),
	.rst_n     (1'b1),
	.noisy_in  (KEY_0),
	.clean_out (db_key0)
	);
	
		debounce_button #(.DELAY_MAX(100_000)) debounce_inst2 (
	.clk       (clk_internal),
	.rst_n     (1'b1),
	.noisy_in  (KEY_1),
	.clean_out (db_key1)
	);
	

	// Reset and Start logic
	wire reset_n_sys, start_sig;

	reset_and_start rs (
	.clk             (clk_internal),
	.db_button_in    (db_key0),          // db_key0 = 0 when pressed
	.reset_n_out     (reset_n_sys),
	.start_pulse     (start_sig)
	);

	wire stop_reset;
	
	reset_stop_signal resetstop (
	.clk             (clk_internal),
	.db_button_in    (db_key1),          // db_key0 = 0 when pressed
	.stop_reset      (stop_reset)
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
        .address_in       (gen_address),
		  .test_count       (test_count)
    );


	// Control unit that coordinates SDRAM load and signals start of test

    wire ctrl_start_run;

     control_unit ctrl (
    .clk               (clk_internal),
    .reset_n           (reset_n_sys),
    .start             (start_sig),
    .start_run         (ctrl_start_run),
	 .val_done          (val_done),
	 .stop_tests        (stop_tests)
);

	// Test generator to provide inputs to DUT from on-chip memory

	 wire gen_wr_en, gen_chip_sel;
	 reg [15:0] gen_address;
	 reg [8:0] test_count;
    
	 test_generator #(
		  .ADDR_WIDTH (16),
		  .LOAD_DEPTH (66)
		) gen (
        .clk         (clk_internal),
        .reset       (reset_n_sys),
        .start       (ctrl_start_run),
        .address_BUS (gen_address),
        .rd_en       (gen_rd_en),
        .wr_en       (gen_wr_en),
        .val_done    (val_done),
        .chip_sel    (gen_chip_sel),
		  .tests_count (test_count)
    );

    wire        mac_ready, mac_single_output;

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
		 .result_out    (result),
		 .val_done      (val_done),
		 .expected_single_out(expected_res),
		 .chip_sel       (chip_sel)
	);
	
	
	
	// instantiate failure-counter & 7-seg driver
    wire stop_tests;
	 
    seven_seg_failures fail_disp (
        .clk        (clk_internal),
        .reset_n    (reset_n_sys),
        .val_done   (val_done),
        .result     (result),
        .test_count (test_count),
		  .stop_reset (stop_reset),
		  .stop_tests (stop_tests),
        .seg1_0     (HEX0),
        .seg1_1     (HEX1),
        .seg1_2     (HEX2),
        .seg2_0     (HEX3),
        .seg2_1     (HEX4),
        .seg2_2     (HEX5)
		); 

	 
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
	assign GPIO_[2] = gen_chip_sel;
	assign GPIO_[3] = gen_wr_en;
   assign GPIO_[4] = clk_internal;
	assign GPIO_[5] = mac_ready;
	assign GPIO_[6] = val_done;
	assign GPIO_[7] = result;
	assign GPIO_[8] = clk_internal;
	
//	assign GPIO_[4] = test_count[0];
//	assign GPIO_[5] = test_count[1];
//	assign GPIO_[6] = test_count[2];
//	



endmodule
