module ResetButton (
    input wire KEY0,  
    output reg LED0,  
    output reg LED1,  
    output reg LED2,
    output reg LED3,  
    output reg LED4,
    output reg LED5,
    output reg LED6,
    output reg LED7,
    output reg LED8,
    output reg LED9
);

wire clean_key;   // after debouncing 

debounce db (
    .clk(clk),
    .KEY0(KEY0),
    .clean_key(clean_key)

);

always @(*) begin
   if (KEY0 == 1'b0) begin
        LED0 = 1'b1;
        LED1 = 1'b0;
        LED2 = 1'b0;
        LED3 = 1'b0;
        LED4 = 1'b0;
        LED5 = 1'b0;
        LED6 = 1'b0;
        LED7 = 1'b0;
        LED8 = 1'b0;
        LED9 = 1'b0;
    end else if (KEY0 == 1'b1) begin
        LED0 = 1'b0;
        LED1 = 1'b0;
        LED2 = 1'b0;
        LED3 = 1'b0;
        LED4 = 1'b0;
        LED5 = 1'b0;
        LED6 = 1'b0;
        LED7 = 1'b0;
        LED8 = 1'b0;
    end
end
endmodule