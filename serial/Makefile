.PHONY: receiver.waves

receiver.waves:
	iverilog -I ../includes/ -s receiver_tb *.v && vvp -n a.out && gtkwave receiver.vcd
