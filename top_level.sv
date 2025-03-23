module top_level (
    input  wire         MAX10_CLK1_50,
    input  wire         KEY_0, // push-button, active-low

    input  wire [15:0]  FPGA_DATA_IN,
    output wire [15:0]  FPGA_DATA_OUT,
    output wire         FPGA_OUTPUT_READY
);

    // 1) Debounce push-button => reset
    wire db_key0;
    debounce_button #(.DELAY_MAX(100000)) key_deb (
        .clk       (MAX10_CLK1_50),
        .rst_n     (1'b1),
        .noisy_in  (KEY_0),
        .clean_out (db_key0)
    );

    // 2) reset & start
    wire reset_n_sys;
    wire start_sig;
    reset_and_start rs(
        .clk         (MAX10_CLK1_50),
        .db_button_in(db_key0),
        .reset_n_out (reset_n_sys),
        .start_pulse (start_sig)
    );

    // 3) clock_generator
    wire clk_internal;
    clock_generator clkgen(
        .clk_in  (MAX10_CLK1_50),
        .clk_out (clk_internal)
    );

    // 4) SDRAM Controller (Stub) - read only
    wire [15:0] sdram_data_out;
    wire [15:0] sdram_data_in = 16'd0; 
    wire        sdram_rd_en;
    sdram_controller sdram (
        .clk       (clk_internal),
        .reset_n   (reset_n_sys),
        .wr_en     (1'b0),             // not used
        .rd_en     (sdram_rd_en),      // for LOAD
        .data_in   (sdram_data_in),
        .data_out  (sdram_data_out),
        .address   (24'd0),
        .ready     (), // unused
        // stub signals
        .addr      (),
        .ba        (),
        .cas_n     (),
        .ras_n     (),
        .we_n      (),
        .clk_out   (),
        .cke       (),
        .cs_n      (),
        .dq        (),
        .ldqm      (),
        .udqm      ()
    );

    // 5) on_chip_memory
    wire [15:0] mem_data_out;
    wire [15:0] mem_data_in;
    wire [10:0] mem_address;
    wire        mem_wr_en;
    wire        mem_rd_en;

    on_chip_memory onchip_mem(
        .clk              (clk_internal),
        .reset_n          (reset_n_sys),
        .wr_en            (mem_wr_en),
        .rd_en            (mem_rd_en),
        .data_in          (mem_data_in),
        .data_out         (mem_data_out),
        .multi_cycle_mode (1'b0),
        .cycle_count      (2'd1),
        .address_in       (mem_address),
        .use_external_addr(1'b1)
    );

    // 6) control_unit - load from SDRAM => on_chip_memory, then run
    wire        ctrl_wr_en;
    wire [10:0] ctrl_mem_address;
    wire        start_run;
    wire        ctrl_output_ready;

    control_unit #(.LOAD_DEPTH(256)) ctrl(
        .clk         (clk_internal),
        .reset_n     (reset_n_sys),
        .start       (start_sig),

        // LOAD signals
        .sdram_rd_en (sdram_rd_en),
        .mem_wr_en   (ctrl_wr_en),
        .mem_address (ctrl_mem_address),

        // run signals
        .wr_en       (),  // not used
        .rd_en       (),
        .output_ready(ctrl_output_ready),
        .start_run   (start_run)
    );

    // 7) generator
    wire [10:0] gen_address;
    wire        gen_rd_en, gen_wr_en, gen_chip_sel;
    wire [15:0] gen_data_out;
    test_generator #(.ADDR_WIDTH(11)) gen (
        .clk         (clk_internal),
        .reset       (~reset_n_sys),
        .start       (start_run),
        .address_BUS (gen_address),
        .DATA_BUS    (gen_data_out), // generator might produce data if needed
        .rd_en       (gen_rd_en),
        .wr_en       (gen_wr_en),
        .chip_sel    (gen_chip_sel)
    );

    // 8) mac_core
    wire [15:0] mac_data_out;
    wire        mac_ready;
    mac_core dut (
        .clk          (clk_internal),
        .reset_n      (reset_n_sys),

        // ** get data from on_chip_memory **
        .data_in      (mem_data_out),

        // control signals from generator
        .wr_en        (gen_wr_en),
        .rd_en        (gen_rd_en),
        .chip_sel     (gen_chip_sel),

        // out
        .data_out     (mac_data_out),
        .output_ready (mac_ready)
    );

    // 9) validator
    wire [10:0] val_address_out;
    wire        val_rd_en, val_wr_en;
    wire [15:0] val_data_to_mem;
    wire        val_done;
    validator #(.ADDR_WIDTH(11)) val (
        .clk          (clk_internal),
        .reset_n      (reset_n_sys),
        .output_ready (mac_ready),
        .dut_output   (mac_data_out),

        // memory I/F
        .address_out  (val_address_out),
        .rd_en        (val_rd_en),
        .wr_en        (val_wr_en),
        .mem_data_out (mem_data_out),  
        .data_to_mem  (val_data_to_mem),

        .val_done     (val_done)
    );

    // 10) MUX to memory
    reg [10:0] mux_address;
    reg [15:0] mux_data_in_r;
    reg        mux_wr_en, mux_rd_en_r;

    always @(*) begin
        mux_wr_en   = 1'b0;
        mux_rd_en_r = 1'b0;
        mux_address = 11'd0;
        mux_data_in_r = 16'd0;

        // 1) control_unit load
        if (ctrl_wr_en) begin
            mux_wr_en     = 1'b1;
            mux_address   = ctrl_mem_address;
            mux_data_in_r = sdram_data_out;
        end
        // 2) generator read
        else if (gen_wr_en || gen_rd_en) begin
            mux_wr_en     = gen_wr_en;
            mux_rd_en_r   = gen_rd_en;
            mux_address   = gen_address;
            mux_data_in_r = 16'd0; 
        end
        // 3) validator
        else if (val_wr_en || val_rd_en) begin
            mux_wr_en     = val_wr_en;
            mux_rd_en_r   = val_rd_en;
            mux_address   = val_address_out;
            mux_data_in_r = val_data_to_mem;
        end
    end

    assign mem_wr_en   = mux_wr_en;
    assign mem_rd_en   = mux_rd_en_r;
    assign mem_address = mux_address;
    assign mem_data_in = mux_data_in_r;

    // 11) OUTPUT signals
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

endmodule
