.PHONY: master.waves

master.waves:
	iverilog -I ../../includes/ -s master_tb *.v && vvp -n a.out && gtkwave master.vcd
