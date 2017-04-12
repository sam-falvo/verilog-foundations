help:
	@echo
	@echo "make async_bridge.waves      Run gtkwave on results from simulating RAMCON"
	@echo

async_bridge.waves:
	iverilog -s async_bridge_tb async_bridge.v && vvp -n a.out && gtkwave async_bridge.vcd

