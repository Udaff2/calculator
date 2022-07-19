module ALU #(
  parameter integer REG     = 11,
  parameter integer ARIF    = 4,
  parameter integer IND_1   = 11,
  parameter integer CONTROL = 3,
  parameter integer RECORD  = 2,
  parameter integer ENTER_SW = 4
)(
  input clk_ALU,
  input [ ARIF - 1   : 00 ] arif_from_top,
  input [ ENTER_SW - 1  : 00 ] in_numb_from_top,
  input [ RECORD - 1 : 00 ] keys,

  output reg [ IND_1 - 1   : 00 ] ind_1,
  output reg [ CONTROL - 1 : 00 ] control

);

  parameter integer PLUS    = 4'b1110;
  parameter integer MINUS   = 4'b1101;
  parameter integer UMNOG   = 4'b1011;
  parameter integer DELEN   = 4'b0111;
  parameter integer DEFAULT = 4'b1111;
  parameter integer CODE_P  = 0;
  parameter integer CODE_M  = 1;
  parameter integer CODE_D0 = 2;
  parameter integer CODE_D  = 4;
  parameter integer KEY1 = 2'b10;
  parameter integer KEY2 = 2'b01;

  reg [ REG - 1 : 00 ] reg_1_from_sw;
  reg [ REG - 1 : 00 ] reg_2_from_sw;
  wire [ REG - 1 : 00 ] big;

  assign big = in_numb_from_top;

  always@(posedge clk_ALU)
    begin
      case(keys)
        KEY2: begin
          reg_2_from_sw = big;
        end
        KEY1: begin
          reg_1_from_sw = big;
        end
      endcase
      case(arif_from_top)
        DEFAULT: begin
          ind_1 = big;
          control = CODE_P;
        end
        PLUS: begin
          ind_1 = reg_1_from_sw + reg_2_from_sw;
          control = CODE_P;
        end
        MINUS: begin
          if(reg_1_from_sw < reg_2_from_sw)
            begin
              ind_1 = reg_2_from_sw - reg_1_from_sw;
              control = CODE_M;
            end
          else
            begin
              ind_1 = reg_1_from_sw - reg_2_from_sw;
              control = CODE_P;
            end
        end
        UMNOG: begin
          ind_1 = reg_1_from_sw * reg_2_from_sw;
          control = CODE_P;
        end
        DELEN:  begin
          if(reg_2_from_sw == 0)
            begin
              control = CODE_D0;
            end
          else
            begin
              ind_1 = (reg_1_from_sw * 100) / reg_2_from_sw;
              control = CODE_D;
            end
        end
      endcase
    end

endmodule
