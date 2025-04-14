module on_chip_memory(
    input  wire         clk,
    input  wire         reset_n,
    input  wire         wr_en,
    input  wire         rd_en,
    input  wire [15:0]  data_in,
    output reg  [15:0]  data_out,

    input  wire         multi_cycle_mode,
    input  wire [1:0]   cycle_count,

    input  wire [9:0]   address_in,
    input  wire         use_external_addr
);

    reg [15:0] memory [0:1023]; // 1K x 16-bit
    reg [9:0]  addr_counter;
    reg [1:0]  cycle_cntr;

    wire [9:0] active_addr = use_external_addr ? address_in : addr_counter;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            addr_counter <= 10'b0;
            cycle_cntr   <= 2'b0;
            data_out     <= 16'b0;
        end else begin
            // Default no read or write
            if (wr_en) begin
                memory[active_addr] <= data_in;
                if (!use_external_addr)
                    addr_counter <= addr_counter + 1;
            end

            if (rd_en) begin
                if (multi_cycle_mode) begin
                    if (cycle_cntr < cycle_count)
                        cycle_cntr <= cycle_cntr + 1;
                    else begin
                        data_out <= memory[active_addr];
                        if (!use_external_addr)
                            addr_counter <= addr_counter + 1;
                        cycle_cntr <= 0;
                    end
                end else begin
                    data_out <= memory[active_addr];
                    if (!use_external_addr)
                        addr_counter <= addr_counter + 1;
                end
            end
        end
    end

endmodule

