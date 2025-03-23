module control_unit #(
    parameter LOAD_DEPTH = 256  // כמה מילים לטעון מה-SDRAM
)(
    input  wire clk,
    input  wire reset_n,

    // מופעל פעם אחת כדי להתחיל את התהליך
    input  wire start,

    // אותות לשליטה בתהליך הטעינה
    output reg  sdram_rd_en,
    output reg  mem_wr_en,
    output reg [9:0] mem_address,
    input  wire [15:0] sdram_dout, // מידע שמגיע מה-sdram_controller

    // אותות לשליטה בתהליך ה-RUN
    output reg  wr_en,
    output reg  rd_en,
    output reg  output_ready,

    // אות התחלת ריצה חיצוני (למשל ל-generator)
    output reg  start_run
);

    // מצבים בסיסיים
    typedef enum logic [2:0] {
        ST_IDLE = 3'd0,
        ST_LOAD = 3'd1,
        ST_RUN  = 3'd2,
        ST_DONE = 3'd3
    } state_t;

    state_t state, next_state;

    // מונה לטעינה
    reg [9:0] load_counter;

    //------------------------------------------------------------
    // מכונת מצבים
    //------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= ST_IDLE;
        else
            state <= next_state;
    end

    // מעבר בין מצבים
    always_comb begin
        next_state = state;
        case (state)
            ST_IDLE: begin
                if (start)
                    next_state = ST_LOAD;
            end

            ST_LOAD: begin
                // נעצור אחרי שהעמסנו LOAD_DEPTH מילים
                if (load_counter == (LOAD_DEPTH-1))
                    next_state = ST_RUN;
            end

            ST_RUN: begin
                // לצורך פשטות, אחרי X זמן אפשר לעבור ל-ST_DONE
                // או ממתינים לסיגנל "test_done" (לא מופיע כאן)
                // next_state = ST_DONE;
            end

            ST_DONE: begin
                // חוזרים ל-ST_IDLE לצורך restart
                next_state = ST_IDLE;
            end
        endcase
    end

    //------------------------------------------------------------
    // לוגיקת פעולות לכל מצב
    //------------------------------------------------------------
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
            // ברירות מחדל בכל מחזור
            sdram_rd_en   <= 1'b0;
            mem_wr_en     <= 1'b0;
            wr_en         <= 1'b0;
            rd_en         <= 1'b0;
            output_ready  <= 1'b0;
            start_run     <= 1'b0; // יהיה 1 רק במחזור שרוצים להתחיל RUN

            case (state)
                ST_IDLE: begin
                    load_counter <= 10'd0;
                end

                ST_LOAD: begin
                    // קריאה מ-SDRAM
                    sdram_rd_en  <= 1'b1;
                    // כתיבה ל-on_chip_memory
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

            // הפעלה חד-מחזורית של start_run כאשר נכנסים ל-ST_RUN
            if (state == ST_LOAD && next_state == ST_RUN)
                start_run <= 1'b1;
        end
    end

endmodule
