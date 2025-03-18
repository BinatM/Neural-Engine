module validator(
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] data_in,
    input  wire [10:0] address,
    output reg  [15:0] data_out,
    output reg         output_ready,
    input  wire        wr_en,
    input  wire        rd_en
);
    
    reg [15:0] memory [0:2047]; // 2K x 16-bit
    reg [3:0]  state;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            output_ready <= 0;
            data_out     <= 0;
            state        <= 0;
        end else begin
            case (state)
                0: if (wr_en) begin
                        memory[address] <= data_in;
                        state <= 1;
                   end else if (rd_en) begin
                        data_out       <= memory[address];
                        output_ready   <= 1;
                        state          <= 2;
                   end
                1: begin
                    // end write
                    state <= 0;
                   end
                2: begin
                    // end read
                    output_ready <= 0;
                    state        <= 0;
                   end
                default: state <= 0;
            endcase
        end
    end

endmodule
