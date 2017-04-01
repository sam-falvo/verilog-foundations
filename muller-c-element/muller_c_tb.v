`timescale 1ns / 1ps

module muller_c_tb();
	reg a, b;
	wire x;

	muller_c mc(.a(a), .b(b), .x(x));

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		{a, b} = 0; #5;
		if(x !== 0) begin
			$display("001 X Expected 0, got %d", x);
			$stop;
		end

		{a, b} = 1; #5;
		if(x !== 0) begin
			$display("002 X Expected 0, got %d", x);
			$stop;
		end

		{a, b} = 2; #5;
		if(x !== 0) begin
			$display("003 X Expected 0, got %d", x);
			$stop;
		end

		{a, b} = 3; #5;
		if(x !== 1) begin
			$display("004 X Expected 1, got %d", x);
			$stop;
		end

		{a, b} = 2; #5;
		if(x !== 1) begin
			$display("005 X Expected 1, got %d", x);
			$stop;
		end

		{a, b} = 1; #5;
		if(x !== 1) begin
			$display("006 X Expected 1, got %d", x);
			$stop;
		end

		{a, b} = 0; #5;
		if(x !== 0) begin
			$display("007 X Expected 0, got %d", x);
			$stop;
		end
	end
endmodule
