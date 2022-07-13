module sw(

 input [3:0]in_number_from_top,
 input [1:0]key_from_top,
 
 output reg [3:0]reg_1,
 output reg [3:0]reg_2,
 output reg [7:0]ind
);

always@(posedge key_from_top)
 begin
  case(key_from_top)
   1: begin
	    reg_1 = in_number_from_top;
       ind = in_number_from_top;
		end
	2: begin
	    reg_2 = in_number_from_top;
	    ind = in_number_from_top;
		end
  endcase
 end
 
endmodule
