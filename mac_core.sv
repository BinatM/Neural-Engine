module mac_core(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        chip_sel,    // This “enables” or “starts” the MAC operation
    input  wire [15:0] data_in,
    input  wire        wr_en,
    input  wire        rd_en,
    output reg  [15:0] data_out,
    output reg         output_ready
);

    reg [31:0] accumulator;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            accumulator  <= 32'd0;
            data_out     <= 16'd0;
            output_ready <= 1'b0;
        end
        else begin
            // Only operate if chip_sel is asserted
            if (chip_sel) begin
                // Accumulate on wr_en
                if (wr_en) begin
                    accumulator <= accumulator + data_in;
                end
                // Latch out result on rd_en
                if (rd_en) begin
                    data_out     <= accumulator[15:0];
                    output_ready <= 1'b1;
                end
                else begin
                    output_ready <= 1'b0;
                end
            end
            else begin
                // If chip_sel=0, do nothing
                output_ready <= 1'b0;
            end
        end
    end

endmodule
