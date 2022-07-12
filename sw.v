module sw(

   input [3:0] in_number,
   input k_1,

   output reg [3:0] reg_1,
   output reg [2:0] led,
   output [2:0] contr
);

always@(posedge k_1) begin
   reg_1 = in_number;
   led = 3'b010;
   //contr = 0;
end

//display display(.clk(clk), .data(reg_1), .anodes(anodes), .segments(segments), .contr(contr));
display display(.clk(clk), .data(reg_1), .anodes(anodes), .segments(segments), .contr(local_contr));
endmodule
