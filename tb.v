`timescale 1 ns / 100 ps
 module tb();

	reg clk = 1'b0;

	wire [3:0]anodes;
	wire [6:0]segments;

always begin
    #10;
     clk = ~clk;
end

top top (.clk(clk), .anodes(anodes), .segments(segments));

initial begin
		$dumpvars;
		#13000000 $stop;
end

endmodule
