`default_nettype none
`timescale 1ns / 1ps

`include "ipl_config.vh"

// This core aims to implement a simple, reusable Wishbone B.4 compatible
// bus master.  EMPHASIS ON SIMPLE -- pipelined mode can get pretty complex
// if you're not careful.
//
// Pipelined masters and slaves are really quite simple to implement overall.
// You just register the address, the bus command (read/write), and if writing,
// the data.
//
// Be careful about edge cases though.  If you implement back-to-back cycles
// to two different peripherals, and your pipeline depth is different for each,
// you can get an out-of-order response which leads to read 1 getting read 2's
// data, or worse.  Ultimately, since most masters are built to be generic,
// it's up to the intercon to prevent this from happening by forcing STALL_I
// on the master high until order can be preserved.  But, this is getting into
// that complexity that I specifically wanted to avoid above.  The simpler way
// of preventing this from happening is sticking to one, and only one, outstanding
// transaction per bus cycle: one strobe, one ack, in that order.

`include "asserts.vh"

module master_tb();
	parameter ADDR_WIDTH = 16;

	parameter AW = ADDR_WIDTH - 1;

	reg	[11:0]	story_to;
	reg		clk_i, reset_i, fault_to;

	wire	[AW:0]	adr_o;
	wire		cyc_o, stb_o, we_o;
	reg		ack_i;
	reg		dreq_i;

	always begin
		#5 clk_i <= ~clk_i;
	end

	master #(
		.ADDR_WIDTH(ADDR_WIDTH)
	) m(
		.clk_i(clk_i),
		.reset_i(reset_i),

		.dreq_i(dreq_i),

		.adr_o(adr_o),
		.cyc_o(cyc_o),
		.stb_o(stb_o),
		.we_o(we_o),
		.ack_i(ack_i)
	);

	`STANDARD_FAULT

	`DEFASSERT(adr, AW, o)
	`DEFASSERT0(cyc, o)
	`DEFASSERT0(stb, o)
	`DEFASSERT0(we, o)

	initial begin
		$dumpfile("master.vcd");
		$dumpvars;

		{ack_i, dreq_i, clk_i, reset_i, fault_to} <= 0;
		wait(~clk_i); wait(clk_i);

		reset_i <= 1;
		wait(~clk_i); wait(clk_i);

		reset_i <= 0;
		story_to <= 12'h000;
		wait(~clk_i); wait(clk_i); #1;
		assert_adr(0);
		assert_cyc(0);
		assert_stb(0);
		assert_we(0);

		// Given CYC_O is negated,
		// When DREQ_I is asserted,
		// I want CYC_O to assert
		// and a valid SIA address presented
		// and a read command offered.

		dreq_i <= 1;
		wait(~clk_i); wait(clk_i); #1;
		assert_cyc(1);
		assert_stb(1);
		assert_we(0);
		assert_adr(`IPL_READ_ADDR);

		// Given CYC_O is asserted,
		// If DREQ_I is (still) asserted,
		// I want the STB_O to negate to avoid re-reading the same address before we're ready.

		wait(~clk_i); wait(clk_i); #1;
		assert_cyc(1);
		assert_stb(0);
		assert_we(0);
		assert_adr(0);

		// Given CYC_O is asserted,
		// and a read cycle is in progress,
		// If ACK_I is asserted,
		// I want the cycle to end, and the data latched for the subsequent write cycle.

		ack_i <= 1;
		wait(~clk_i); wait(clk_i); #1;
		assert_cyc(0);
		assert_stb(0);
		assert_we(0);
		assert_adr(0);

		$display("@I Done.");
		onFault;
	end
endmodule

