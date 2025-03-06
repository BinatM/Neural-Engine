module debounce (
    input wire clk,
    input wire KEY0,
    output reg clean_key
);

reg [19:0] count;
reg stable_key;

always @(posedge clk) begin
    if (KEY0 == stable_key) begin
        if (count <1_000_000) // assuming 50MHz clock frequancy
            count <= count + 1;
        else
            clean_key <= stable_key;
    end else begin
        count <= 0;
        stable_key <= KEY0;
    end
end

endmodule