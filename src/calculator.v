module calculator #(
  parameter integer ENTER_SW = 4,
  parameter integer ALU_SW   = 4,
  parameter integer RECORD   = 2,
  parameter integer ANODES   = 4,
  parameter integer SEG_7    = 8,
  parameter integer LED      = 3,
  parameter integer IND_REG  = 4,
  parameter integer CONTROLS = 3,
  parameter integer IND_CON  = 11
)(
  input clk,
  input [ ENTER_SW - 1 : 00 ] in_number,
  input [ ALU_SW - 1   : 00 ] arif,
  input [ RECORD -1    : 00 ] key,

  output [ ANODES -1   : 00 ] anodes,
  output [ SEG_7 -1    : 00 ] segments,
  output reg [ LED -1  : 00 ] led
);

  parameter integer LED1 = 3'b001;
  parameter integer LED2 = 3'b010;
  parameter integer LED3 = 3'b100;
  parameter integer KEY1 = 2'b01;
  parameter integer KEY2 = 2'b10;

  reg [ IND_REG - 1 : 00 ] ind;
  reg [ IND_REG - 1 : 00 ] reg_1;
  reg [ IND_REG - 1 : 00 ] reg_2;

  initial
    begin
      led = 3'b110;
    end

  always@(posedge clk)
    begin
      if(arif < 15)
        begin
          led <= ~LED1;
        end
      case(key)
        ~KEY1: led <= ~LED2;
        ~KEY2: led <= ~LED3;
      endcase
    end

  always@(posedge clk)
    begin
      ind <= ~in_number;
      case(key)
        ~KEY1: begin
          reg_2 <= ~in_number;
        end
        ~KEY2: begin
          reg_1 <= ~in_number;
        end
      endcase
    end

  wire [ CONTROLS - 1 : 00 ] controls;
  wire [  IND_CON - 1 : 00 ] ind_con;

  ALU ALU(
    .clk_ALU(clk),
    .reg_1_from_sw  (reg_1   ),
    .reg_2_from_sw  (reg_2   ),
    .arif_from_top  (arif    ),
    .ind_1          (ind_con ),
    .control        (controls)
  );

  segment segment(
    .Clk           (clk     ),
    .ind_from_sw   (ind     ),
    .ind_from_ALU  (ind_con ),
    .c_from_ALU    (controls),
    .keys          (key     ),
    .arifs         (arif    ),
    .anodes        (anodes  ),
    .segments      (segments)
  );

endmodule
