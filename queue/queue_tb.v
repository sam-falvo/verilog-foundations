`timescale 1ns / 1ps

`include "asserts.vh"


module queue_tb();
	reg	[11:0]	story_to;

	reg		clk_i, reset_i;
	reg	[7:0]	dat_i;
	reg		push_i;
	reg		pop_i;

	wire	[7:0]	dat_o;
	wire		full_o, empty_o;

	wire	[2:0]	rp_to;
	wire	[2:0]	wp_to;
	wire	[3:0]	room_to;

	queue #(
		.DEPTH_BITS(3),	// 8-deep queue
		.DATA_BITS(8)	// 8-bit data path for input and output
	) q (
		.clk_i(clk_i),
		.reset_i(reset_i),

		.dat_i(dat_i),
		.push_i(push_i),

		.dat_o(dat_o),
		.pop_i(pop_i),
		.full_o(full_o),
		.empty_o(empty_o),

		.rp_to(rp_to),
		.wp_to(wp_to),
		.we_to(we_to)
	);

	task story;
	input [11:0] expected;
	begin
		story_to = expected;
	end
	endtask

	`DEFASSERT(rp,2,to)
	`DEFASSERT(wp,2,to)
	`DEFASSERT(room,3,to)

	`DEFASSERT0(empty,o)
	`DEFASSERT0(full,o)
	`DEFASSERT(dat,7,o)

	task tick;
	begin
		#19
		clk_i <= 0; #20
		clk_i <= 1; #1;
	end
	endtask

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		{clk_i, reset_i, dat_i, push_i} <= 0;
		story(0);

		tick;

		reset_i <= 1;

		tick;

		assert_rp(0);
		assert_wp(0);
		assert_room(8);

		story(2);

		reset_i <= 0;

		push_i <= 1;
		dat_i <= 8'hFF;

		tick;
		assert_room(7);
		assert_wp(1);
		assert_rp(0);
		tick;
		assert_room(6);
		assert_wp(2);
		assert_rp(0);
		tick;
		assert_room(5);
		assert_wp(3);
		assert_rp(0);
		tick;
		assert_room(4);
		assert_wp(4);
		assert_rp(0);
		tick;
		assert_room(3);
		assert_wp(5);
		assert_rp(0);
		tick;
		assert_room(2);
		assert_wp(6);
		assert_rp(0);
		tick;
		assert_room(1);
		assert_wp(7);
		assert_rp(0);
		tick;
		assert_room(0);
		assert_wp(0);
		assert_rp(0);
		tick;
		assert_room(0);
		assert_wp(0);
		assert_rp(0);

		// Popping the queue should advance the read pointer.

		story(3);

		push_i <= 0;
		pop_i <= 1;		// Also drives data outputs

		tick;
		assert_room(1);
		assert_wp(0);
		assert_rp(1);
		tick;
		assert_room(2);
		assert_wp(0);
		assert_rp(2);
		tick;
		assert_room(3);
		assert_wp(0);
		assert_rp(3);
		tick;
		assert_room(4);
		assert_wp(0);
		assert_rp(4);
		tick;
		assert_room(5);
		assert_wp(0);
		assert_rp(5);
		tick;
		assert_room(6);
		assert_wp(0);
		assert_rp(6);
		tick;
		assert_room(7);
		assert_wp(0);
		assert_rp(7);
		tick;
		assert_room(8);
		assert_wp(0);
		assert_rp(0);
		tick;
		assert_room(8);
		assert_wp(0);
		assert_rp(0);

		// The FIFO must support concurrent reads and writes.

		// (after writing the 8th item to the queue,
		// we should wrap around, and see the first
		// of the overwrites.)

		$display("@I Done.");
		$stop;
	end
endmodule

