module validator #(
    parameter ADDR_WIDTH = 11
)(
    input  wire                  clk,
    input  wire                  reset_n,

    // DUT signals
    input  wire                  output_ready, // DUT finished
    input  wire [15:0]           dut_output,

    // גישה לזיכרון
    output reg  [ADDR_WIDTH-1:0] address_out,
    output reg                   rd_en,
    output reg                   wr_en,
    input  wire [15:0]           mem_data_out,   // expected data read from on_chip_memory

    // לצורך כתיבת תוצאה חזרה
    // נשתמש ב-data_to_mem, 15:0
    output reg [15:0]           data_to_mem,

    // סיגנל סוף בדיקה ל top-level (אופציונלי)
    output reg                  val_done
);

    //**************************************************************************
    // מצבים
    //**************************************************************************
    typedef enum logic [2:0] {
        VAL_IDLE,
        VAL_WAIT_DUT,
        VAL_READ_EXPECTED,
        VAL_WAIT_DATA,
        VAL_COMPARE,
        VAL_WRITE_RESULT,
        VAL_DONE
    } val_state_t;

    val_state_t state, next_state;

    reg [15:0] compare_result;
    reg [ADDR_WIDTH-1:0] expected_addr; // הכתובת שבה נמצא expected_output

    // הגדר לעצמך איזה כתובת ה-expected נמצאת, או חשב dynamic
    localparam [ADDR_WIDTH-1:0] EXPECTED_BASE_ADDR = 11'd512; // סתם דוגמה

    //**************************************************************************
    // מעבר בין מצבים
    //**************************************************************************
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= VAL_IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            VAL_IDLE: begin
                // נמתין לאיזה טריגר
                next_state = VAL_WAIT_DUT;
            end

            VAL_WAIT_DUT: begin
                // מחכה ל output_ready מה-DUT
                if (output_ready)
                    next_state = VAL_READ_EXPECTED;
            end

            VAL_READ_EXPECTED: begin
                // מפעיל rd_en אל on_chip_memory
                next_state = VAL_WAIT_DATA;
            end

            VAL_WAIT_DATA: begin
                // מחכים מחזור 1 כדי שהmem_data_out יתייצב
                next_state = VAL_COMPARE;
            end

            VAL_COMPARE: begin
                // השוואה
                next_state = VAL_WRITE_RESULT;
            end

            VAL_WRITE_RESULT: begin
                // כותבים Pass/Fail ל on_chip_memory
                next_state = VAL_DONE;
            end

            VAL_DONE: begin
                // אות val_done =1 למחזור, ואז חוזרים ל-IDLE
                next_state = VAL_IDLE;
            end
        endcase
    end

    //**************************************************************************
    // פעולות בכל מצב
    //**************************************************************************
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            address_out    <= {ADDR_WIDTH{1'b0}};
            rd_en          <= 1'b0;
            wr_en          <= 1'b0;
            data_to_mem    <= 16'b0;
            compare_result <= 16'b0;
            val_done       <= 1'b0;

            expected_addr  <= EXPECTED_BASE_ADDR;

        end else begin
            // דיפולטים
            rd_en    <= 1'b0;
            wr_en    <= 1'b0;
            val_done <= 1'b0;

            case (state)
                VAL_IDLE: begin
                    // אפשר לאפס expected_addr בין מחזורים
                    expected_addr <= EXPECTED_BASE_ADDR;
                end

                VAL_WAIT_DUT: begin
                    // כלום, מחכים ל-output_ready
                end

                VAL_READ_EXPECTED: begin
                    // נקבע rd_en=1 + כתובת
                    rd_en      <= 1'b1;
                    address_out <= expected_addr; // נניח ששם נמצא ה-expected
                end

                VAL_WAIT_DATA: begin
                    // במחזור הבא mem_data_out כבר תקף
                end

                VAL_COMPARE: begin
                    // משווה dut_output מול mem_data_out
                    if (dut_output == mem_data_out)
                        compare_result <= 16'h55AA;  // pass
                    else
                        compare_result <= 16'hDEAD;  // fail
                end

                VAL_WRITE_RESULT: begin
                    // כותבים את compare_result ל on_chip_memory בכתובת אחרת?
                    wr_en       <= 1'b1;
                    address_out <= 11'd1000; // סתם דוגמה
                    data_to_mem <= compare_result;
                end

                VAL_DONE: begin
                    val_done <= 1'b1;
                end
            endcase
        end
    end
endmodule
