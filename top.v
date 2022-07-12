module top(
 input clk,
 input [3:0] in_number,
 input p_key,
 input m_key,
 input um_key,
 input del_key,
 input k_1, k_2,
 
 output [3:0] anodes,
 output [7:0] segments,
 output [2:0] led = 0
);

wire [2:0] contr1;
wire [2:0] contr2;
wire [2:0] contr3;
wire reg_1;
wire contr;
sw sw(.in_number(in_number), .k_1(k_1), .reg_1(reg_1), .led(led), .contr(contr1));

sw2 sw2(.in_number(in_number), .k_2(k_2), .reg_2(reg_2), .led(led), .contr(contr2));

ALU ALU(.first(reg_1), .second(reg_2), .p_key(p_key), .m_key(m_key), .um_key(um_key),.del_key(del_key), .final(final), .contr(contr3), .led(led));

endmodule
