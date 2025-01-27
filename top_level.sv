module top_level(
    // Clock Inputs
    input wire MAX10_CLK1_50,


    // SDRAM Interface
    output wire [12:0] DRAM_ADDR,   // SDRAM address bus
    output wire [1:0] DRAM_BA,      // SDRAM bank address
    output wire DRAM_CAS_N,         // SDRAM column address strobe
    output wire DRAM_RAS_N,         // SDRAM row address strobe
    output wire DRAM_WE_N,          // SDRAM write enable
    output wire DRAM_CLK,           // SDRAM clock
    output wire DRAM_CKE,           // SDRAM clock enable
    output wire DRAM_CS_N,          // SDRAM chip select
    inout wire [15:0] DRAM_DQ,      // SDRAM data bus
    output wire DRAM_LDQM,          // SDRAM lower data mask
    output wire DRAM_UDQM,          // SDRAM upper data mask

    // FPGA Logic Signals
    input wire KEY_0,        // Active-low reset
    input wire [15:0] FPGA_DATA_IN, // Input test data (16-bit wide for DUT)
    input wire FPGA_WR_EN,          // Write enable signal
    input wire FPGA_RD_EN,          // Read enable signal
    input wire FPGA_CHIP_SEL,       // Chip select for SDRAM
    output wire [15:0] FPGA_DATA_OUT, // DUT output data
    output wire FPGA_OUTPUT_READY,   // Output ready signal

    // GPIO Interface for External Test Board
    inout wire [15:0] GPIO_DATA,    // Bidirectional GPIO data bus
    output wire [10:0] GPIO_ADDR,   // GPIO address bus
    output wire GPIO_WR_EN,         // GPIO write enable
    output wire GPIO_RD_EN          // GPIO read enable
);

    // Internal signals
    wire [15:0] FPGA_DATA_BUS;      // Shared data bus for test data and threshold
    wire [10:0] Address_BUS;        // Address bus for generator/validator
    wire FPGA_START;                // Start signal from Control Unit

    // Clock Generator
    clock_generator clk_gen (
        .clk_in(MAX10_CLK1_50),
        .clk_out(clk_internal)
    );

    // SDRAM Controller
    sdram_controller sdram_ctrl (
        .clk(clk_internal),
        .reset_n(FPGA_RESET_N),
        .addr(DRAM_ADDR),
        .ba(DRAM_BA),
        .cas_n(DRAM_CAS_N),
        .ras_n(DRAM_RAS_N),
        .we_n(DRAM_WE_N),
        .clk_out(DRAM_CLK),
        .cke(DRAM_CKE),
        .cs_n(DRAM_CS_N),
        .dq(DRAM_DQ),
        .ldqm(DRAM_LDQM),
        .udqm(DRAM_UDQM),
        .data_in(FPGA_DATA_BUS),
        .data_out(FPGA_DATA_BUS),
        .wr_en(FPGA_WR_EN),
        .rd_en(FPGA_RD_EN),
        .chip_sel(FPGA_CHIP_SEL)
    );

    // On-Chip Memory
    on_chip_memory memory (
        .clk(clk_internal),
        .reset_n(FPGA_RESET_N),
        .wr_en(FPGA_WR_EN),
        .rd_en(FPGA_RD_EN),
        .data_in(FPGA_DATA_BUS),
        .data_out(FPGA_DATA_BUS),
        .multi_cycle_mode(1'b1),     // Enable multi-cycle operation
        .cycle_count(2)             // Data split across two cycles for >16-bit
    );

    // Control Unit
    control_unit ctrl (
        .clk(clk_internal),
        .reset_n(FPGA_RESET_N),
        .start(FPGA_START),
        .wr_en(FPGA_WR_EN),
        .rd_en(FPGA_RD_EN),
        .output_ready(FPGA_OUTPUT_READY)
    );

    // Test Generator
    test_generator gen (
        .clk(clk_internal),
        .reset_n(FPGA_RESET_N),
        .start(FPGA_START),
        .test_data_in(FPGA_DATA_IN),
        .data_out(FPGA_DATA_BUS),
        .address(Address_BUS),
        .wr_en(FPGA_WR_EN),
        .rd_en(FPGA_RD_EN),
        .chip_sel(FPGA_CHIP_SEL)
    );

    // Validator
    validator val (
        .clk(clk_internal),
        .reset_n(FPGA_RESET_N),
        .data_in(FPGA_DATA_BUS),
        .address(Address_BUS),
        .output(FPGA_DATA_OUT),
        .output_ready(FPGA_OUTPUT_READY),
        .wr_en(FPGA_WR_EN),
        .rd_en(FPGA_RD_EN)
    );

    // Device Under Test (DUT) or External Test Board
    `ifdef EXTERNAL_TEST_BOARD
    external_test_board dut (
        .clk(clk_internal),
        .reset_n(FPGA_RESET_N),
        .gpio_data(GPIO_DATA),
        .gpio_addr(GPIO_ADDR),
        .gpio_wr_en(GPIO_WR_EN),
        .gpio_rd_en(GPIO_RD_EN),
        .output_ready(FPGA_OUTPUT_READY)
    );
    `else
    mac_core dut (
        .clk(clk_internal),
        .reset_n(FPGA_RESET_N),
        .data_in(FPGA_DATA_BUS),
        .wr_en(FPGA_WR_EN),
        .rd_en(FPGA_RD_EN),
        .output(FPGA_DATA_OUT),
        .output_ready(FPGA_OUTPUT_READY)
    );
    `endif

endmodule
