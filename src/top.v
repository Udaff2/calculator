module top(

input clk,
input bit0, bit1, bit2, bit3,
input summ4, vixit5, delen6, umnog7,
input k_1, k_2

output anodes_1, anodes_2, anodes_3, anodes_4,
output seg_1, seg_2, seg_3, seg_4, seg_5, seg_6, seg_7
);

bit bit(.bit0(bit0), .bit1(bit1), .bit2(bit2), .bit3(bit3), .k_1(k_1), .k_2(k_2), .reg_1(reg_1), .reg_2(reg_2));

Arif Arif(.summ4(summ4), .vixit5(vixit5), .delen6(delen6), .umnog7(sw_7), .first(reg_1), .second(reg_2), .final(final));

Ind Ind(.clk(clk), .anodes_1(anodes_1), .anodes_2(anodes_2), .anodes_3(anodes_3), .anodes_4(anodes_4), .seg_1(seg_1), .seg_2(seg_2), 
.seg_3(seg_3), .seg_4(seg_4), .seg_5(seg_5), .seg_6(seg_6), .seg_7(seg_7));

endmodule
