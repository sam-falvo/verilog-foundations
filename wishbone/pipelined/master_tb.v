`default_nettype none
`timescale 1ns / 1ps

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
	reg		clk_i, reset_i;

	wire	[AW:0]	adr_o;
	wire		cyc_o, stb_o, we_o;

	always begin
		#5 clk_i <= ~clk_i;
	end

	master #(
		.ADDR_WIDTH(ADDR_WIDTH)
	) m(
		.clk_i(clk_i),
		.reset_i(reset_i),

		.adr_o(adr_o),
		.cyc_o(cyc_o),
		.stb_o(stb_o),
		.we_o(we_o)
	);

	`DEFASSERT(adr, AW, o)
	`DEFASSERT0(cyc, o)
	`DEFASSERT0(stb, o)
	`DEFASSERT0(we, o)

	initial begin
		$dumpfile("master.vcd");
		$dumpvars;

		{clk_i, reset_i} <= 0;
		wait(~clk_i); wait(clk_i);

		reset_i <= 1;
		wait(~clk_i); wait(clk_i);

		reset_i <= 0;
		story_to <= 12'h000;
		wait(~clk_i); wait(clk_i);
		assert_adr(0);
		assert_cyc(0);
		assert_stb(0);
		assert_we(0);

		#100;
		$display("@I Done.");
		$stop;
	end
endmodule

