module tb_validator;

    // Clock and reset
    reg clk, reset_n;

    // DUT outputs (simulated)
    reg [15:0] dut_data_out;
    reg        dut_single_out;
    reg        output_ready;

    // Generator control signal
    reg gen_wr_en;

    // Memory interface
    wire [10:0] address_out;
    wire        rd_en, wr_en;
    wire [15:0] mem_data_out;
    wire [15:0] data_to_mem;
    wire        val_done;

    // Memory model
    reg [15:0] memory [0:2047];
    assign mem_data_out = memory[address_out];

    // Instantiate the validator module
    validator dut (
        .clk(clk),
        .reset_n(reset_n),
        .dut_data_out(dut_data_out),
        .dut_single_out(dut_single_out),
        .output_ready(output_ready),
        .gen_wr_en(gen_wr_en),
        .address_out(address_out),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .mem_data_out(mem_data_out),
        .data_to_mem(data_to_mem),
        .val_done(val_done)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Memory write operation
    always @(posedge clk) begin
        if (wr_en)
            memory[address_out] <= data_to_mem;
    end

    // Test variables
    reg [21:0] expected_mac;
    reg        expected_single_bit;

    initial begin
        $display("Starting simulation...");

        // Initialize
        clk = 0;
        reset_n = 0;
        dut_data_out = 0;
        dut_single_out = 0;
        output_ready = 0;
        gen_wr_en = 0;

        expected_mac = 22'h123456;        // full MAC value
        expected_single_bit = 1'b1;

        // Apply reset
        #20;
        reset_n = 1;

        // Load expected values into memory
        memory[512] = expected_mac[15:0];               // lower 16 bits
        memory[513] = {9'b0, expected_single_bit, expected_mac[21:16]}; // 6 MSBs and single bit

        #100;

        // Drive gen_wr_en high for 66 cycles
        repeat (66) begin
            gen_wr_en = 1;
            #10;
        end
        gen_wr_en = 0;

        #10;

        // Send lower 16 bits of MAC
        dut_data_out = expected_mac[15:0];
        #10;

        // Send upper 6 bits in bits [5:0]
        dut_data_out = {10'b0, expected_mac[21:16]};
        dut_single_out = expected_single_bit;
        output_ready = 1;
        #10;
        output_ready = 0;

        // Wait for validator to complete
        #100;

        // Print results from memory
        $display("Validation result (memory[1000]): %b", memory[1000]);

        // Print what was expected and what was sent
        $display("Expected MAC:        0x%h", expected_mac);
        $display("Expected single bit: %b", expected_single_bit);
        $display("Sent lower 16 bits:  0x%h", expected_mac[15:0]);
        $display("Sent upper 6 bits:   0x%h", expected_mac[21:16]);

        $stop;
    end

endmodule