module sdram_controller(
    input  wire         clk,
    input  wire         reset_n,

    input  wire         wr_en,
    input  wire         rd_en,
    input  wire [15:0]  data_in,
    output reg  [15:0]  data_out,
    input  wire [23:0]  address,
    output reg          ready,

    // Physical SDRAM pins
    output reg  [12:0]  addr,
    output reg  [1:0]   ba,
    output reg          cas_n,
    output reg          ras_n,
    output reg          we_n,
    output reg          clk_out,
    output reg          cke,
    output reg          cs_n,
    inout  wire [15:0]  dq,
    output reg          ldqm,
    output reg          udqm
);

    // Just a local memory model for demonstration
    reg [15:0] memory [0:8191];

    reg [15:0] dq_out;
    reg        dq_drive_en;
    assign dq = dq_drive_en ? dq_out : 16'bz;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 16'd0;
            addr     <= 13'd0;
            ba       <= 2'd0;
            cas_n    <= 1'b1;
            ras_n    <= 1'b1;
            we_n     <= 1'b1;
            clk_out  <= 1'b0;
            cke      <= 1'b0;
            cs_n     <= 1'b1;
            ldqm     <= 1'b0;
            udqm     <= 1'b0;
            ready    <= 1'b0;
            dq_out   <= 16'd0;
            dq_drive_en <= 1'b0;
        end else begin
            // default
            clk_out     <= clk;
            cke         <= 1'b1;
            cs_n        <= 1'b0;
            ldqm        <= 1'b0;
            udqm        <= 1'b0;
            cas_n       <= 1'b1;
            ras_n       <= 1'b1;
            we_n        <= 1'b1;
            dq_drive_en <= 1'b0;
            ready       <= 1'b0;

            if (wr_en) begin
                // write
                memory[address[12:0]] <= data_in;
                // pretend it's done
                ready <= 1'b1;
            end else if (rd_en) begin
                // read
                data_out     <= memory[address[12:0]];
                dq_out       <= memory[address[12:0]];
                dq_drive_en  <= 1'b1;
                ready        <= 1'b1;

                // set RAS/CAS for example
                cas_n <= 1'b0;
                ras_n <= 1'b0;
                we_n  <= 1'b1;
            end
        end
    end

endmodule
