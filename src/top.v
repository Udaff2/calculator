module top(

input clk,

output [3:0]anodes,
output [6:0]segments
);

reg [7:0] d = 225;

clk_div clk_div(.clk(clk), .clk2(clk2));

segment segment(.clk(clk2), .data(d), .anodes(anodes), .segments(segments));

endmodule
