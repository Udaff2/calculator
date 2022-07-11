module bin_to_seg(

input [7:0]data, 
input [3:0]anodes,
output reg [6:0]segments

);

integer data1 = 0;
wire first_digit = data % 10;
wire second_digit = ((data - (data % 10)) % 100) / 10;
wire third_digit = ((data - (data % 100)) % 1000) / 100;
wire fourth_digit = ((data - (data % 1000)) % 10000) / 1000;


always@(anodes) 
   begin
     case (anodes)
       4'b1110: data1 = (data%10);
       4'b1101: data1 = ((data - (data % 10)) % 100) / 10;
       4'b1011: data1 = ((data - (data % 100)) % 1000) / 100;
       4'b0111: data1 = ((data - (data % 1000)) % 10000) / 1000;
     endcase
    case (data1)
     4'd0: segments = 7'b1111110;
     4'd1: segments = 7'b0110000;
     4'd2: segments = 7'b1101101;
     4'd3: segments = 7'b1111001;
     4'd4: segments = 7'b0110011;
     4'd5: segments = 7'b1011011;
     4'd6: segments = 7'b0011110;
     4'd7: segments = 7'b1110000;
     4'd8: segments = 7'b1111111;
     4'd9: segments = 7'b1110011;
     default: segments = 7'b0000000;
    endcase
   end

endmodule
