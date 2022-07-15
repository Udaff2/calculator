module segment #(
  parameter integer IND_SW  = 4,
  parameter integer IND_ALU = 11,
  parameter integer C_ALU   = 3,
  parameter integer ARIFS   = 4,
  parameter integer ANODES  = 4,
  parameter integer SEG     = 8,
  parameter integer DATA    = 11,
  parameter integer CONTR   = 3,
  parameter integer CNT     = 12
)(
  input clk,
  input [ IND_SW - 1   : 00 ] ind_from_sw,
  input [ IND_ALU - 1  : 00 ] ind_from_ALU,
  input [ C_ALU - 1    : 00 ] c_from_ALU,
  input [ ARIFS - 1    : 00 ] arifs,

  output [ ANODES - 1  : 00 ] anodes,
  output reg [ SEG - 1 : 00 ] segments
);

  reg [ DATA - 1  : 00 ] data;
  reg [ CONTR - 1 : 00 ] contr;


  parameter integer NUMBER_TO_SEG  = 4;
  parameter integer ANODE_1        = 4'b1110;
  parameter integer ANODE_2        = 4'b1101;
  parameter integer ANODE_3        = 4'b1011;
  parameter integer ANODE_4        = 4'b0111;
  parameter DIG_0                  = 7'b1000000;
  parameter DIG_1                  = 7'b1111001;
  parameter DIG_2                  = 7'b0100100;
  parameter DIG_3                  = 7'b0110000;
  parameter DIG_4                  = 7'b0011001;
  parameter DIG_5                  = 7'b0010010;
  parameter DIG_6                  = 7'b0000010;
  parameter DIG_7                  = 7'b1111000;
  parameter DIG_8                  = 7'b0000000;
  parameter DIG_9                  = 7'b0010000;
  parameter MINUS                  = 7'b0111111;
  parameter ERROR                  = 7'b0000110;
  parameter OFF_DOT                = 1'b1;
  parameter ON_DOT                 = 1'b0; 

  always@ (posedge clk)
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

  reg [ CNT - 1 : 00 ] cnt = 0;
  reg clk2;

  always@ (posedge clk)
    begin
      cnt <= cnt + 'b1;
      clk2 <= cnt[ CNT - 1 ];
    end

  reg [1:0]shift = 0;
  assign anodes = (4'b1111 - (4'b0001 << shift));
  always@ (posedge clk2)
    begin
      shift <= shift + 2'b1;
    end

  reg [ NUMBER_TO_SEG - 1 : 00 ] number_to_seg = 0;

  always@ (posedge clk)
    begin
      if(contr == 0) begin
        case (anodes)
          ANODE_1: number_to_seg <= (data%10);
          ANODE_2: number_to_seg <= ((data - (data % 10)) % 100) / 10;
          ANODE_3: number_to_seg <= ((data - (data % 100)) % 1000) / 100;
          ANODE_4: number_to_seg <= ((data - (data % 1000)) % 10000) / 1000;
        endcase
        case (number_to_seg)
          4'd0:    segments <= {OFF_DOT, DIG_0};
          4'd1:    segments <= {OFF_DOT, DIG_1};
          4'd2:    segments <= {OFF_DOT, DIG_2};
          4'd3:    segments <= {OFF_DOT, DIG_3};
          4'd4:    segments <= {OFF_DOT, DIG_4};
          4'd5:    segments <= {OFF_DOT, DIG_5};
          4'd6:    segments <= {OFF_DOT, DIG_6};
          4'd7:    segments <= {OFF_DOT, DIG_7};
          4'd8:    segments <= {OFF_DOT, DIG_8};
          4'd9:    segments <= {OFF_DOT, DIG_9};
          default: segments <= {OFF_DOT, DIG_0};
        endcase
      end

      else if(contr == 1) begin
        case (anodes)
          ANODE_1: number_to_seg <= (data%10);
          ANODE_2: number_to_seg <= ((data - (data % 10)) % 100) / 10;
          ANODE_3: number_to_seg <= ((data - (data % 100)) % 1000) / 100;
          ANODE_4: number_to_seg <= 10;
        endcase
        case (number_to_seg)
          4'd0:   segments <= {OFF_DOT, DIG_0};
          4'd1:   segments <= {OFF_DOT, DIG_1};
          4'd2:   segments <= {OFF_DOT, DIG_2};
          4'd3:   segments <= {OFF_DOT, DIG_3};
          4'd4:   segments <= {OFF_DOT, DIG_4};
          4'd5:   segments <= {OFF_DOT, DIG_5};
          4'd6:   segments <= {OFF_DOT, DIG_6};
          4'd7:   segments <= {OFF_DOT, DIG_7};
          4'd8:   segments <= {OFF_DOT, DIG_8};
          4'd9:   segments <= {OFF_DOT, DIG_9};
          4'd10:  segments <= {OFF_DOT, MINUS};
          default segments <= {OFF_DOT, DIG_0};
        endcase
      end

      else if(contr == 2) begin
        case (anodes)
          ANODE_1: number_to_seg <= 11;
          ANODE_2: number_to_seg <= 0;
          ANODE_3: number_to_seg <= 0;
          ANODE_4: number_to_seg <= 0;
        endcase
        case (number_to_seg)
          4'd0:   segments <= {OFF_DOT, DIG_0};
          4'd11:  segments <= {OFF_DOT, ERROR};
          default segments <= {OFF_DOT, DIG_0};
        endcase
      end

      else if(contr == 4) begin
        case (anodes)
          ANODE_1: number_to_seg <= (data%10);
          ANODE_2: number_to_seg <= ((data - (data % 10)) % 100) / 10;
          ANODE_3: number_to_seg <= ((data - (data % 100)) % 1000) / 100;
          ANODE_4: number_to_seg <= ((data - (data % 1000)) % 10000) / 1000;
        endcase
        if (anodes == ANODE_3)
          begin
            case (number_to_seg)
          4'd0:   segments <= {ON_DOT, DIG_0};
          4'd1:   segments <= {ON_DOT, DIG_1};
          4'd2:   segments <= {ON_DOT, DIG_2};
          4'd3:   segments <= {ON_DOT, DIG_3};
          4'd4:   segments <= {ON_DOT, DIG_4};
          4'd5:   segments <= {ON_DOT, DIG_5};
          4'd6:   segments <= {ON_DOT, DIG_6};
          4'd7:   segments <= {ON_DOT, DIG_7};
          4'd8:   segments <= {ON_DOT, DIG_8};
          4'd9:   segments <= {ON_DOT, DIG_9};
          default segments <= {OFF_DOT, DIG_0};
            endcase
          end
        else
          begin
            case (number_to_seg)
          4'd0:   segments <= {OFF_DOT, DIG_0};
          4'd1:   segments <= {OFF_DOT, DIG_1};
          4'd2:   segments <= {OFF_DOT, DIG_2};
          4'd3:   segments <= {OFF_DOT, DIG_3};
          4'd4:   segments <= {OFF_DOT, DIG_4};
          4'd5:   segments <= {OFF_DOT, DIG_5};
          4'd6:   segments <= {OFF_DOT, DIG_6};
          4'd7:   segments <= {OFF_DOT, DIG_7};
          4'd8:   segments <= {OFF_DOT, DIG_8};
          4'd9:   segments <= {OFF_DOT, DIG_9};
          default segments <= {OFF_DOT, DIG_0};
            endcase
          end
      end
    end

endmodule
