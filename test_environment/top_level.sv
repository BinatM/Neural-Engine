module top_level (
    input  wire         MAX10_CLK1_50,
    input  wire         KEY_0,

    input  wire [15:0]  FPGA_DATA_IN,
    output wire [15:0]  FPGA_DATA_OUT,
    output wire         FPGA_OUTPUT_READY,

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
    output wire [9:0]   LEDR
);

wire expected_data_en;
wire expected_output_en;

    wire db_key0;
    debounce_button #(.DELAY_MAX(100000)) key_deb (
        .clk       (MAX10_CLK1_50),
        .rst_n     (1'b1),
        .noisy_in  (KEY_0),
        .clean_out (db_key0)
    );

    wire reset_n_sys;
    wire start_sig;
    reset_and_start rs(
        .clk         (MAX10_CLK1_50),
        .db_button_in(db_key0),
        .reset_n_out (reset_n_sys),
        .start_pulse (start_sig)
    );

    wire clk_internal;
    clock_generator clkgen(
        .clk_in  (MAX10_CLK1_50),
        .clk_out (clk_internal)
    );

    wire [15:0] sdram_data_out;
    wire [15:0] sdram_data_in;
    wire [23:0] sdram_address;
    wire        sdram_rd_en, sdram_wr_en;
    wire        sdram_ready;

       SDRAM_CONTROLLER #(
        .G_CLK_FREQ           (50.0),
        .G_CAS_LATENCY        (2),
        .G_WRITE_BURST_MODE   ('0),
        .G_BURST_LENGTH       (1),
        .G_USE_AUTO_PRECHARGE ('0),
        .G_BURST_TYPE         ('0),
        .G_ADDR_WIDTH         (24),
        .G_SDRAM_ADDR_WIDTH   (13),
        .G_SDRAM_DATA_WIDTH   (16),
        .G_SDRAM_COL_WIDTH    (9),
        .G_SDRAM_ROW_WIDTH    (13),
        .G_SDRAM_BANK_WIDTH   (2),
        .G_T_DESL             (200_000.0),
        .G_T_MRD              (14.0),
        .G_T_RC               (65.0),
        .G_T_RCD              (20.0),
        .G_T_RP               (20.0),
        .G_T_WR               (14.0),
        .G_T_REFI             (7800.0)
    ) sdram (
        .I_CLOCK             (clk_internal),
        .I_RESET_N           (reset_n_sys),
        .I_ADDRESS           (sdram_address),
        .I_DATA              (sdram_data_write),
        .I_REQUEST           (sdram_rd_en || sdram_wr_en),
        .I_WRITE_ENABLE      (sdram_wr_en),
        .O_ACKNOWLEDGE       (),
        .O_VALID             (sdram_ready),
        .O_Q                 (sdram_data_out),
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
        .O_SDRAM_INITIALIZED ()
    );


assign DRAM_CLK = clk_internal;

wire [15:0] expected_data_from_mem;
    wire [15:0] mem_data_out;
    wire [15:0] mem_data_in;
    wire [10:0] mem_address;
    wire        mem_wr_en;
    wire        mem_rd_en;

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

reg [15:0] expected_word1_r;
reg [21:0] expected_mac_output_r;
reg        expected_single_out_r;

always_ff @(posedge clk_internal or negedge reset_n_sys) begin
    if (!reset_n_sys) begin
        expected_word1_r        <= 16'd0;
        expected_mac_output_r   <= 22'd0;
        expected_single_out_r   <= 1'b0;
    end else begin
        if (expected_data_en)
            expected_word1_r <= expected_data_from_mem;
        if (expected_output_en) begin
            expected_mac_output_r   <= {expected_data_from_mem[5:0], expected_word1_r};
            expected_single_out_r   <= expected_data_from_mem[6];
        end
    end
end
    // Control Unit
    wire ctrl_wr_en;
    wire [9:0] ctrl_mem_address;
    wire ctrl_output_ready, ctrl_start_run, ctrl_all_done;
    wire led_done_wire;

     control_unit #(.LOAD_DEPTH(69)) ctrl (
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
    .output_ready      (ctrl_output_ready),
    .start_run         (ctrl_start_run),
    .led_done          (led_done_wire),
    .val_result_bits   (mem_data_out),
    .sdram_data_out    (sdram_data_write),
    .expected_data_en  (expected_data_en),    
    .expected_output_en(expected_output_en)    
);

  //  reg [15:0] expected_mac;
    //reg        expected_out;

    //always_ff @(posedge clk_internal or negedge reset_n_sys) begin
      //  if (!reset_n_sys) begin
        //    expected_mac <= 16'd0;
          //  expected_out <= 1'b0;
       // end else begin
         //   if (expected_data_en)
           //     expected_mac <= mem_data_out;
           // if (expected_output_en)
             //   expected_out <= mem_data_out[0];
        //end
    //end

    // Generator
    wire [10:0] gen_address;
    wire        gen_rd_en, gen_wr_en, gen_chip_sel;


    test_generator #(.ADDR_WIDTH(11)) gen (
        .clk         (clk_internal),
        .reset       (~reset_n_sys),
        .start       (ctrl_start_run),
        .address_BUS (gen_address),
        .rd_en       (gen_rd_en),
        .wr_en       (gen_wr_en),
 .output_ready(output_ready),
        .chip_sel    (gen_chip_sel)
    );

    // MAC core
    wire [15:0] mac_data_out;
    wire        mac_ready;
