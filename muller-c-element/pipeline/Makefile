.PHONY: test waves

waves: test
	gtkwave wtf.vcd

test:
	iverilog -I ../includes/ -s pipeline_tb *.v ../*.v && vvp -n a.out
