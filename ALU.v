module ALU(

   input reg_1,
   input reg_2,
   input p_key,
   input m_key,
   input um_key,
   input del_key,

   output reg [7:0] final,
   output reg [2:0] contr,
   output reg [2:0] led
);

wire local_contr;
initial begin
 contr = 0;
end

always@(negedge p_key) begin
      final <= reg_1 + reg_2;
      led <= 3'b100;
      contr <= 0;
end

always@(negedge m_key) begin
   if(reg_1 < reg_2) begin
      final <= reg_2 - reg_1;
      contr <= 3'b001;
      led <= 3'b100;
   end
   else 
      begin 
       final <= reg_1 - reg_2;
       contr <= 0;
       led <= 3'b100;
      end
end

always@(negedge um_key) begin
      final <= reg_1 * reg_2;
      led <= 3'b100; 
      contr <= 0;
end

always@(negedge del_key) begin
   if(reg_2 == 0) begin
      contr <= 3'b010;
      led <= 3'b100;
   end
   else 
    begin
     final <= (reg_1 * 100) / reg_2;
     contr <= 3'b100;
     led <= 3'b100;
    end
end

//display display(.clk(clk), .data(final), .anodes(anodes), .segments(segments), .contr(contr));
display display(.clk(clk), .data(final), .anodes(anodes), .segments(segments), .contr(local_contr));

endmodule
