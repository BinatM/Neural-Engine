module on_chip_memory(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        wr_en,
    input  wire        rd_en,
    input  wire [15:0] data_in,
    output reg  [15:0] data_out,
    input  wire        multi_cycle_mode,
    input  wire [1:0]  cycle_count
);

    reg [15:0] memory [0:1023]; // 1K x 16-bit memory
    reg [9:0]  addr_counter;
    reg [1:0]  cycle_cntr;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            addr_counter <= 0;
            cycle_cntr   <= 0;
            data_out     <= 0;
        end
        else begin
            if (wr_en) begin
                memory[addr_counter] <= data_in;
                addr_counter         <= addr_counter + 1;
            end

            if (rd_en) begin
                // multi-cycle
                if (multi_cycle_mode) begin
                    if (cycle_cntr < cycle_count) begin
                        cycle_cntr <= cycle_cntr + 1;
                    end
                    else begin
                        data_out     <= memory[addr_counter];
                        addr_counter <= addr_counter + 1;
                        cycle_cntr   <= 0;
                    end
                end
                else begin
                    data_out     <= memory[addr_counter];
                    addr_counter <= addr_counter + 1;
                end
            end
        end
    end

endmodule
