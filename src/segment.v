module segment(
  input Clk,
  input [3:0]ind_from_sw,
  input [10:0]ind_from_ALU,
  input [2:0]c_from_ALU,
  input [1:0]keys,
  input [3:0]arifs,

  output [3:0]anodes,
  output reg [7:0]segments
);

  reg [10:0]data;
  reg [2:0]contr;

  always@ (posedge Clk)
    begin
      if(arifs == 15)
        begin
          data <= ind_from_sw;
          contr <= 0;
        end
      else if(arifs <15)
        begin
          data <= ind_from_ALU;
          contr <= c_from_ALU;
        end
    end

  reg [11:00]cnt = 0;
  reg clk2;

  always@ (posedge Clk)
    begin
      cnt <= cnt + 12'b1;
      clk2 <= cnt[11];
    end

  reg [1:0]i = 0;
  assign anodes = (4'b1111 - (4'b0001 << i));
  always@ (posedge clk2)
    begin
      i <= i + 2'b1;
    end

  reg [3:0]data1 = 0;

  always@ (posedge Clk)
    begin
      if(contr == 0) begin
        case (anodes)
          14: data1 <= (data%10);
          13: data1 <= ((data - (data % 10)) % 100) / 10;
          11: data1 <= ((data - (data % 100)) % 1000) / 100;
          7: data1 <= ((data - (data % 1000)) % 10000) / 1000;
        endcase
        case (data1)
          4'd0: segments <= 8'b11000000;
          4'd1: segments <= 8'b11111001;
          4'd2: segments <= 8'b10100100;
          4'd3: segments <= 8'b10110000;
          4'd4: segments <= 8'b10011001;
          4'd5: segments <= 8'b10010010;
          4'd6: segments <= 8'b10000010;
          4'd7: segments <= 8'b11111000;
          4'd8: segments <= 8'b10000000;
          4'd9: segments <= 8'b10010000;
          default segments <= 8'b11000000;
        endcase
      end

      else if(contr == 1) begin
        case (anodes)
          14: data1 <= (data%10);
          13: data1 <= ((data - (data % 10)) % 100) / 10;
          11: data1 <= ((data - (data % 100)) % 1000) / 100;
          7: data1 <= 10;
        endcase
        case (data1)
          4'd0: segments <= 8'b11000000;
          4'd1: segments <= 8'b11111001;
          4'd2: segments <= 8'b10100100;
          4'd3: segments <= 8'b10110000;
          4'd4: segments <= 8'b10011001;
          4'd5: segments <= 8'b10010010;
          4'd6: segments <= 8'b10000010;
          4'd7: segments <= 8'b11111000;
          4'd8: segments <= 8'b10000000;
          4'd9: segments <= 8'b10010000;
          4'd10: segments <= 8'b10111111;
          default segments <= 8'b11000000;
        endcase
      end

      else if(contr == 2) begin
        case (anodes)
          14: data1 <= 11;
          13: data1 <= 0;
          11: data1 <= 0;
          7: data1 <= 0;
        endcase
        case (data1)
          4'd0: segments <= 8'b11000000;
          4'd11: segments <= 8'b10000110;
          default segments <= 8'b11000000;
        endcase
      end

      else if(contr == 4) begin
        case (anodes)
          14: data1 <= (data%10);
          13: data1 <= ((data - (data % 10)) % 100) / 10;
          11: data1 <= ((data - (data % 100)) % 1000) / 100;
          7: data1 <= ((data - (data % 1000)) % 10000) / 1000;
        endcase
        if (anodes == 11)
          begin
            case (data1)
              4'd0: segments <= 8'b11000000;
              4'd1: segments <= 8'b11111001;
              4'd2: segments <= 8'b10100100;
              4'd3: segments <= 8'b10110000;
              4'd4: segments <= 8'b10011001;
              4'd5: segments <= 8'b10010010;
              4'd6: segments <= 8'b10000010;
              4'd7: segments <= 8'b11111000;
              4'd8: segments <= 8'b10000000;
              4'd9: segments <= 8'b10010000;
              default segments <= 8'b11000000;
            endcase
          end
        else
          begin
            case (data1)
              4'd0: segments <= 8'b11000000;
              4'd1: segments <= 8'b11111001;
              4'd2: segments <= 8'b10100100;
              4'd3: segments <= 8'b10110000;
              4'd4: segments <= 8'b10011001;
              4'd5: segments <= 8'b10010010;
              4'd6: segments <= 8'b10000010;
              4'd7: segments <= 8'b11111000;
              4'd8: segments <= 8'b10000000;
              4'd9: segments <= 8'b10010000;
              default segments <= 8'b11000000;
            endcase
          end
      end
    end

endmodule
