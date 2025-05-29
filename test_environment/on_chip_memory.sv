module on_chip_memory #(
    parameter ADDR_WIDTH = 16,           // supports up to 33000 addresses
    parameter DATA_WIDTH = 16,           // width of each data word
    parameter LOAD_DEPTH = 33000,        // number of words in all test
parameter TOTAL_TESTS = 500          // number of test in total
)(
    input  wire                     clk,           // system clock
    input  wire                     reset_n,       // active-low reset
    input  wire                     rd_en,         // read enable from generator
    input  wire [ADDR_WIDTH-1:0]    address_in,    // address input from generator
input  reg  [8:0]               test_count,    // represnts the current test number out of 500
    output reg  [DATA_WIDTH-1:0]    data_out,      // data output to DUT
    output reg                      expected_out   // expected result output
);

    // memory array holding LOAD_DEPTH data words
    reg [DATA_WIDTH-1:0] mem [0:LOAD_DEPTH-1];
    // memory to hold the expected validation results
    reg expected_mem[0:TOTAL_TESTS-1];

    // preload test data and expected result for Test 1
initial begin
// 64 data words + 2 threshold values
   mem[0]  = 16'b0000000100000010;
mem[1]  = 16'b0000001000000010;
    //....
mem[63] = 16'b0100000000000010;
// threshold values
mem[64] = 16'b0000111110100000;
mem[65] = 16'b0000000000000000;

//...
mem[LOAD_DEPTH-1] = ...


// expected validation result
 expected_mem[0]   = 1'b1;
        expected_mem[1]   = 1'b0;
        // ...
        expected_mem[499] = 1'b1;
end


    // on rd_en, output the selected memory word and the expected result
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out     <= {DATA_WIDTH{1'b0}};
            expected_out <= 1'b0;
        end else begin
            if (rd_en) begin
                data_out <= mem[address_in];  // provide data word
            end
             // index into expected_mem using test_count
            expected_out <= expected_mem[test_count];
        end
    end

endmodule