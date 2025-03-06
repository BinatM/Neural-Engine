module test_generator(
    input wire clk,
    input wire reset_n,
    input wire start,
    input wire [15:0] test_data_in,
    output reg [15:0] data_out,
    output reg [10:0] address,
    output reg wr_en,
    output reg rd_en,
    output reg chip_sel
);

    reg [10:0] addr_counter;
    reg active;
    reg [3:0] state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            addr_counter <= 0;
            data_out <= 0;
            address <= 0;
            wr_en <= 0;
            rd_en <= 0;
            chip_sel <= 0;
            active <= 0;
            state <= 0;
        end else begin
            case (state)
                0: if (start) begin
                        active <= 1;
                        chip_sel <= 1;
                        state <= 1;
                   end
                1: if (active) begin
                        address <= addr_counter;
                        data_out <= test_data_in;
                        wr_en <= 1;
                        rd_en <= 0;
                        state <= 2;
                   end
                2: begin
                        wr_en <= 0;
                        rd_en <= 1;
                        state <= 3;
                   end
                3: begin
                        rd_en <= 0;
                        addr_counter <= addr_counter + 1;
                        if (addr_counter == 11'b11111111111) begin
                            chip_sel <= 0;
                            active <= 0;
                            state <= 0;
                        end else begin
                            state <= 1;
                        end
                   end
            endcase
        end
    end
endmodule
