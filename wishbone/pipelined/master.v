`default_nettype none
`timescale 1ns / 1ps

`include "ipl_config.vh"

module master(
	input		clk_i,
	input		reset_i,

	input		dreq_i,
	output		dack_o,

	output	[AW:0]	adr_o,
	output		cyc_o,
	output		stb_o,
	output		we_o,
	input		ack_i
);
	parameter	ADDR_WIDTH = 16;

	parameter	AW = ADDR_WIDTH - 1;

	reg	[AW:0]	adr_o;
	reg		stb_o;
	reg		we_o;

	reg	[AW:0]	rd_adr, wr_adr;
	reg		rd_cyc, wr_cyc;

	reg		dack_o;

	assign		cyc_o = rd_cyc | wr_cyc;

	always @(posedge clk_i) begin
		adr_o <= 0;
		stb_o <= 0;
		we_o <= 0;
		rd_cyc <= rd_cyc;
		wr_cyc <= wr_cyc;
		dack_o <= 0;

		if(reset_i) begin
			rd_adr <= `IPL_READ_ADDR;
			wr_adr <= `IPL_WRITE_ADDR;
			rd_cyc <= 0;
			wr_cyc <= 0;
		end

		else begin
			// WARNING: THIS DOES NOT SUPPORT SINGLE-CYCLE TRANSACTIONS!!!!!
			// Experience shows that it works in practice on my simulator,
			// but I offer NO PROMISE that it'll work for you.  You'll need
			// to explore/experiment on your own.

			if(dreq_i && ~cyc_o) begin
				adr_o <= rd_adr;
				stb_o <= 1;
				rd_cyc <= 1;
				dack_o <= 1;
			end
			if(rd_cyc && ack_i) begin
				rd_cyc <= 0;
				wr_cyc <= 1;
				adr_o <= wr_adr;
				stb_o <= 1;
				we_o <= 1;
			end
			if(wr_cyc && ack_i) begin
				wr_cyc <= 0;
				if(dreq_i) begin
					adr_o <= rd_adr;
					stb_o <= 1;
					rd_cyc <= 1;
					dack_o <= 1;
				end
			end
		end
	end
endmodule

