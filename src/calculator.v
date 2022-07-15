module calculator(

  input clk,
  input [3:0]in_number,
  input [3:0]arif,
  input [1:0]key,

  output [3:0]anodes,
  output [7:0]segments,
  output reg [2:0]led
);

  reg [3:0]ind;
  reg [3:0]reg_1;
  reg [3:0]reg_2;

  initial
    begin
      led = 3'b110;
    end

  always@(posedge clk)
    begin
      if(arif < 15)
        begin
          led <= 3'b110;
        end
      case(key)
        2'b10: led <= 3'b101;
        2'b01: led <= 3'b011;
      endcase
    end

  always@(posedge clk)
    begin
      ind <= ~in_number;
      case(key)
        1: begin
          reg_2 <= ~in_number;
        end
        2: begin
          reg_1 <= ~in_number;
        end
      endcase
    end

  wire [2:0] controls;
  wire [10:0] ind_con;

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
