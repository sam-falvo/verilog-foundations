.PHONY: test waves

waves: test
	gtkwave wtf.vcd

test:
	iverilog -I ../includes/ -s queue_tb *.v && vvp -n a.out
