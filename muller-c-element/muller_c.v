`timescale 1ns / 1ps

module muller_c(
	input		r,
	input		a,
	input		b,
	output		x
);
	assign #0.1 x = ~r & ((a & b) | (a & x) | (b & x));
endmodule
