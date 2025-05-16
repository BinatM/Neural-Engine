module control_unit #(
    parameter LOAD_DEPTH = 68
)(
    input  wire         clk,
    input  wire         reset_n,
    input  wire         start,
    input  wire         val_done,

    output reg          sdram_rd_en,
    output reg          sdram_wr_en,
    output reg [15:0]   sdram_data_out,
    output reg [23:0]   sdram_address,
    input  wire [15:0]  sdram_dout,
    input  wire         sdram_ready,

    output reg [9:0]    mem_address,
    output reg          mem_wr_en,

    output reg          start_run,
    output reg          led_done,       // output for LED9

    input  wire [15:0]  val_result_bits
);

    localparam [15:0] HEADER_WORD = 16'hABCD;

    typedef enum logic [2:0] {
        ST_IDLE         = 3'd0,
        ST_READ_CNT     = 3'd1,
        ST_HEADER       = 3'd2,
        ST_REQ_DATA     = 3'd3,
        ST_WAIT_RDY     = 3'd4,
        ST_PROCESS      = 3'd5,
        ST_RUN          = 3'd6,
        ST_SAVE_RESULT  = 3'd7
    } state_t;

    state_t state;
    reg [15:0] test_count;
    reg [8:0]  word_count;
    reg [23:0] sdram_addr_next;
    reg [15:0] current_word;
    reg [23:0] sdram_results_start_addr;
    reg [23:0] sdram_write_addr;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state                  <= ST_IDLE;
            sdram_rd_en            <= 1'b0;
            sdram_wr_en            <= 1'b0;
            sdram_data_out         <= 16'd0;
            sdram_address          <= 24'd0;
            sdram_addr_next        <= 24'd0;
            sdram_results_start_addr <= 24'd0;
            sdram_write_addr       <= 24'd0;
            mem_address            <= 10'd0;
            start_run              <= 1'b0;
            led_done               <= 1'b0;
            word_count             <= 9'd0;
            current_word           <= 16'd0;
        end else begin
            // Default values every cycle to avoid latches
            sdram_rd_en         <= 1'b0;
            sdram_wr_en         <= 1'b0;
            start_run           <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        sdram_addr_next    <= 24'd0;
                        sdram_write_addr   <= 24'd0;
                        led_done           <= 1'b0;
                        state              <= ST_REQ_DATA;
                    end
                end

                ST_REQ_DATA: begin
                    sdram_rd_en     <= 1'b1;
                    sdram_address   <= sdram_addr_next;
                    state           <= ST_WAIT_RDY;
                end

                ST_WAIT_RDY: begin
                    if (sdram_ready) begin
                        current_word     <= sdram_dout;
                        sdram_addr_next  <= sdram_addr_next + 1;

                        if (sdram_addr_next == 0)
                            state <= ST_READ_CNT;
                        else if (word_count == 0 && sdram_dout == HEADER_WORD)
                            state <= ST_HEADER;
                        else
                            state <= ST_PROCESS;
                    end
                end

                ST_READ_CNT: begin
                    test_count               <= current_word;
                    word_count              <= 9'd0;
                    sdram_results_start_addr <= 1 + current_word * LOAD_DEPTH;
 sdram_write_addr         <= 1 + current_word * LOAD_DEPTH;

                    state                   <= ST_REQ_DATA;
                end

                ST_HEADER: begin
                    word_count   <= 9'd0;
                    mem_address  <= 10'd0;
                    state        <= ST_REQ_DATA;
                end

                ST_PROCESS: begin
                    if (current_word != HEADER_WORD) begin
                        if (word_count < 66) begin
                            mem_wr_en     <= 1'b1;
                            mem_address   <= word_count;
                        end
                        word_count <= word_count + 1;
                    end
                    if (word_count == 66)
                        state <= ST_RUN;
                    else
                        state <= ST_REQ_DATA;
                end

                ST_RUN: begin
                    start_run    <= 1'b1;
                    if (val_done)
                    state <= ST_SAVE_RESULT;
                    end

                ST_SAVE_RESULT: begin
                    sdram_wr_en     <= 1'b1;
                    sdram_data_out  <= val_result_bits;
                    sdram_address   <= sdram_write_addr;
                    sdram_write_addr <= sdram_write_addr + 1;
                    test_count      <= test_count - 1;
                    if (test_count == 1) begin
                        led_done <= 1'b1;
                        state    <= ST_IDLE;
                    end else begin
                        word_count  <= 9'd0;
                        mem_address <= 10'd0;
                        state       <= ST_REQ_DATA;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule