module ALU #(
  parameter integer REG     = 4,
  parameter integer ARIF    = 4,
  parameter integer IND_1   = 11,
  parameter integer CONTROL = 3,
  parameter integer BIG_1   = 11
)(
  input [ REG - 1  : 00 ] reg_1_from_sw,
  input [ REG - 1  : 00 ] reg_2_from_sw,
  input [ ARIF - 1 : 00 ] arif_from_top,
  input clk_ALU,

  output reg [ IND_1 - 1   : 00 ] ind_1,
  output reg [ CONTROL - 1 : 00 ] control

);

  parameter integer PLUS    = 4'b1110;
  parameter integer MINUS   = 4'b1101;
  parameter integer UMNOG   = 4'b1011;
  parameter integer DELEN   = 4'b0111;
  parameter integer CODE_P  = 0;
  parameter integer CODE_M  = 1;
  parameter integer CODE_D0 = 2;
  parameter integer CODE_D  = 4;

  initial begin
    control = CODE_P;
  end

  reg [ BIG_1 - 1 : 00 ] big_1;

  always@(posedge clk_ALU)
    begin
      case(arif_from_top)
        PLUS: begin
          ind_1 <= reg_1_from_sw + reg_2_from_sw;
          control <= CODE_P;
        end
        MINUS: begin
          if(reg_1_from_sw < reg_2_from_sw)
            begin
              ind_1 <= reg_2_from_sw - reg_1_from_sw;
              control <= CODE_M;
            end
          else
            begin
              ind_1 <= reg_1_from_sw - reg_2_from_sw;
              control <= CODE_P;
            end
        end
        UMNOG: begin
          ind_1 <= reg_1_from_sw * reg_2_from_sw;
          control <= CODE_P;
        end
        DELEN:  begin
          if(reg_2_from_sw == 0)
            begin
              control <= CODE_D0;
            end
          else
            begin
              big_1 = reg_1_from_sw;
              ind_1 = (big_1 * 100) / reg_2_from_sw;
              control <= CODE_D;
            end
        end
      endcase
    end

endmodule
