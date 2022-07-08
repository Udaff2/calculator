module top(

input clk,
input sw_0, sw_1, sw_2, sw_3,
input sw_4, sw_5, sw_6, sw_7,
input k_1, k_2

output dig_1, dig_2, dig_3, dig_4,
output seg_1, seg_2, seg_3, seg_4, seg_5, seg_6, seg_7
);

sw sw(.sw_0(sw_0), .sw_1(sw_1), .sw_2(sw_2), .sw_3(sw_3), .k_1(k_1), .k_2(k_2), .reg_1(reg_1), .reg_2(reg_2));

Arif Arif(.sw_4(sw_4), .sw_5(sw_5), .sw_6(sw_6), .sw_7(sw_7), .first(reg_1), .second(reg_2), .final(final));

Ind Ind(.clk(clk), .dig_1(dig_1), .dig_2(dig_2), .dig_3(dig_3), .dig_4(dig_4), .seg_1(seg_1), .seg_2(seg_2), 
.seg_3(seg_3), .seg_4(seg_4), .seg_5(seg_5), .seg_6(seg_6), .seg_7(seg_7));

endmodule
