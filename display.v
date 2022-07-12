module display(

input clk,
input [7:0] data,

output [3:0] anodes,
output [7:0] segments,
output reg [2:0] contr
);

wire [3:0]Anodes;

wire [2:0]contr1;
assign anodes = ~Anodes;

clk_div clk_div(.clk(clk), .clk2(clk2));

segment segment(.clk(clk2), .data(data), .anodes(Anodes), .segments(segments), .contr(contr1));

endmodule
