module sw2(

   input [3:0] in_number,
   input k_2,

   output reg [3:0] reg_2,
   output reg [2:0] led,
   output reg [2:0] contr
);

initial begin
   reg_2 = 0;
   contr = 0;
end

always@(posedge k_2) begin
   reg_2 = in_number;
   led = 3'b100;
   contr = 0;
end

//display display(.clk(clk), .data(reg_2), .anodes(anodes), .segments(segments), .contr(contr));
display display(.clk(clk), .data(reg_2), .anodes(anodes), .segments(segments), .contr(local_contr));

endmodule
