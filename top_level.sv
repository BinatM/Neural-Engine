module top_level (
    input  wire MAX10_CLK1_50,
    input  wire KEY_0,         // raw push-button, active-low

    // Other I/Os, e.g. for test data
    input  wire [15:0] FPGA_DATA_IN,
    output wire [15:0] FPGA_DATA_OUT,
    output wire        FPGA_OUTPUT_READY
);

    // 1) Debounce the raw KEY_0
    wire db_key0;
    debounce_button #(.DELAY_MAX(100000)) key0_debouncer (
        .clk       (MAX10_CLK1_50),
        .rst_n     (1'b1),  // if you want a higher-level reset, feed that in
        .noisy_in  (KEY_0),
        .clean_out (db_key0)  // stable, active-low
    );

    // 2) Create a system reset and start pulse
    wire reset_n_sys;  // for entire system
    wire start_sig;
    reset_and_start rs(
        .clk         (MAX10_CLK1_50),
        .db_button_in(db_key0),    // active-low stable
        .reset_n_out (reset_n_sys),// active-low system reset
        .start_pulse (start_sig)   // 1-cycle active-high
    );

    // 3) Clock generator or pass-through
    wire clk_internal;
    clock_generator clk_gen(
        .clk_in  (MAX10_CLK1_50),
        .clk_out (clk_internal)
    );

    // 4) Control unit
    wire ctrl_wr_en, ctrl_rd_en;
    wire ctrl_output_ready;
    control_unit ctrl(
        .clk         (clk_internal),
        .reset_n     (reset_n_sys),
        .start       (start_sig),
        .wr_en       (ctrl_wr_en),
        .rd_en       (ctrl_rd_en),
        .output_ready(ctrl_output_ready)
    );

    // 5) Test generator 
    wire [15:0] gen_data_out;
    wire [10:0] gen_address;
    wire gen_wr_en, gen_rd_en, gen_chip_sel;

    test_generator gen (
        .clk          (clk_internal),
        .reset_n      (reset_n_sys),
        .start        (start_sig),
        .test_data_in (FPGA_DATA_IN),
        .data_out     (gen_data_out),
        .address      (gen_address),
        .wr_en        (gen_wr_en),
        .rd_en        (gen_rd_en),
        .chip_sel     (gen_chip_sel)
    );

    // 6) Merge signals from control_unit + test_generator
    wire final_wr_en  = ctrl_wr_en | gen_wr_en;
    wire final_rd_en  = ctrl_rd_en | gen_rd_en;
    // If you had a chip_sel from user or from generator:
    wire final_chip_sel = gen_chip_sel; // Or add an OR with some external

    // 7) mac_core
    wire [15:0] mac_data_out;
    wire mac_ready;
    mac_core dut (
        .clk          (clk_internal),
        .reset_n      (reset_n_sys),
        .data_in      (gen_data_out),
        .wr_en        (final_wr_en),
        .rd_en        (final_rd_en),
        .data_out     (mac_data_out),
        .output_ready (mac_ready)
    );

    // 8) validator
    wire [15:0] val_data_out;
    wire val_ready;
    validator val(
        .clk          (clk_internal),
        .reset_n      (reset_n_sys),
        .data_in      (gen_data_out),
        .address      (gen_address),
        .data_out     (val_data_out),
        .output_ready (val_ready),
        .wr_en        (final_wr_en),
        .rd_en        (final_rd_en)
    );

    // 9) sdram_controller stub for demonstration
    // If you want real on-board SDRAM, you'll have to adapt a proper alt_sdram or a pre-made IP.
    wire [15:0] sdram_dummy_out;
    sdram_controller sdram(
        .clk         (clk_internal),
        .reset_n     (reset_n_sys),
        .addr        (),
        .ba          (),
        .cas_n       (),
        .ras_n       (),
        .we_n        (),
        .clk_out     (),
        .cke         (),
        .cs_n        (),
        .dq          (),
        .ldqm        (),
        .udqm        (),
        .data_in     (gen_data_out),
        .data_out    (sdram_dummy_out),
        .wr_en       (final_wr_en),
        .rd_en       (final_rd_en),
        .chip_sel    (final_chip_sel)
    );

    // 10) Output selection
    reg [15:0] internal_data;
    reg        internal_ready;

    always @(*) begin
        if (val_ready) begin
            internal_data  = val_data_out;
            internal_ready = 1'b1;
        end
        else if (mac_ready) begin
            internal_data  = mac_data_out;
            internal_ready = 1'b1;
        end
        else begin
            internal_data  = 16'b0;
            internal_ready = ctrl_output_ready;
        end
    end

    assign FPGA_DATA_OUT     = internal_data;
    assign FPGA_OUTPUT_READY = internal_ready;

endmodule
