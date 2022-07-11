module segment(

input clk, 
input [7:0]data,

output [3:0]anodes, 
output [6:0]segments

);

reg [1:0]i = 0;
assign anodes = (4'b1 << i);

always@(posedge clk) begin 
   i <= i + 2'b1;
end


bin_to_seg bin_to_seg(.data(data), .segments(segments), .anodes(anodes));

endmodule
