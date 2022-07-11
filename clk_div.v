module clk_div(

	input clk,

	output clk2
);

reg [11:00]cnt = 0;

assign clk2 = cnt[11];

always@(posedge clk) begin 
	cnt <= cnt + 12'b1;
end

endmodule
