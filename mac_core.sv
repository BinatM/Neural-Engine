module mac_core(
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] data_in,
    input  wire        wr_en,
    input  wire        rd_en,
    output reg  [15:0] data_out,
    output reg         output_ready
);
    // A simple skeleton
    reg [31:0] accumulator;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            accumulator  <= 32'b0;
            data_out     <= 16'b0;
            output_ready <= 0;
        end
        else begin
            if (wr_en) begin
                accumulator <= accumulator + data_in;
            end
            if (rd_en) begin
                data_out     <= accumulator[15:0]; // example
                output_ready <= 1;
            end
            else begin
                output_ready <= 0;
            end
        end
    end

endmodule
