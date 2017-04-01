.PHONY: test waves

waves: test
	gtkwave wtf.vcd

test:
	iverilog -I ../includes/ -s muller_c_tb *.v && vvp -n a.out
