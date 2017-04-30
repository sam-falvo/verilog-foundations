`default_nettype none
`timescale 1ns / 1ps

`include "ipl_config.vh"

// This core aims to implement a simple, reusable Wishbone B.4 compatible bus
// master (currently in the form of a generic DMA controller).	EMPHASIS ON
// SIMPLE -- pipelined mode can get pretty complex if you're not careful.
//
// Masters and slaves designed to work with pipelined Wishbone are rather
// simple to implement overall.  You just register the address, the bus command
// (read/write), and if writing, the data.  Just make sure CYC_O is asserted
// until all outstanding transactions are completed.
//
// Be careful about edge cases though.	If you implement back-to-back cycles to
// two different peripherals, and your pipeline depth is different for each,
// you can get an out-of-order response which leads to read 1 getting read 2's
// data, or worse.  Ultimately, since most masters are built to be generic,
// it's up to the intercon to prevent this from happening by forcing STALL_I on
// the master high until order can be preserved.  But, this is getting into
// that complexity that I specifically wanted to avoid above.  The simpler way
// of preventing this from happening is sticking to one, and only one,
// outstanding transaction per bus cycle: one strobe, one ack, in that order.

// This master is currently built to model a DMA controller.  A *pulse* on
// DREQ_I triggers back to back read then write operations.  A pulse on DACK_O
// indicates to the slave that its request is *currently* being addressed.  (It
// does **not** indicate that the request has been completely serviced yet.)
//		   __	 __    __    __
// CLK_I	__/  \__/  \__/  \__/  \__
//		    _____
// DREQ_I	___/	 \________________
//			 ______
// DACK_O	________/      \__________
//			 ____________
// CYC_O	________/	     \____
//			 ____________
// STB_O	________/	     \____
//			       ______
// WE_O		______________/      \____
//			 _____________
// ACK_I	________////	      \___
//
// The following timing diagram shows a more traditional timing diagram for
// pipelined Wishbone interconnects:
//		   __	 __    __    __    __	 __    __    __
// CLK_I	__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
//		    _____
// DREQ_I	___/	 \________________________________________
//			 ______
// DACK_O	________/      \__________________________________
//			 ____________________________________
// CYC_O	________/				     \____
//			 ______		   ______
// STB_O	________/      \__________/	 \________________
//					   ______
// WE_O		__________________________/	 \________________
//				______			_____
// ACK_I	_______________/      \________________/     \____
//
//
// Note that DREQ_I is sampled when the DMAC is idle, or when ACK_I is asserted
// on the write cycle.	At least on my simulator, it's possible to get
// sustained back-to-back reads and writes with this logic as long as DREQ_I
// and ACK_I remains asserted.
//
// NOTE: This core does not implement a complete Wishbone interface.
// Only the bare minimum needed to illustrate the relevant and core
// logic.
//
// NOTE AGAIN: Notice that this core does not proceed beyond a single
// transaction.  As a result, we do not accept a STALL_I input.  It doesn't make sense for us.
// However, if you make a core that *does* allow more than one outstanding bus transaction,
// you will absolutely have to support STALL_I.

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
	parameter	IPL_READ_ADDR = `IPL_READ_ADDR;
	parameter	IPL_WRITE_ADDR = `IPL_WRITE_ADDR;

	parameter	AW = ADDR_WIDTH - 1;

	reg	[AW:0]	adr_o;
	reg		stb_o;
	reg		we_o;

	reg	[AW:0]	rd_adr, wr_adr;
	reg		rd_cyc, wr_cyc;

	reg		dack_o;

	assign		cyc_o = rd_cyc | wr_cyc;

	always @(posedge clk_i) begin
		// Unless otherwise instructed, the following signals assume
		// these values on any given clock cycle.

		adr_o <= 0;
		stb_o <= 0;
		we_o <= 0;
		rd_cyc <= rd_cyc;
		wr_cyc <= wr_cyc;
		dack_o <= 0;

		// Upon reset, reset internal registers to their power-on
		// defaults.

		if(reset_i) begin
			rd_adr <= IPL_READ_ADDR;
			wr_adr <= IPL_WRITE_ADDR;
			rd_cyc <= 0;
			wr_cyc <= 0;
		end

		// Otherwise, implement the read/write state machine here.

		else begin
			// WARNING: THIS CODE IS NOT EXPRESSLY DESIGNED FOR
			// SINGLE-CYCLE TRANSACTIONS.  Experience on my
			// simulator shows that it works in practice; but, I
			// offer NO PROMISE that it'll work for you.  You'll
			// need to explore/experiment on your own.

			// If the DMAC isn't doing anything at the moment,
			// initiate a read cycle.  At this time, we acknowledge
			// the request for data to tell the slave that it's
			// in-progress.

			if(dreq_i && ~cyc_o) begin
				adr_o <= rd_adr;
				stb_o <= 1;
				rd_cyc <= 1;
				dack_o <= 1;
			end

			// If the read cycle is complete, then we kick off the
			// write cycle.

			if(rd_cyc && ack_i) begin
				rd_cyc <= 0;
				wr_cyc <= 1;
				adr_o <= wr_adr;
				stb_o <= 1;
				we_o <= 1;
			end

			// If the write cycle is complete, we sample the DREQ_I
			// signal.  If it's still asserted, kick off another
			// read cycle.	Otherwise, revert back to idle
			// condition.

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

