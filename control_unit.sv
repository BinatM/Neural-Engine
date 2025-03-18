module control_unit(
    input  wire clk,
    input  wire reset_n,
    input  wire start,
    output reg  wr_en,
    output reg  rd_en,
    output reg  output_ready
);

    // This is a minimal skeleton. You can expand as needed.
    reg [3:0] state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_en         <= 0;
            rd_en         <= 0;
            output_ready  <= 0;
            state         <= 0;
        end
        else begin
            case (state)
                0: if (start) begin
                       // Example: set wr_en to 1 for demonstration
                       wr_en <= 1;
                       state <= 1;
                   end
                1: begin
                    wr_en <= 0;
                    rd_en <= 1;
                    state <= 2;
                end
                2: begin
                    rd_en        <= 0;
                    output_ready <= 1;
                    state        <= 3;
                end
                3: begin
                    output_ready <= 0;
                    state        <= 0;
                end
                default: state <= 0;
            endcase
        end
    end
endmodule
