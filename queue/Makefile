waves: test
	gtkwave wtf.vcd

test:
	iverilog -I ../includes/ -m queue_8x9_tb *.v
	vvp -n a.out
