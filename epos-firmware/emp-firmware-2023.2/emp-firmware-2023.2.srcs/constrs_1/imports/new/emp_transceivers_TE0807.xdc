##===========##
## MGT CLOCK ##
##===========##

## Comment: * The MGT reference clock MUST be provided by an external clock generator.
##
##          * The MGT reference clock frequency must be 320MHz.

set_property PACKAGE_PIN H10 [get_ports MGT_REFCLK_P_0]
set_property PACKAGE_PIN H9 [get_ports MGT_REFCLK_N_0]
create_clock -period 3.125 -name MGT_REFCLK_P [get_ports MGT_REFCLK_P_0]

# set_property PACKAGE_PIN D10 [get_ports MGT_REFCLK_P_1]
# set_property PACKAGE_PIN D9 [get_ports MGT_REFCLK_N_1]
# create_clock -period 3.125 -name MGT_REFCLK_SFP [get_ports MGT_REFCLK_P_1]


# Reset the LOC constraints applied by the IP XDC file, so that the board level pin/location constraints can be applied.
# NOTE: It is easier 'emp_fw_TE0807.bd' to use 'set_property LOC {}' here than to use 'reset_property LOC'.
#set_property LOC {} [get_cells -hierarchical -regexp -filter {REF_NAME =~ {.*GT(H|Y)E(3|4)_CHANNEL.*} && NAME =~ {.*timing.*}}]


#set_property LOC GTHE4_CHANNEL_X0Y0 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_0* && NAME =~ *gen_channel_container[0].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN V2 [get_ports CH0_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y1 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_1* && NAME =~ *gen_channel_container[0].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN U4 [get_ports CH1_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y2 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_2* && NAME =~ *gen_channel_container[0].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN T2 [get_ports CH2_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y3 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_3* && NAME =~ *gen_channel_container[0].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN P2 [get_ports CH3_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y4 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_4* && NAME =~ *gen_channel_container[1].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN N4 [get_ports CH4_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y5 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_5* && NAME =~ *gen_channel_container[1].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN M2 [get_ports CH5_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y6 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_6* && NAME =~ *gen_channel_container[1].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN K2 [get_ports CH6_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y7 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_7* && NAME =~ *gen_channel_container[1].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN J4 [get_ports CH7_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y8 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_8* && NAME =~ *gen_channel_container[2].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN H2 [get_ports CH8_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y9 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_9* && NAME =~ *gen_channel_container[2].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN G4 [get_ports CH9_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y10 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_10* && NAME =~ *gen_channel_container[2].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN F2 [get_ports CH10_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y11 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_11* && NAME =~ *gen_channel_container[2].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN E4 [get_ports CH11_RXp_i_0]
#set_property LOC GTHE4_CHANNEL_X0Y15 [get_cells -hierarchical -filter {NAME =~ *mgt_channel_inst_12* && NAME =~ *gen_channel_container[3].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]
#set_property PACKAGE_PIN A4 [get_ports CH12_RXp_i_0]




