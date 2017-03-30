// INTERNAL.
// Renders a name and suffix as a string, suitable for use in a $display
// statement.  Example: NTB(status,i) answers with "status_i"

`define NTB(name,suffix)\
	`"name``_``suffix`"

// Create a task to assert, in the functional testing sense,
// that a signal matches an expected value.  This variant is
// intended to be used with multi-bit quantities.
//
// Example: DEFASSERT(status, 7, i)
// Effects: Creates a task named assert_status(exp) which compares a wire
//          [7+n:n] status_i against the expected value exp[7:0].  If they
//          do not match, a diagnostic is printed via $display(), and the
//          simulation is stopped with $stop.

`define DEFASSERT(name,msb,suffix)\
	task assert_``name``;\
	input [``msb``:0] expected;\
	begin\
		if(expected !== ``name``_``suffix``) begin\
			$display("@E %03X %s Expected %X, got %X", story_to, `NTB(name,suffix), expected, ``name``_``suffix``);\
			$stop;\
		end\
	end\
	endtask

// Create a task to assert, in the functional testing sense,
// that a signal matches an expected value.  This particular
// variant is for single-bit checks.
//
// Example: DEFASSERT0(status, i)
// Effects: Creates a task named assert_status(exp) which compares a wire
//          named status_i against the expected value exp.  If they do not
//          match, a diagnostic is printed via $display(), and the simulation
//          is stopped with $stop.

`define DEFASSERT0(name,suffix)\
	task assert_``name``;\
	input expected;\
	begin\
		if(expected !== ``name``_``suffix``) begin\
			$display("@E %03X %s Expected %X, got %X", story_to, `NTB(name,suffix), expected, ``name``_``suffix``);\
			$stop;\
		end\
	end\
	endtask

// Create a pair of tasks which assert or negate a specified signal.
// Example: DEFIO(clk, _l, _h)
// Effects: Creates two tasks, clk_l() and clk_h(), which effects a register
//          named clk to be either 0 or 1, respectively.

`define DEFIO(name,highsuf,lowsuf)\
	task name``lowsuf``;\
	begin\
		name <= 0; #10;\
	end\
	endtask\
	task name``highsuf``;\
	begin\
		name <= 1; #10;\
	end\
	endtask
