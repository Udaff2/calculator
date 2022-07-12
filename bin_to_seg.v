module bin_to_seg(

input [7:0]data, 
input [3:0]anodes,
output reg [7:0]segments,
output reg [2:0] contr
);

integer data1 = 0;

always@(anodes) 
   begin
    if(contr == 3'b000) begin
        case (anodes)
          4'b0001: data1 = (data%10);
          4'b0010: data1 = ((data - (data % 10)) % 100) / 10;
          4'b0100: data1 = ((data - (data % 100)) % 1000) / 100;
          4'b1000: data1 = ((data - (data % 1000)) % 10000) / 1000;
        endcase
        case (data1)
				4'd0: segments = 8'b11000000;
				4'd1: segments = 8'b11111100;
				4'd2: segments = 8'b10100100;
				4'd3: segments = 8'b10110000;
				4'd4: segments = 8'b10011001;
				4'd5: segments = 8'b10010010;
				4'd6: segments = 8'b10000010;
				4'd7: segments = 8'b11111000;
				4'd8: segments = 8'b10000000;
				4'd9: segments = 8'b10010000;
				default: segments = 8'b11111111;
        endcase
      end
     else if(contr == 3'b001) begin
        case (anodes)
          4'b0001: data1 = (data%10);
          4'b0010: data1 = ((data - (data % 10)) % 100) / 10;
          4'b0100: data1 = ((data - (data % 100)) % 1000) / 100;
          4'b1000: data1 = 10;
        endcase
        case (data1)
				4'd0: segments = 8'b11000000;
				4'd1: segments = 8'b11111100;
				4'd2: segments = 8'b10100100;
				4'd3: segments = 8'b10110000;
				4'd4: segments = 8'b10011001;
				4'd5: segments = 8'b10010010;
				4'd6: segments = 8'b10000010;
				4'd7: segments = 8'b11111000;
				4'd8: segments = 8'b10000000;
				4'd9: segments = 8'b10010000;
				4'd10: segments = 8'b10111111;
				default: segments = 8'b11111111;
        endcase
      end
     else if(contr == 3'b010) begin
        case (anodes)
          4'b0001: data1 = 11;
          4'b0010: data1 = 0;
          4'b0100: data1 = 0;
          4'b1000: data1 = 0;
        endcase
        case (data1)
				4'd0: segments = 8'b11000000;
				4'd11: segments = 8'b10000110;
				default: segments = 8'b11111111;
        endcase
      end
      else if(contr == 3'b100) begin
        case (anodes)
          4'b0001: data1 = (data%10);
          4'b0010: data1 = ((data - (data % 10)) % 100) / 10;
          4'b0100: data1 = ((data - (data % 100)) % 1000) / 100;
          4'b1000: data1 = ((data - (data % 1000)) % 10000) / 1000;
        endcase
        if (anodes == 4'b0100)
         begin
          case (data1)
				4'd0: segments = 8'b11000000;
				4'd1: segments = 8'b11111100;
				4'd2: segments = 8'b10100100;
				4'd3: segments = 8'b10110000;
				4'd4: segments = 8'b10011001;
				4'd5: segments = 8'b10010010;
				4'd6: segments = 8'b10000010;
				4'd7: segments = 8'b11111000;
				4'd8: segments = 8'b10000000;
				4'd9: segments = 8'b10010000;
				default: segments = 8'b11111111;
          endcase
         end
        else begin
         case (data1)
				4'd0: segments = 8'b11000000;
				4'd1: segments = 8'b11111100;
				4'd2: segments = 8'b10100100;
				4'd3: segments = 8'b10110000;
				4'd4: segments = 8'b10011001;
				4'd5: segments = 8'b10010010;
				4'd6: segments = 8'b10000010;
				4'd7: segments = 8'b11111000;
				4'd8: segments = 8'b10000000;
				4'd9: segments = 8'b10010000;
				default: segments = 8'b11111111;
         endcase
        end
      end
   end

endmodule

