# SDC Timing Constraints for Counter
set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA

# Clock definition: 100 MHz (10.0 ns period)
create_clock [get_ports clk] -name core_clk -period 10.0 -waveform {0.0 5.0}

# Clock uncertainty / jitter
set_clock_uncertainty 0.25 [get_clocks core_clk]
set_clock_transition  0.15 [get_clocks core_clk]

# Input and Output delays relative to core_clk
set_input_delay  2.0 -clock core_clk [get_ports {rst_n enable up_down load_val* load_en}]
set_output_delay 2.0 -clock core_clk [get_ports {count* overflow}]

# Driving cell and load
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 [all_inputs]
set_load 0.035 [all_outputs]
