module on_chip_memory #(
    parameter ADDR_WIDTH = 7,           // supports up to 128 addresses
    parameter DATA_WIDTH = 16,          // width of each data word
    parameter LOAD_DEPTH = 66           // number of words in the test
)(
    input  wire                     clk,           // system clock
    input  wire                     reset_n,       // active-low reset
    input  wire                     rd_en,         // read enable from generator
    input  wire [ADDR_WIDTH-1:0]    address_in,    // address input from generator
    output reg  [DATA_WIDTH-1:0]    data_out,      // data output to DUT
    output reg                      expected_out   // expected result output
);

    // memory array holding LOAD_DEPTH data words
    reg [DATA_WIDTH-1:0] mem [0:LOAD_DEPTH-1];
    // register to hold the expected validation result
    reg expected_reg;

    // preload test data and expected result for Test 1
	 initial begin
		 // 64 data words + 2 threshold values
		 mem[0]  = 16'b0000000100000010;
		 mem[1]  = 16'b0000001000000010;
		 mem[2]  = 16'b0000001100000010;
		 mem[3]  = 16'b0000010000000010;
		 mem[4]  = 16'b0000010100000010;
		 mem[5]  = 16'b0000011000000010;
		 mem[6]  = 16'b0000011100000010;
		 mem[7]  = 16'b0000100000000010;
		 mem[8]  = 16'b0000100100000010;
		 mem[9]  = 16'b0000101000000010;
		 mem[10] = 16'b0000101100000010;
		 mem[11] = 16'b0000110000000010;
		 mem[12] = 16'b0000110100000010;
		 mem[13] = 16'b0000111000000010;
		 mem[14] = 16'b0000111100000010;
		 mem[15] = 16'b0001000000000010;
		 mem[16] = 16'b0001000100000010;
		 mem[17] = 16'b0001001000000010;
		 mem[18] = 16'b0001001100000010;
		 mem[19] = 16'b0001010000000010;
		 mem[20] = 16'b0001010100000010;
		 mem[21] = 16'b0001011000000010;
		 mem[22] = 16'b0001011100000010;
		 mem[23] = 16'b0001100000000010;
		 mem[24] = 16'b0001100100000010;
		 mem[25] = 16'b0001101000000010;
		 mem[26] = 16'b0001101100000010;
		 mem[27] = 16'b0001110000000010;
		 mem[28] = 16'b0001110100000010;
		 mem[29] = 16'b0001111000000010;
		 mem[30] = 16'b0001111100000010;
		 mem[31] = 16'b0010000000000010;
		 mem[32] = 16'b0010000100000010;
		 mem[33] = 16'b0010001000000010;
		 mem[34] = 16'b0010001100000010;
		 mem[35] = 16'b0010010000000010;
		 mem[36] = 16'b0010010100000010;
		 mem[37] = 16'b0010011000000010;
		 mem[38] = 16'b0010011100000010;
		 mem[39] = 16'b0010100000000010;
		 mem[40] = 16'b0010100100000010;
		 mem[41] = 16'b0010101000000010;
		 mem[42] = 16'b0010101100000010;
		 mem[43] = 16'b0010110000000010;
		 mem[44] = 16'b0010110100000010;
		 mem[45] = 16'b0010111000000010;
		 mem[46] = 16'b0010111100000010;
		 mem[47] = 16'b0011000000000010;
		 mem[48] = 16'b0011000100000010;
		 mem[49] = 16'b0011001000000010;
		 mem[50] = 16'b0011001100000010;
		 mem[51] = 16'b0011010000000010;
		 mem[52] = 16'b0011010100000010;
		 mem[53] = 16'b0011011000000010;
		 mem[54] = 16'b0011011100000010;
		 mem[55] = 16'b0011100000000010;
		 mem[56] = 16'b0011100100000010;
		 mem[57] = 16'b0011101000000010;
		 mem[58] = 16'b0011101100000010;
		 mem[59] = 16'b0011110000000010;
		 mem[60] = 16'b0011110100000010;
		 mem[61] = 16'b0011111000000010;
		 mem[62] = 16'b0011111100000010;
		 mem[63] = 16'b0100000000000010;
		 // threshold values
		 mem[64] = 16'b0000111110100000;
		 mem[65] = 16'b0000000000000000;

		 // expected validation result
		 expected_reg = 1'b1;
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
            expected_out <= expected_reg;    // keep expected output stable
        end
    end

endmodule
