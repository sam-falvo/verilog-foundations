`timescale 1ns / 1ps

module pipeline_tb();
	reg	req0=0, ack3=0, reset=0;
	wire	ack0, ack1, ack2;

	muller_c stage0(.a(req0), .b(~ack1), .x(ack0), .r(reset));
	muller_c stage1(.a(ack0), .b(~ack2), .x(ack1), .r(reset));
	muller_c stage2(.a(ack1), .b(~ack3), .x(ack2), .r(reset));

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		#10;
		reset <= 1;
		#10;
		reset <= 0;
		#10;
		req0 <= 1; #1; req0 <= 0;
		#10;
		ack3 <= 1;
		#10;
		req0 <= 1; #1; req0 <= 0;
		#10;
		ack3 <= 0;
		req0 <= 1; #1; req0 <= 0;
		#10;
		ack3 <= 1;
		#10;
	end
endmodule
