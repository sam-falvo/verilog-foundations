`timescale 1ns / 1ps

module muller_c(
	input		a,
	input		b,
	output		x
);
	assign x = (a & b) | (a & x) | (b & x);
endmodule
