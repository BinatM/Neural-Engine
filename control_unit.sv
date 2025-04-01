module control_unit #(
    parameter LOAD_DEPTH = 256  // Number of words to load from SDRAM
)(
    input  wire clk,
    input  wire reset_n,

    // Activated once to start the process
    input  wire start,

    // Load process control signals
    output reg  sdram_rd_en,
    output reg  mem_wr_en,
    output reg [9:0] mem_address,
    input  wire [15:0] sdram_dout, // Data from sdram_controller

    // Run process control signals
    output reg  wr_en,
    output reg  rd_en,
    output reg  output_ready,

    // External run trigger (e.g., for generator)
    output reg  start_run
);

    // State definitions
    typedef enum logic [2:0] {
        ST_IDLE = 3'd0,
        ST_LOAD = 3'd1,
        ST_RUN  = 3'd2,
        ST_DONE = 3'd3
    } state_t;

    state_t state, next_state;

    // Load counter
    reg [9:0] load_counter;

    // State transition
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= ST_IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            ST_IDLE: begin
                if (start)
                    next_state = ST_LOAD;
            end

            ST_LOAD: begin
                // Transition after loading LOAD_DEPTH words
                if (load_counter == (LOAD_DEPTH-1))
                    next_state = ST_RUN;
            end

            ST_RUN: begin
                // Can transition to ST_DONE later
                // next_state = ST_DONE;
            end

            ST_DONE: begin
                // Return to ST_IDLE
                next_state = ST_IDLE;
            end
        endcase
    end

    // State actions
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            load_counter <= 10'd0;

            sdram_rd_en   <= 1'b0;
            mem_wr_en     <= 1'b0;
            mem_address   <= 10'd0;

            wr_en         <= 1'b0;
            rd_en         <= 1'b0;
            output_ready  <= 1'b0;
            start_run     <= 1'b0;

        end else begin
            // Default values each cycle
            sdram_rd_en   <= 1'b0;
            mem_wr_en     <= 1'b0;
            wr_en         <= 1'b0;
            rd_en         <= 1'b0;
            output_ready  <= 1'b0;
            start_run     <= 1'b0;

            case (state)
                ST_IDLE: begin
                    load_counter <= 10'd0;
                end

                ST_LOAD: begin
                    sdram_rd_en  <= 1'b1;
                    mem_wr_en    <= 1'b1;
                    mem_address  <= load_counter;

                    load_counter <= load_counter + 1;
                end

                ST_RUN: begin
                    wr_en        <= 1'b1;
                    rd_en        <= 1'b1;
                    output_ready <= 1'b1;
                end

                ST_DONE: begin
                    output_ready <= 1'b0;
                end
            endcase

            // Single-cycle pulse for start_run on transition to ST_RUN
            if (state == ST_LOAD && next_state == ST_RUN)
                start_run <= 1'b1;
        end
    end

endmodule
