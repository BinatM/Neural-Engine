module top_level (
    // Clock Inputs
    input  wire MAX10_CLK1_50,

    // SDRAM Interface
    output wire [12:0] DRAM_ADDR,
    output wire [1:0]  DRAM_BA,
    output wire        DRAM_CAS_N,
    output wire        DRAM_RAS_N,
    output wire        DRAM_WE_N,
    output wire        DRAM_CLK,
    output wire        DRAM_CKE,
    output wire        DRAM_CS_N,
    inout  wire [15:0] DRAM_DQ,
    output wire        DRAM_LDQM,
    output wire        DRAM_UDQM,

    // FPGA Logic Signals
    input  wire        KEY_0,
    input  wire [15:0] FPGA_DATA_IN,
    input  wire        FPGA_CHIP_SEL,  // external chip select
    output reg  [15:0] FPGA_DATA_OUT,
    output reg         FPGA_OUTPUT_READY,

    // GPIO Interface for External Test Board
    inout wire [15:0]  GPIO_DATA,
    output reg [10:0]  GPIO_ADDR,
    output reg         GPIO_WR_EN,
    output reg         GPIO_RD_EN
);
    // Internal signals
    wire clk_internal;
    wire FPGA_RESET_N = ~KEY_0;

    // from test_generator
    wire [15:0] testgen_data_out;
    wire [10:0] testgen_addr;
    wire        testgen_wr_en;
    wire        testgen_rd_en;
    wire        testgen_chip_sel;

    // from control_unit
    wire        ctrl_wr_en;
    wire        ctrl_rd_en;
    wire        ctrl_output_ready;

    // from sdram_controller
    wire [15:0] sdram_data_out;

    // from on_chip_memory
    wire [15:0] mem_data_out;

    // from validator
    wire [15:0] val_data_out;
    wire        val_output_ready;

    // from mac_core
    wire [15:0] mac_data_out;
    wire        mac_output_ready;

    // pick data bus from one source
    reg [15:0] FPGA_DATA_BUS;
    
    // clock generator
    clock_generator clk_gen(
        .clk_in (MAX10_CLK1_50),
        .clk_out(clk_internal)
    );

    // control_unit
    control_unit ctrl(
        .clk         (clk_internal),
        .reset_n     (FPGA_RESET_N),
        .start       (1'b0), // Hard-coded example or connect if needed
        .wr_en       (ctrl_wr_en),
        .rd_en       (ctrl_rd_en),
        .output_ready(ctrl_output_ready)
    );

    // test_generator
    test_generator gen(
        .clk         (clk_internal),
        .reset_n     (FPGA_RESET_N),
        .start       (1'b0),  // or from external if needed
        .test_data_in(FPGA_DATA_IN),
        .data_out    (testgen_data_out),
        .address     (testgen_addr),
        .wr_en       (testgen_wr_en),
        .rd_en       (testgen_rd_en),
        .chip_sel    (testgen_chip_sel)
    );

    // pick which set of signals is driving wr_en/rd_en/chip_sel
    // for example, if we let test_generator override them:
    wire final_wr_en  = testgen_wr_en  | ctrl_wr_en; 
    wire final_rd_en  = testgen_rd_en  | ctrl_rd_en;
    wire final_sel    = testgen_chip_sel | FPGA_CHIP_SEL; 

    // sdram_controller
    sdram_controller sdram_ctrl(
        .clk        (clk_internal),
        .reset_n    (FPGA_RESET_N),
        .addr       (DRAM_ADDR),
        .ba         (DRAM_BA),
        .cas_n      (DRAM_CAS_N),
        .ras_n      (DRAM_RAS_N),
        .we_n       (DRAM_WE_N),
        .clk_out    (DRAM_CLK),
        .cke        (DRAM_CKE),
        .cs_n       (DRAM_CS_N),
        .dq         (DRAM_DQ),
        .ldqm       (DRAM_LDQM),
        .udqm       (DRAM_UDQM),
        .data_in    (FPGA_DATA_BUS),
        .data_out   (sdram_data_out),
        .wr_en      (final_wr_en),
        .rd_en      (final_rd_en),
        .chip_sel   (final_sel)
    );

    // on_chip_memory
    on_chip_memory memory(
        .clk             (clk_internal),
        .reset_n         (FPGA_RESET_N),
        .wr_en           (final_wr_en),
        .rd_en           (final_rd_en),
        .data_in         (FPGA_DATA_BUS),
        .data_out        (mem_data_out),
        .multi_cycle_mode(1'b1),
        .cycle_count     (2)
    );

    // validator
    validator val(
        .clk          (clk_internal),
        .reset_n      (FPGA_RESET_N),
        .data_in      (FPGA_DATA_BUS),
        .address      (testgen_addr),
        .data_out     (val_data_out),
        .output_ready (val_output_ready),
        .wr_en        (final_wr_en),
        .rd_en        (final_rd_en)
    );

    // mac_core
    mac_core dut(
        .clk          (clk_internal),
        .reset_n      (FPGA_RESET_N),
        .data_in      (FPGA_DATA_BUS),
        .wr_en        (final_wr_en),
        .rd_en        (final_rd_en),
        .data_out     (mac_data_out),
        .output_ready (mac_output_ready)
    );

    // Simple multiplexer for data bus
    // Priority: testgen_data_out -> sdram_data_out -> mem_data_out
    always @(*) begin
        // default
        FPGA_DATA_BUS = 16'b0;
        // choose which module is writing
        if (testgen_wr_en) begin
            FPGA_DATA_BUS = testgen_data_out;
        end
        else if (final_wr_en && final_sel) begin
            // example approach: if sdram is selected
            FPGA_DATA_BUS = sdram_data_out;
        end
        else if (final_wr_en) begin
            FPGA_DATA_BUS = mem_data_out;
        end
    end

    // combine or select output
    always @(*) begin
        if (val_output_ready) begin
            FPGA_DATA_OUT       = val_data_out;
            FPGA_OUTPUT_READY   = 1'b1;
        end
        else if (mac_output_ready) begin
            FPGA_DATA_OUT       = mac_data_out;
            FPGA_OUTPUT_READY   = 1'b1;
        end
        else begin
            FPGA_DATA_OUT       = 16'b0;
            FPGA_OUTPUT_READY   = ctrl_output_ready;
        end
    end

    // Provide default assignments for unused signals
    initial begin
        GPIO_ADDR   = 0;
        GPIO_WR_EN  = 0;
        GPIO_RD_EN  = 0;
    end

endmodule
