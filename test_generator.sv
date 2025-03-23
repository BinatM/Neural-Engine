module test_generator #(
    parameter ADDR_WIDTH = 11  // 2K entries, for example
)(
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    start,

    // יציאה לאוטובוס הכתובת עבור on_chip_memory
    output reg  [ADDR_WIDTH-1:0]   address_BUS,

    // bidirectional bus [15:0] אם תרצה אותו דו-כיווני ממש,
    // כאן נניח שה generator קורא מה on_chip_memory.data_out (ראו הערה בסוף).
    // לצורך הגשה ל-DUT, נייצר data_out:
    output reg  [15:0]            DATA_BUS,

    // אותות בקרה
    output reg                    rd_en,     // קריאה מה-on_chip
    output reg                    wr_en,     // כתיבה ל-DUT
    output reg                    chip_sel   // בחירת ה-DUT
);

    //**************************************************************************
    // מכונת מצבים בסיסית
    //**************************************************************************
    typedef enum logic [2:0] {
        GEN_IDLE,
        GEN_READ_REQ,   // מפעיל rd_en ל-on_chip_memory
        GEN_WAIT_READ,  // ממתין מחזור לקבלת data
        GEN_WRITE_DUT,  // מפעיל wr_en ל-DUT
        GEN_INC_ADDR,   // מעדכן כתובת / בודק סוף נתונים
        GEN_DONE
    } gen_state_t;

    gen_state_t state, next_state;

    // מונה כתובות
    reg [ADDR_WIDTH-1:0] addr_counter;

    //**************************************************************************
    // תהליך ניהול מצב
    //**************************************************************************
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            state <= GEN_IDLE;
        else
            state <= next_state;
    end

    //**************************************************************************
    // next_state logic
    //**************************************************************************
    always_comb begin
        next_state = state;
        case (state)
            GEN_IDLE: begin
                if (start)
                    next_state = GEN_READ_REQ;
            end

            GEN_READ_REQ: begin
                // מיד אחרי שביקשנו לקרוא
                next_state = GEN_WAIT_READ;
            end

            GEN_WAIT_READ: begin
                // בדוגמה, נניח שאנו מחכים מחזור אחד,
                // ואז נתקדם לכתיבה ל-DUT
                next_state = GEN_WRITE_DUT;
            end

            GEN_WRITE_DUT: begin
                // אחרי כתיבה ל-DUT אפשר לבדוק אם סיימנו
                next_state = GEN_INC_ADDR;
            end

            GEN_INC_ADDR: begin
                // בדוגמה, נניח שנרצה 8 מילים... צריך מנגנון עצירה
                // כאן אפשר לשים תנאי. לצורך פשטות, נעצור אחרי 8 מילים
                // הגבלת debug:
                if (addr_counter == 8 - 1)
                    next_state = GEN_DONE;
                else
                    next_state = GEN_READ_REQ;
            end

            GEN_DONE: begin
                // חוזרים ל-IDLE? או נשארים ב-DONE?
                next_state = GEN_IDLE;
            end
        endcase
    end

    //**************************************************************************
    // פעולות בכל מצב
    //**************************************************************************
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            address_BUS <= '0;
            DATA_BUS    <= 16'b0;

            rd_en       <= 1'b0;
            wr_en       <= 1'b0;
            chip_sel    <= 1'b0;

            addr_counter <= '0;
        end
        else begin
            // ערכי דיפולט בכל מחזור:
            rd_en    <= 1'b0;
            wr_en    <= 1'b0;
            chip_sel <= 1'b0;

            case (state)
                GEN_IDLE: begin
                    address_BUS  <= 0;
                    DATA_BUS     <= 16'b0;
                    addr_counter <= 0;
                end

                GEN_READ_REQ: begin
                    // מבקשים מה-on_chip_memory לקרוא מכתובת addr_counter
                    address_BUS <= addr_counter;
                    rd_en       <= 1'b1;     // enable read
                end

                GEN_WAIT_READ: begin
                    // מחכים מחזור אחד כדי שה-data_out
                    // מה-on_chip_memory יתייצב
                    // (במציאות יכול להיות pipeline של cycle אחד)
                end

                GEN_WRITE_DUT: begin
                    // כעת יש בידינו את הנתונים מה-on_chip_memory
                    // מניחים שאתה תופס אותם ב-top_level ע\"י mem_data_out,
                    // ושם תחליט \"generator data_in = mem_data_out\"

                    // לצורך הדגמה, אפשר להגיד:
                    chip_sel <= 1'b1;  // מפעיל ה-DUT
                    wr_en    <= 1'b1;  // DUT כותב data_in
                    // DATA_BUS נניח מעדכן כאן...
                    // או שאתה יכול לשים DATA_BUS = mem_data_out בחיבור top-level
                end

                GEN_INC_ADDR: begin
                    // מעלה את המונה
                    addr_counter <= addr_counter + 1;
                end

                GEN_DONE: begin
                    // כאן אפשר לנוח, או לחזור ל-IDLE
                end

            endcase
        end
    end

endmodule
