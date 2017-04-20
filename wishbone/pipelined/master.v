`default_nettype none
`timescale 1ns / 1ps

module master(
	input		clk_i,
	input		reset_i,

	output	[AW:0]	adr_o,
	output		cyc_o,
	output		stb_o,
	output		we_o
);
	parameter	ADDR_WIDTH = 16;

	parameter	AW = ADDR_WIDTH - 1;

	assign adr_o = 0;
	assign cyc_o = 0;
	assign stb_o = 0;
	assign we_o = 0;
endmodule

