module top_level (
    input wire         MAX10_CLK1_50,
	 input wire         ADC_CLK_10,
	 input wire KEY_0,   // Reset button (active-low)

    // SDRAM physical pins
    output wire [12:0]  DRAM_ADDR,
    output wire [1:0]   DRAM_BA,
    output wire         DRAM_CAS_N,
    output wire         DRAM_CKE,
    output wire         DRAM_CLK,
    output wire         DRAM_CS_N,
    inout  wire [15:0]  DRAM_DQ,
    output wire         DRAM_LDQM,
    output wire         DRAM_RAS_N,
    output wire         DRAM_UDQM,
    output wire         DRAM_WE_N,
    output wire [9:0]   LEDR,
	 output wire [35:0]  GPIO_
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

// SDRAM interface signals
    wire [15:0] sdram_data_out;
    wire [15:0] sdram_data_write;
    wire [23:0] sdram_address;
    wire        sdram_rd_en;
	 wire        sdram_wr_en;
    wire        sdram_ready;
	 wire [15:0] mem_data_out;
	 wire sdram_initialized;
	 
	 
	 // debug wires for SDRAM interface

wire [3:0]  sdram_state_wire;    // internal SDRAM state
wire sdram_ack;

	 

// Instantiate SDRAM controller
       SDRAM_CONTROLLER #(
        .G_CLK_FREQ           (50.0),
        .G_CAS_LATENCY        (2),
        .G_WRITE_BURST_MODE   ('1),
        .G_BURST_LENGTH       (1),
        .G_USE_AUTO_PRECHARGE ('0),
        .G_BURST_TYPE         ('0),
        .G_ADDR_WIDTH         (25),
        .G_SDRAM_ADDR_WIDTH   (13),
        .G_SDRAM_DATA_WIDTH   (16),
        .G_SDRAM_COL_WIDTH    (10),
        .G_SDRAM_ROW_WIDTH    (13),
        .G_SDRAM_BANK_WIDTH   (2),
        .G_T_DESL             (200_000.0),
        .G_T_MRD              (14.0),
        .G_T_RC               (65.0),
        .G_T_RCD              (15.0),
        .G_T_RP               (15.0),
        .G_T_WR               (14.0),
        .G_T_REFI             (7812.5)
    ) sdram (
        .I_CLOCK             (MAX10_CLK1_50),
        .I_RESET_N           (reset_n_sys),
        .I_ADDRESS           (sdram_address),
        .I_DATA              (sdram_data_write),
        .I_REQUEST           (sdram_rd_en || sdram_wr_en),
        .I_WRITE_ENABLE      (sdram_wr_en),
        .O_ACKNOWLEDGE       (sdram_ack),
        .O_VALID             (sdram_ready),
        .O_Q                 (sdram_data_out),
		  .O_STATE             (sdram_state_wire),
        .O_SDRAM_A           (DRAM_ADDR),
        .O_SDRAM_BA          (DRAM_BA),
        .IO_SDRAM_DQ         (DRAM_DQ),
        .O_SDRAM_CKE         (DRAM_CKE),
        .O_SDRAM_CS          (DRAM_CS_N),
        .O_SDRAM_RAS         (DRAM_RAS_N),
        .O_SDRAM_CAS         (DRAM_CAS_N),
        .O_SDRAM_WE          (DRAM_WE_N),
        .O_SDRAM_DQML        (DRAM_LDQM),
        .O_SDRAM_DQMH        (DRAM_UDQM),
        .O_SDRAM_INITIALIZED (sdram_initialized)
    );

// Drive SDRAM clock directly from internal clock
assign DRAM_CLK = MAX10_CLK1_50;

// On-chip memory signals
wire [15:0] expected_data_from_mem;
    wire [15:0] mem_data_in;
    wire [10:0] mem_address;
    wire        mem_wr_en;
	 wire        mem_rd_en;

// On-chip memory instance
    on_chip_memory onchip_mem (
        .clk              (clk_internal),
        .reset_n          (reset_n_sys),
        .wr_en            (mem_wr_en),
        .rd_en            (mem_rd_en),
        .data_in          (mem_data_in),
        .data_out         (expected_data_from_mem),
        .multi_cycle_mode (1'b0),
        .cycle_count      (2'd1),
        .address_in       (mem_address),
        .use_external_addr(1'b1)
    );


// Registers to hold latest read word and counter
reg [15:0] current_mem_word;
reg [6:0]  mem_read_counter;

always_ff @(posedge clk_internal or negedge reset_n_sys) begin
if (!reset_n_sys) begin
 current_mem_word <= 16'd0;
 mem_read_counter <= 7'd0;
end else if (gen_rd_en) begin
 current_mem_word <= expected_data_from_mem;
 mem_read_counter <= mem_read_counter + 7'd1;
end
end

// Registers for holding the expected single-bit output value
reg expected_single_out_r;

always_ff @(posedge clk_internal or negedge reset_n_sys) begin
if (!reset_n_sys) begin
 expected_single_out_r <= 1'b0;
end else begin
 if (mem_read_counter == 7'd66)
expected_single_out_r <= current_mem_word[0];  // bit 0 contains the expected single-bit result
end
end


 // Control unit that coordinates SDRAM load and signals start of test
    wire ctrl_wr_en;
    wire [9:0] ctrl_mem_address;
    wire ctrl_start_run, ctrl_all_done;
    wire led_done_wire;
	 logic [2:0] control_state;
	 reg counter;

     control_unit #(.LOAD_DEPTH(68)) ctrl (
    .clk               (clk_internal),
    .reset_n           (reset_n_sys),
    .start             (start_sig),
    .sdram_rd_en       (sdram_rd_en),
    .sdram_wr_en       (sdram_wr_en),
    .sdram_address     (sdram_address),
    .sdram_dout        (sdram_data_out),
    .sdram_ready       (sdram_ready),
    .mem_wr_en         (ctrl_wr_en),
    .mem_address       (ctrl_mem_address),
    .start_run         (ctrl_start_run),
    .led_done          (led_done_wire),
    .val_done          (val_done),
	 .done_67 (counter),
	 .sdram_initialized (sdram_initialized),
    .val_result_bits   (val_data_to_mem),
    .sdram_data_out    (sdram_data_write),
	 .state(control_state)
);

// Test generator to provide inputs to DUT from on-chip memory
    wire [10:0] gen_address;
    wire        gen_rd_en, gen_wr_en, gen_chip_sel;


    test_generator #(.ADDR_WIDTH(11)) gen (
        .clk         (clk_internal),
        .reset       (~reset_n_sys),
        .start       (ctrl_start_run),
        .address_BUS (gen_address),
        .rd_en       (gen_rd_en),
        .wr_en       (gen_wr_en),
        .val_done    (val_done),
        .chip_sel    (gen_chip_sel)
    );


    wire        mac_ready;
    wire        mac_single_output;

// Tristate bus to DUT ? drives data only when writing input vectors
wire [15:0] dut_bus;
assign dut_bus = gen_wr_en ? current_mem_word : 16'hZZZZ;
wire        output_bit;


// DUT instantiation ? MAC core under test
    top u_dut (
        .clk_in(clk_internal),
        .bus(dut_bus),
        .wr_en(gen_wr_en),
        .chip_sel(gen_chip_sel),
        .output_ready(mac_ready),
        .output_bit(mac_single_output),
        .wr_data_ptr(),
        .rd_data_ptr(),
        .ctrl_state()
    );


// Validator compares DUT output with expected and returns result
    wire [15:0] val_data_to_mem;
    wire        val_done;

validator #(.ADDR_WIDTH(11)) val (
    .clk           (clk_internal),
    .reset_n       (reset_n_sys),
    .dut_single_out(mac_single_output),
    .output_ready  (mac_ready),
    .data_to_mem   (val_data_to_mem),
    .val_done      (val_done),
    .expected_single_out(expected_single_out_r)
);

 
reg [10:0] mux_address;
reg [15:0] mux_data_in_r;
reg        mux_wr_en;
reg        mux_rd_en_r;

// Centralized bus multiplexer (MUX) controls access to on-chip memory
// Priority:
// 1. Control unit loads test data from SDRAM
// 2. Generator reads input stimulus (read-only)
// Prevents bus conflicts by ensuring only one source drives the bus at a time

always @(*) begin
    mux_wr_en     = 1'b0;
    mux_rd_en_r   = 1'b0;
    mux_address   = 11'd0;
    mux_data_in_r = 16'd0;

    // 1. Control unit loads test data from SDRAM
    if (ctrl_wr_en) begin
        mux_wr_en     = 1'b1;
        mux_address   = ctrl_mem_address;
        mux_data_in_r = sdram_data_out;

    // 2. Generator reads inputs to dut
    end else if (gen_rd_en) begin
        mux_rd_en_r   = 1'b1;
        mux_address   = gen_address;
    end
end

    assign mem_wr_en   = mux_wr_en;
    assign mem_rd_en   = mux_rd_en_r;
    assign mem_address = mux_address;
    assign mem_data_in = mux_data_in_r;


///////////DEBUG///////////


//assign GPIO_[0] = sdram_data_out[8];
//assign GPIO_[1] = sdram_data_out[9];
//assign GPIO_[2] = sdram_data_out[10];
//assign GPIO_[3] = sdram_data_out[11];
//assign GPIO_[4] = sdram_data_out[12];
//assign GPIO_[5] = sdram_data_out[13];
//assign GPIO_[6] = sdram_data_out[14];
//assign GPIO_[7] = sdram_data_out[15];

assign GPIO_[0] = control_state[0];
assign GPIO_[1] = control_state[1];
assign GPIO_[2] = control_state[2];
assign GPIO_[3] = counter;

//assign GPIO_[4] = reset_n_sys;
//assign GPIO_[4] = start_sig;

assign GPIO_[5] = sdram_ready;
assign GPIO_[6] = sdram_rd_en;
assign GPIO_[7] = sdram_ack;

//assign GPIO_[3:0]    = sdram_state_wire;    // SDRAM internal state [3:0]

assign GPIO_[8] = clk_internal;
assign GPIO_[13] = clk_internal;

// debug: raise a flag if on the 55th read we really got 16'b0011011000000010
wire match_word_55;
// binary 0011_0110_0000_0010 == 16'h3602
assign match_word_55 = (mem_data_in == 16'h3602);

// drive that onto a spare GPIO pin
assign GPIO_[4] = match_word_55;



//assign LEDR[0] = ~KEY_0;          // LED 0: physical button press (active-high)
//assign LEDR[2] = ~reset_n_sys;      // LED 2: system is in reset (active-high)


// 3)  Latch “validation done” pulse
sr_ff u_ff_val_done (
    .clk        (clk_internal),
    .rst_n      (reset_n_sys),
    .set_pulse  (led_done_wire),
    .Q          (led_done_latched)
);

assign LEDR[9] = led_done_latched;


endmodule