wire mac_single_output;
    assign      output_ready = mac_ready;

//mac_core dut (
 //   .clk          (clk_internal),
 //   .reset_n      (reset_n_sys),
 //   .data_in      (mem_data_out),
 //   .wr_en        (gen_wr_en),
 //   .rd_en        (gen_rd_en),
 //   .chip_sel     (gen_chip_sel),

    // These should match your mac_core.sv ports
 //   .data_out     (mac_data_out),
 //   .output_ready (mac_ready),
// .mac_single_output (mac_single_output_wire),
//);
    top u_dut (
        .clk_in(clk_internal),
        .bus(mem_data_out),
        .wr_en(gen_wr_en),
        .rd_en(gen_rd_en),
        .chip_sel(gen_chip_sel),
        .output_ready(mac_ready),
        .output_bit(mac_single_output),
        .wr_data_ptr(),
        .rd_data_ptr(),
        .ctrl_state()
    );
reg [15:0] mac_data_mux;

always @(*) begin
    if (mac_ready) begin
        mac_data_mux = mem_data_out;
    end else if (ctrl_output_ready) begin
        mac_data_mux = 16'h9999;
    end else if (val_done) begin
        mac_data_mux = 16'hF0F0;
    end else begin
        mac_data_mux = 16'h0000;
    end
end

assign mac_data_out = mac_data_mux;


    // Validator
    wire [10:0] val_address_out;
    wire        val_rd_en, val_wr_en;
    wire [15:0] val_data_to_mem;
    wire        val_done;

validator #(.ADDR_WIDTH(11)) val (
    .clk           (clk_internal),
    .reset_n       (reset_n_sys),
    .dut_data_out  (mac_data_out),
    .dut_single_out(mac_single_output),
    .output_ready  (mac_ready),
    .address_out   (val_address_out),
    .rd_en         (val_rd_en),
    .wr_en         (val_wr_en),
    .data_to_mem   (val_data_to_mem),
    .gen_wr_en     (gen_wr_en),
    .val_done      (val_done),
    .expected_mac_output(expected_mac_output_r),
    .expected_single_out(expected_single_out_r)
);

 
reg [10:0] mux_address;
reg [15:0] mux_data_in_r;
reg        mux_wr_en;
reg        mux_rd_en_r;

    // MUX
always @(*) begin
    mux_wr_en     = 1'b0;
    mux_rd_en_r   = 1'b0;
    mux_address   = 11'd0;
    mux_data_in_r = 16'd0;

    if (expected_data_en || expected_output_en) begin

        mux_wr_en     = val_wr_en;
        mux_rd_en_r   = val_rd_en;
        mux_address   = val_address_out;
        mux_data_in_r = val_data_to_mem;
    end else if (ctrl_wr_en) begin
        mux_wr_en     = 1'b1;
        mux_address   = ctrl_mem_address;
        mux_data_in_r = sdram_data_out;
    end else if (gen_wr_en || gen_rd_en) begin
        mux_wr_en     = gen_wr_en;
        mux_rd_en_r   = gen_rd_en;
        mux_address   = gen_address;
        mux_data_in_r = 16'd0;
    end
end


    assign mem_wr_en   = mux_wr_en;
    assign mem_rd_en   = mux_rd_en_r;
    assign mem_address = mux_address;
    assign mem_data_in = mux_data_in_r;

    // Output
    wire any_ready = mac_ready || val_done || ctrl_output_ready;
    assign FPGA_OUTPUT_READY = any_ready;

    reg [15:0] internal_data;
    always @(*) begin
        if (val_done)
            internal_data = 16'hF0F0;
        else if (mac_ready)
            internal_data = mac_data_out;
        else if (ctrl_output_ready)
            internal_data = 16'h9999;
        else
            internal_data = 16'h0000;
    end

    assign FPGA_DATA_OUT = internal_data;
    assign LEDR[9] = led_done_wire;


endmodule