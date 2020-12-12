# 300 MHz external oscillator
create_clock -period [expr 10.0/3.0] -name osc_clk [get_ports osc_clk_p]
