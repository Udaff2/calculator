module calculator #(
  parameter integer ENTER_SW = 4,
  parameter integer ALU_SW   = 4,
  parameter integer RECORD   = 2,
  parameter integer ANODES   = 4,
  parameter integer SEG_7    = 8,
  parameter integer LED      = 3,
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

  parameter integer LED1 = 3'b110;
  parameter integer LED2 = 3'b101;
  parameter integer LED3 = 3'b011;
  parameter integer KEY1 = 2'b10;
  parameter integer KEY2 = 2'b01;

  initial
    begin
      led = 3'b110;
    end

  always@(posedge clk)
    begin
      if(arif < 15)
        begin
          led <= LED1;
        end
      case(key)
        KEY1: led <= LED2;
        KEY2: led <= LED3;
      endcase
    end

  wire [ CONTROLS - 1 : 00 ] controls;
  wire [  IND_CON - 1 : 00 ] ind_con;
  wire [ ENTER_SW - 1 : 00 ] in_number_out;
  
  assign in_number_out = ~in_number;

  ALU ALU(
    .clk_ALU(clk),
    .arif_from_top    (arif         ),
    .in_numb_from_top (in_number_out),
	  .keys             (key          ),
    .ind_1            (ind_con      ),
    .control          (controls     )
  );

  segment segment(
    .clk           (clk     ),
    .data          (ind_con ),
    .contr         (controls),
    .anodes        (anodes  ),
    .segments      (segments)
  );

endmodule
