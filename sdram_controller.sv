module sdram_controller(
    input wire clk,
    input wire reset_n,
    output reg [12:0] addr,
    output reg [1:0] ba,
    output reg cas_n,
    output reg ras_n,
    output reg we_n,
    output reg clk_out,
    output reg cke,
    output reg cs_n,
    inout wire [15:0] dq,
    output reg ldqm,
    output reg udqm,
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    input wire wr_en,
    input wire rd_en,
    input wire chip_sel
);

    reg [3:0] state;
    reg [15:0] memory [0:8191]; // 8K x 16-bit SDRAM
    reg [12:0] addr_counter;
    reg write_cycle, read_cycle;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 0;
            addr_counter <= 0;
            cas_n <= 1;
            ras_n <= 1;
            we_n <= 1;
            cs_n <= 1;
            cke <= 0;
            ldqm <= 0;
            udqm <= 0;
            data_out <= 0;
            write_cycle <= 0;
            read_cycle <= 0;
        end else begin
            case (state)
                0: if (chip_sel) begin
                        cke <= 1;
                        cs_n <= 0;
                        state <= 1;
                   end
                1: if (wr_en && !write_cycle) begin
                        memory[addr_counter] <= data_in;
                        addr_counter <= addr_counter + 1;
                        write_cycle <= 1;
                        state <= 2;
                   end else if (rd_en && !read_cycle) begin
                        data_out <= memory[addr_counter];
                        addr_counter <= addr_counter + 1;
                        read_cycle <= 1;
                        state <= 3;
                   end
                2: begin
                        we_n <= 0;
                        write_cycle <= 0;
                        state <= 0;
                   end
                3: begin
                        cas_n <= 0;
                        read_cycle <= 0;
                        state <= 0;
                   end
            endcase
        end
    end
endmodule