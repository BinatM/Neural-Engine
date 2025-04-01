module mac_core(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        chip_sel,         // "enables" or "starts" the MAC operation
    input  wire [15:0] data_in,
    input  wire        wr_en,
    input  wire        rd_en,

    output reg  [15:0] data_out,         // 16-bit partial MAC result (two-cycle)
    output reg         mac_single_output,// single line for pass/fail or threshold check
    output reg         output_ready
);

    //---------------------------------------------------------
    // Example: 32-bit internal accumulator
    // We'll pretend only the lower 22 bits are relevant
    //---------------------------------------------------------
    reg [31:0] accumulator;
    localparam [31:0] THRESHOLD = 32'd1000; // example threshold

    //---------------------------------------------------------
    // We'll track which "read phase" we're in:
    //   0 => first read returns lower 16 bits
    //   1 => second read returns upper 6 bits in data_out[5:0],
    //        plus 1 bit in mac_single_output
    //---------------------------------------------------------
    reg read_phase;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            accumulator       <= 32'd0;
            data_out          <= 16'd0;
            mac_single_output <= 1'b0;
            output_ready      <= 1'b0;
            read_phase        <= 1'b0;
        end
        else begin
            // Only operate if chip_sel is asserted
            if (chip_sel) begin

                // Accumulate on wr_en
                if (wr_en) begin
                    accumulator <= accumulator + data_in;
                end

                // If there's a read, toggle between two read phases
                if (rd_en) begin
                    // Always set output_ready when we do a read
                    output_ready <= 1'b1;

                    // First read cycle => output lower 16 bits
                    if (!read_phase) begin
                        data_out <= accumulator[15:0];
                        // Single output is stable in second read, so 0 here or 
                        // you could always show current threshold check
                        mac_single_output <= (accumulator >= THRESHOLD);
                        read_phase <= 1'b1;
                    end
                    // Second read cycle => output top bits
                    else begin
                        // Put upper 6 bits in the lower bits of data_out
                        // e.g. data_out[5:0] = accumulator[21:16]
                        // remainder bits 15:6 => 0
                        data_out <= { 10'b0, accumulator[21:16] };
                        // We also update the single bit based on threshold
                        mac_single_output <= (accumulator >= THRESHOLD);
                        // Return to first read phase
                        read_phase <= 1'b0;
                    end
                end 
                else begin
                    // No read => no new data on data_out
                    output_ready <= 1'b0;
                end

            end // if (chip_sel)
            else begin
                // If chip_sel=0, we do nothing
                output_ready <= 1'b0;
                read_phase   <= 1'b0; // reset read_phase if desired
            end
        end
    end

endmodule
