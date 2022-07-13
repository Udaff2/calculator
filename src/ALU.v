module ALU(

 input [3:0]reg_1_from_sw,
 input [3:0]reg_2_from_sw,
 input [3:0]arif_from_top,
 
 output reg [7:0]ind_1,
 output reg [2:0]control
 
);

reg [10:0]big;

always@(posedge arif_from_top)
 begin
  case(arif_from_top)
   1: begin
	    ind_1 = reg_1_from_sw + reg_2_from_sw;
		 control = 0;
	   end
	2: begin
	    if(reg_1_from_sw < reg_2_from_sw)
		  begin
		   ind_1 = reg_2_from_sw - reg_1_from_sw;
			control = 1;
		  end
		 else
		  begin
		   ind_1 = reg_1_from_sw - reg_2_from_sw;
			control = 0;
		  end
		end
	4: begin
	    ind_1 = reg_1_from_sw * reg_2_from_sw;
		 control = 0;
		end
	8: begin
	    if(reg_2_from_sw == 0)
		  begin
		   control = 2;
		  end
		 else
		  begin
		   big = reg_1_from_sw;
		   ind_1 = (big * 100) / reg_2_from_sw;
			control = 4;
		  end
		end
  endcase
 end
 
endmodule
