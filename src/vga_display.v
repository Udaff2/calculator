// vga_display.v
`timescale 1ns / 1ps

module vga_display(
    input clk,
	 input [5:0] data1,
	 input [5:0] data2,
	 input [5:0] data3,
	 input [5:0] data4,
	 input [5:0] data6,
	 input [5:0] data8,
	 input [5:0] data9,
	 input [5:0] data10,
	 input [5:0] data11,
	 input [5:0] data13,
    input [5:0] data15,
    input [5:0] data16,
    input [5:0] data17,
    input [5:0] data18,
	 input [5:0] datadot,
    output reg r,
    output reg g,
    output reg b,
    output hs,
    output vs
    );
	
	 // отображаемая область дисплея
	parameter UP_BOUND = 31;
	parameter DOWN_BOUND = 510;
	parameter LEFT_BOUND = 144;
	parameter RIGHT_BOUND = 783;

	 // Область отображения 14 символов в центре экрана
	parameter up_pos = 267;
	parameter down_pos = 274;
	parameter left_pos = 457;
	parameter right_pos = 583;
	
	wire pclk;
	reg [1:0] count;
	reg [9:0] hcount, vcount;
	wire [7:0] p[126:0];

	RAM_set u_ram_1 (
		.clk(clk),
		.data(data1),
		.col0(p[0]),
		.col1(p[1]),
		.col2(p[2]),
		.col3(p[3]),
		.col4(p[4]),
		.col5(p[5]),
		.col6(p[6])
	);
	RAM_set u_ram_2 (
		.clk(clk),
		.data(data2),
		.col0(p[7]),
		.col1(p[8]),
		.col2(p[9]),
		.col3(p[10]),
		.col4(p[11]),
		.col5(p[12]),
		.col6(p[13])
	);
	RAM_set u_ram_3 (
		.clk(clk),
		.data(data3),
		.col0(p[14]),
		.col1(p[15]),
		.col2(p[16]),
		.col3(p[17]),
		.col4(p[18]),
		.col5(p[19]),
		.col6(p[20])
	);
	RAM_set u_ram_4 (
		.clk(clk),
		.data(data4),
		.col0(p[21]),
		.col1(p[22]),
		.col2(p[23]),
		.col3(p[24]),
		.col4(p[25]),
		.col5(p[26]),
		.col6(p[27])
	);
	RAM_set u_ram_6 (
		.clk(clk),
		.data(data6),
		.col0(p[35]),
		.col1(p[36]),
		.col2(p[37]),
		.col3(p[38]),
		.col4(p[39]),
		.col5(p[40]),
		.col6(p[41])
	);
	RAM_set u_ram_8 (
		.clk(clk),
		.data(data8),
		.col0(p[49]),
		.col1(p[50]),
		.col2(p[51]),
		.col3(p[52]),
		.col4(p[53]),
		.col5(p[54]),
		.col6(p[55])
	);
	RAM_set u_ram_9 (
		.clk(clk),
		.data(data9),
		.col0(p[56]),
		.col1(p[57]),
		.col2(p[58]),
		.col3(p[59]),
		.col4(p[60]),
		.col5(p[61]),
		.col6(p[62])
	);
	RAM_set u_ram_10 (
		.clk(clk),
		.data(data10),
		.col0(p[63]),
		.col1(p[64]),
		.col2(p[65]),
		.col3(p[66]),
		.col4(p[67]),
		.col5(p[68]),
		.col6(p[69])
	);
	RAM_set u_ram_11 (
		.clk(clk),
		.data(data11),
		.col0(p[70]),
		.col1(p[71]),
		.col2(p[72]),
		.col3(p[73]),
		.col4(p[74]),
		.col5(p[75]),
		.col6(p[76])
	);
	RAM_set u_ram_13 (
		.clk(clk),
		.data(data13),
		.col0(p[84]),
		.col1(p[85]),
		.col2(p[86]),
		.col3(p[87]),
		.col4(p[88]),
		.col5(p[89]),
		.col6(p[90])
	);
	RAM_set u_ram_15 (
		.clk(clk),
		.data(data15),
		.col0(p[98]),
		.col1(p[99]),
		.col2(p[100]),
		.col3(p[101]),
		.col4(p[102]),
		.col5(p[103]),
		.col6(p[104])
	);
	RAM_set u_ram_16 (
		.clk(clk),
		.data(data16),
		.col0(p[105]),
		.col1(p[106]),
		.col2(p[107]),
		.col3(p[108]),
		.col4(p[109]),
		.col5(p[110]),
		.col6(p[111])
	);
	RAM_set dot (
		.clk(clk),
		.data(datadot),
		.col0(p[112])
	);
	RAM_set u_ram_17 (
		.clk(clk),
		.data(data17),
		.col0(p[113]),
		.col1(p[114]),
		.col2(p[115]),
		.col3(p[116]),
		.col4(p[117]),
		.col5(p[118]),
		.col6(p[119])
	);
	RAM_set u_ram_18 (
		.clk(clk),
		.data(data18),
		.col0(p[120]),
		.col1(p[121]),
		.col2(p[122]),
		.col3(p[123]),
		.col4(p[124]),
		.col5(p[125]),
		.col6(p[126])
	);
	
	 // Получаем частоту пикселей 25 МГц
  pll pll_inst(
      .inclk0(clk),
      .c0(pclk)
  );
	
	 // Количество столбцов и синхронизация строк
	assign hs = (hcount < 96) ? 0 : 1;
	always @ (posedge pclk)
	begin
		if (hcount == 799)
			hcount <= 0;
		else
			hcount <= hcount+1;
	end
	
	 // Количество строк и синхронизация полей
	assign vs = (vcount < 2) ? 0 : 1;
	always @ (posedge pclk)
	begin
		if (hcount == 799) begin
			if (vcount == 520)
				vcount <= 0;
			else
				vcount <= vcount+1;
		end
		else
			vcount <= vcount;
	end
	
	 // Устанавливаем значение отображаемого сигнала
	always @ (posedge pclk)
	begin
		if (vcount >= UP_BOUND && vcount <= DOWN_BOUND && hcount >= LEFT_BOUND && hcount <= RIGHT_BOUND) 
		 begin
			if (vcount >= up_pos && vcount <= down_pos && hcount >= left_pos && hcount <= right_pos) 
			 begin
				if (p[hcount-left_pos][vcount-up_pos]) begin
					r <= 1'b1;
					g <= 1'b1;
					b <= 1'b1;
				end
				else begin
					r <= 1'b0;
					g <= 1'b0;
					b <= 1'b0;
				end
			 end
			 else begin
				 r <= 1'b0;
				 g <= 1'b0;
				 b <= 1'b0;
			 end
		 end
		 else begin
			 r <= 1'b0;
			 g <= 1'b0;
			 b <= 1'b0;
		 end
	end

endmodule
