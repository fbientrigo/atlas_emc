##====================##
## TIMING CONSTRAINTS ##
##====================##

# Multicycle constraints: ease the timing constraints

# Uplink constraints: Values depend on the c_multicyleDelay. Shall be the same one for setup time and -1 for the hold time
set _xlnx_shared_i0 [get_pins -hierarchical -filter {NAME =~ *lpgbtFpga_top_inst/uplink_inst/frame_pipelined_s_reg[*]/C}]
set_multicycle_path -setup -from $_xlnx_shared_i0 3
set_multicycle_path -hold -from $_xlnx_shared_i0 2
set _xlnx_shared_i1 [get_pins -hierarchical -filter {NAME =~ *lpgbtFpga_top_inst/uplink_inst/*descrambledData_reg[*]/C}]
set_multicycle_path -setup -from $_xlnx_shared_i1 3
set_multicycle_path -hold -from $_xlnx_shared_i1 2

# Downlink constraints: Values depend on the c_multicyleDelay. Shall be the same one for setup time and -1 for the hold time
set _xlnx_shared_i2 [get_pins -hierarchical -filter {NAME =~ *lpgbtFpga_top_inst/downlink_inst/lpgbtfpga_scrambler_inst/scrambledData*/D}]
set_multicycle_path -setup -to $_xlnx_shared_i2 3
set_multicycle_path -hold -to $_xlnx_shared_i2 2