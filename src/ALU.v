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
  output reg [ CONTROL - 1 : 00 ] control,
  output reg [ 5 : 00 ] data_1,
  output reg [ 5 : 00 ] data_2,
  output reg [ 5 : 00 ] data_3,
  output reg [ 5 : 00 ] data_4,
  output reg [ 5 : 00 ] data_6,
  output reg [ 5 : 00 ] data_8,
  output reg [ 5 : 00 ] data_9,
  output reg [ 5 : 00 ] data_10,
  output reg [ 5 : 00 ] data_11,
  output reg [ 5 : 00 ] data_13,
  output reg [ 5 : 00 ] data_15,
  output reg [ 5 : 00 ] data_16,
  output reg [ 5 : 00 ] data_17,
  output reg [ 5 : 00 ] data_18,
  output reg [ 5 : 00 ] data_dot
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
  
  initial begin
   data_1 = 0;
	data_2 = 0;
	data_3 = 0;
	data_4 = 0;
	data_6 = 6'b11_1111;
   data_8 = 0;
	data_9 = 0;
	data_10 = 0;
	data_11 = 0;
	data_13 = 6'b11_1111;
	data_15 = 6'b11_1111;
	data_16 = 6'b11_1111;
	data_17 = 6'b11_1111;
	data_18 = 6'b11_1111;	
  end

  always@(posedge clk_ALU)
    begin
      case(keys)
        KEY2: begin
          reg_2_from_sw = big;
			 data_6 = 6'b11_1111;
			 data_11 = (reg_2_from_sw % 10);
          data_10 = (reg_2_from_sw / 10) % 10;
          data_9 = (reg_2_from_sw / 100) % 10;
          data_8 = (reg_2_from_sw / 1000);
			 data_dot = 6'b10_0000;
			 data_13 = 6'b11_1111;
			 data_15 = 6'b11_1111;
			 data_16 = 6'b11_1111;
			 data_17 = 6'b11_1111;
			 data_18 = 6'b11_1111;
        end
        KEY1: begin
          reg_1_from_sw = big;
			 data_4 = (reg_1_from_sw % 10);
          data_3 = (reg_1_from_sw / 10) % 10;
          data_2 = (reg_1_from_sw / 100) % 10;
          data_1 = (reg_1_from_sw / 1000);
			 data_dot = 6'b10_0000;
			 data_6 = 6'b11_1111;
			 data_13 = 6'b11_1111;
			 data_15 = 6'b11_1111;
			 data_16 = 6'b11_1111;
			 data_17 = 6'b11_1111;
			 data_18 = 6'b11_1111;
        end
      endcase
      case(arif_from_top)
        DEFAULT: begin
          ind_1 = big;
          control = CODE_P;
			 data_dot = 6'b10_0000;
			 data_6 = 6'b11_1111;
			 data_13 = 6'b11_1111;
			 data_15 = 6'b11_1111;
			 data_16 = 6'b11_1111;
			 data_17 = 6'b11_1111;
			 data_18 = 6'b11_1111;
        end
        PLUS: begin
          ind_1 = reg_1_from_sw + reg_2_from_sw;
          control = CODE_P;
			 data_dot = 6'b10_0000;
			 data_6 = 6'b11_1110;
			 data_13 = 6'b11_1010;
			 data_18 = (ind_1 % 10);
          data_17 = (ind_1 / 10) % 10;
          data_16 = (ind_1 / 100) % 10;
          data_15 = (ind_1 / 1000);
        end
        MINUS: begin
          if(reg_1_from_sw < reg_2_from_sw)
            begin
              ind_1 = reg_2_from_sw - reg_1_from_sw;
              control = CODE_M;
				  data_dot = 6'b10_0000;
			     data_6 = 10;
			     data_13 = 6'b11_1010;
			     data_18 = (ind_1 % 10);
              data_17 = (ind_1 / 10) % 10;
              data_16 = (ind_1 / 100) % 10;
              data_15 = 10;
            end
          else
            begin
              ind_1 = reg_1_from_sw - reg_2_from_sw;
              control = CODE_P;
				  data_dot = 6'b10_0000;
				  data_6 = 10;
				  data_13 = 6'b11_1010;
			     data_18 = (ind_1 % 10);
              data_17 = (ind_1 / 10) % 10;
              data_16 = (ind_1 / 100) % 10;
              data_15 = (ind_1 / 1000);
            end
        end
        UMNOG: begin
          ind_1 = reg_1_from_sw * reg_2_from_sw;
          control = CODE_P;
			 data_dot = 6'b10_0000;
			 data_6 = 6'b11_1100;
			 data_13 = 6'b11_1010;
			 data_18 = (ind_1 % 10);
          data_17 = (ind_1 / 10) % 10;
          data_16 = (ind_1 / 100) % 10;
          data_15 = (ind_1 / 1000);
        end
        DELEN:  begin
          if(reg_2_from_sw == 0)
            begin
              control = CODE_D0;
				  data_dot = 6'b10_0000;
				  data_6 = 6'b11_1011;
				  data_13 = 6'b11_1010;
			     data_18 = 11;
              data_17 = 0;
              data_16 = 0;
              data_15 = 0;
            end
          else
            begin
              ind_1 = (reg_1_from_sw * 100) / reg_2_from_sw;
              control = CODE_D;
				  data_dot = 6'b10_0001;
				  data_6 = 6'b11_1011;
				  data_13 = 6'b11_1010;
			     data_18 = (ind_1 % 10);
              data_17 = (ind_1 / 10) % 10;
              data_16 = (ind_1 / 100) % 10;
              data_15 = (ind_1 / 1000);
            end
        end
      endcase
    end

endmodule
