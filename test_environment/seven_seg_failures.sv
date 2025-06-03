module seven_seg_failures (
    input  wire        clk,          // system clock
    input  wire        reset_n,      // active-low reset
    input  wire        val_done,     // goes high for one cycle when a test completes
    input  wire        result,       // 1 = pass, 0 = fail
    input  wire [8:0]  test_count,   // index of the test that just completed
    input  wire        stop_reset,

    // display digits for first failure (ones, tens, hundreds)
    output reg [6:0]   seg1_0,       // ones digit on first 7-seg
    output reg [6:0]   seg1_1,       // tens digit on first 7-seg
    output reg [6:0]   seg1_2,       // hundreds digit on first 7-seg

    // display digits for second failure
    output reg [6:0]   seg2_0,       // ones digit on second 7-seg
    output reg [6:0]   seg2_1,       // tens digit on second 7-seg
    output reg [6:0]   seg2_2,       // hundreds digit on second 7-seg

    output reg         stop_tests    // high once two failures recorded
);

    // how many failures seen so far (0, 1 or 2)
    reg [1:0] fails;

    // store the test index of failures (not used for display logic but kept for reference)
    reg [8:0] first_fail;
    reg [8:0] second_fail;

    // extra register to detect rising edge of val_done
    reg prev_val_done;

    // 7-segment decoder: maps 0–9 to segment pattern
    function [6:0] decode7;
        input [3:0] d;
        begin
            case (d)
                4'd0: decode7 = 7'b1000000;
                4'd1: decode7 = 7'b1111001;
                4'd2: decode7 = 7'b0100100;
                4'd3: decode7 = 7'b0110000;
                4'd4: decode7 = 7'b0011001;
                4'd5: decode7 = 7'b0010010;
                4'd6: decode7 = 7'b0000010;
                4'd7: decode7 = 7'b1111000;
                4'd8: decode7 = 7'b0000000;
                4'd9: decode7 = 7'b0010000;
                default: decode7 = 7'b1111111; // all segments off
            endcase
        end
    endfunction

    // extract decimal digit: place=0→ones, 1→tens, 2→hundreds
    function [3:0] digit;
        input [8:0] value;
        input integer place;
        integer tmp;
        begin
            tmp = value;
            case (place)
                0: digit = tmp % 10;
                1: digit = (tmp / 10) % 10;
                2: digit = (tmp / 100) % 10;
                default: digit = 4'd0;
            endcase
        end
    endfunction

    // main logic: on second failure, stop_tests goes high and both displays freeze
    always_ff @(posedge clk or negedge reset_n or posedge stop_reset) begin
        if (!reset_n || stop_reset) begin
            // reset all registers and clear previous val_done
            fails         <= 2'd0;
            first_fail    <= 9'd0;
            second_fail   <= 9'd0;
            seg1_0        <= 7'b1111111;
            seg1_1        <= 7'b1111111;
            seg1_2        <= 7'b1111111;
            seg2_0        <= 7'b1111111;
            seg2_1        <= 7'b1111111;
            seg2_2        <= 7'b1111111;
            stop_tests    <= 1'b0;
            prev_val_done <= 1'b0;  // clear the edge detector
        end else begin
            // capture previous val_done for rising-edge detection
            prev_val_done <= val_done;

            // only register failure on the rising edge of val_done and when result is 0
            if ((val_done && !prev_val_done) && !result && (fails < 2)) begin
                if (fails == 2'd0) begin
                    // record first failure using the current test_count
                    first_fail <= test_count;
                    seg1_0     <= decode7(digit(test_count, 0));
                    seg1_1     <= decode7(digit(test_count, 1));
                    seg1_2     <= decode7(digit(test_count, 2));
                    fails      <= 2'd1;
                end else if (fails == 2'd1) begin
                    // record second failure and stop further tests
                    second_fail <= test_count;
                    seg2_0      <= decode7(digit(test_count, 0));
                    seg2_1      <= decode7(digit(test_count, 1));
                    seg2_2      <= decode7(digit(test_count, 2));
                    fails       <= 2'd2;
                    stop_tests  <= 1'b1;
                end
            end
        end
    end

endmodule
