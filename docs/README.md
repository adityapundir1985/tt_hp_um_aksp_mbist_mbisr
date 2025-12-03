tt_hp_um_aksp_mbist_mbisr - TinyTapeout-HP style project
Author: Aditya Kumar Singh Pundir

This repository is prepared to match the structure of the TinyTapeout 'ttihp-verilog-template' with a Verilog-2001 MBIST/MBISR example.

Project layout:
- verilog/rtl/mbist_controller.v
- verilog/rtl/mbisr_controller.v
- verilog/rtl/top.v
- verilog/rtl/tt_hp_um_aksp_mbist_mbisr.v  (top wrapper to be used by TinyTapeout flows)
- sim/tb_top.v   (testbench that demonstrates hierarchical fault injection)
- scripts/run.bat  (Windows helper)
- docs/README.md

How to simulate locally (Icarus Verilog):
  cd verilog/rtl
  iverilog -o ../../sim/sim.out *.v ../sim/tb_top.v
  vvp ../../sim/sim.out
  gtkwave wave.vcd

Notes:
- Code is Verilog-2001 compatible for Icarus Verilog (no SystemVerilog constructs).
- Fault injection is controlled by hierarchical regs: set 'dut.dut.fault_en' and 'dut.dut.fault_addr' from the TB or external script.
