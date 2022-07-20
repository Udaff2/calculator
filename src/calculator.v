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
  output reg [ LED -1  : 00 ] led,
  output r,
  output g,
  output b,
  output hs,
  output vs
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
  wire [5:0] data1;
  wire [5:0] data2;
  wire [5:0] data3;
  wire [5:0] data4;
  wire [5:0] data6;
  wire [5:0] data8;
  wire [5:0] data9;
  wire [5:0] data10;
  wire [5:0] data11;
  wire [5:0] data13;
  wire [5:0] data15;
  wire [5:0] data16;
  wire [5:0] data17;
  wire [5:0] data18;
  wire [5:0] datadot;
  
  assign in_number_out = ~in_number;

  ALU ALU(
    .clk_ALU(clk),
    .arif_from_top    (arif         ),
    .in_numb_from_top (in_number_out),
	 .keys             (key          ),
    .ind_1            (ind_con      ),
    .control          (controls     ),
	 .data_1           (data1        ),
    .data_2           (data2        ),
    .data_3           (data3        ),
    .data_4           (data4        ),
    .data_6           (data6        ),
    .data_8           (data8        ),
    .data_9           (data9        ),
    .data_10          (data10       ),
    .data_11          (data11       ),
    .data_13          (data13       ),
	 .data_15          (data15       ),
    .data_16          (data16       ),
    .data_17          (data17       ),
    .data_18          (data18       ),
	 .data_dot         (datadot      )
  );

  segment segment(
    .clk           (clk     ),
    .data          (ind_con ),
    .contr         (controls),
    .anodes        (anodes  ),
    .segments      (segments)
  );
  vga_display(
    .clk             (clk),
	 .r               (r  ),
    .g               (g  ),
    .b               (b  ),
    .hs              (hs ),
    .vs              (vs ),
	 .data1           (data1        ),
    .data2           (data2        ),
    .data3           (data3        ),
    .data4           (data4        ),
    .data6           (data6        ),
    .data8           (data8        ),
    .data9           (data9        ),
    .data10          (data10       ),
    .data11          (data11       ),
    .data13          (data13       ),
	 .data15          (data15       ),
    .data16          (data16       ),
    .data17          (data17       ),
    .data18          (data18       ),
	 .datadot         (datadot      )
  );

endmodule
