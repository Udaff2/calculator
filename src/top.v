module top(

 input clk,
 input [3:0]in_number,
 input [3:0]arif,
 input [1:0]key,
 
 output reg [3:0]anode,
 output reg [7:0]segment,
 output reg [2:0]led
 );
 
 initial begin
  led = 3'b001;
 end
 
 always@(arif, key)
   begin
    case(key)
	  2'b01: led = 3'b010;
	  2'b10: led = 3'b101;
	 endcase
	 if(arif > 0)
	  begin
	   led = 3'b001;
	  end
   end

//always@(posedge arif)
// begin
//  led = 3'b001;
// end
//
//always@(posedge key)
// case(key)
//  2'b01: led = 3'b010;
//  2'b10: led = 3'b101;
// endcase
 
sw sw(.in_number_from_top(in_number), .key_from_top(key), .reg_1(reg_1), .reg_2(reg_2), .ind(ind));
		

ALU ALU(.reg_1_from_sw(reg_1),   .reg_2_from_sw(reg_2), .arif_from_top(arif), 
        .ind_1(ind_1),           .control(control));

Seg Seg(.Clk(clk), .ind_from_sw(ind), .ind_from_ALU(ind_1), .c_from_ALU(control), .keys(key), .arifs(arif), .anodes(anodes), .segments(segments));

always@(clk)
 begin
  anode = anodes;
  segment = segments;
 end
 
endmodule
 