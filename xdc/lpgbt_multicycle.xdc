# Multicycle constraints: ease the timing constraints
# Uplink constraints: Values depend on the c_multicyleDelay.
# Shall be the same one for setup time and -1 for the hold time

# retiming changes register names and prevents multicycle path setting on the lpgbt cores
# Prevent these reset registers from getting merged across different LPGBT instances...
# they are high fanout and it caused timing to fail early on

set lpgbt_path "rbgen[*].readout_board_inst/lpgbt_link_wrapper"

set_property -quiet KEEP true \
    [get_cells -quiet -hierarchical -filter {NAME =~ top_hal/lpgbt_link_wrapper_inst/*/gearboxSyncReset*}]

set link_wrapper_cell [get_cells -quiet ${lpgbt_path}]
if {[string is space $link_wrapper_cell] == 0} {
set_property BLOCK_SYNTH.RETIMING false  $link_wrapper_cell
}

puts "Setting LPGBT Uplink Pipeline Multicycle Path"

set pipeline_s_reg_cells [get_cells -quiet "${lpgbt_path}/*uplink*/*frame_pipelined_s_reg[*]"]
if {[string is space $pipeline_s_reg_cells] == 0} {
    set_property -quiet KEEP true $pipeline_s_reg_cells
}

set pipeline_s_reg [get_pins -quiet "${lpgbt_path}/*uplink*/frame_pipelined_s_reg[*]/C"]
if {[string is space $pipeline_s_reg] == 0} {
    set_multicycle_path 4 -from $pipeline_s_reg -setup
    set_multicycle_path 3 -from $pipeline_s_reg -hold
}

puts "Setting LPGBT Uplink Descrambler Multicycle Path"
set descrambled_d_reg_cells \
    [get_cells -quiet "${lpgbt_path}/*uplink*/*descrambler*/*descrambler*/descrambledData_reg*"]
if {[string is space $descrambled_d_reg_cells] == 0} {
    set_property -quiet KEEP true $descrambled_d_reg_cells
}

set descrambled_d_reg \
    [get_pins -quiet "${lpgbt_path}/*uplink*/*descrambler*/*descrambler*/descrambledData_reg*/C"]
if {[string is space $descrambled_d_reg] == 0} {
    set_multicycle_path 4 -from $descrambled_d_reg -setup
    set_multicycle_path 3 -from $descrambled_d_reg -hold
}

# Downlink constraints: Values depend on the c_multicyleDelay.
# Shall be the same one for setup time and -1 for the hold time

puts "Setting LPGBT Downlink Scrambler Multicycle Path"
set scrambled_d_reg_cells [get_cells -quiet "${lpgbt_path}/*downlink_inst*/*_scramble*/scrambledData*"]
if {[string is space $scrambled_d_reg_cells] == 0} {
    set_property -quiet KEEP true $scrambled_d_reg_cells
}

set scrambled_d_reg [get_pins -quiet "${lpgbt_path}/*downlink_inst*/*_scramble*/scrambledData*/D"]
if {[string is space $scrambled_d_reg] == 0} {
    set_multicycle_path 4 -setup -to $scrambled_d_reg
    set_multicycle_path 3 -hold -to $scrambled_d_reg
}

################################################################################
# GBT-SCA Multicycle Path
################################################################################

#set latch_cells [concat \
#                     [get_cells top_hal/*csm_gen*/lpgbt_links_inst/uplink_gen*.lpgbtlatch.uplink_data_o_reg*] \
#                     [get_cells top_hal/*csm_gen*/lpgbt_links_inst/downlink_gen*downlink_data_reg*] \
#                     [get_cells -of [all_fanout -endpoints_only -flat -from [get_nets top_hal/strobe_320]]]
#             ]
#
#set_multicycle_path 8 -setup -from $latch_cells
#set_multicycle_path 7 -hold -from $latch_cells


#set to_sca [get_cells top_hal/csm*/gbt_controller_wrapper_inst/*/sca_inst/sca_gen*/sca_deserializer_inst/data_o_reg*]

#set_multicycle_path 8 -setup -from $sca_clk_en_from
#set_multicycle_path 7 -hold -from $sca_clk_en_from
#set_multicycle_path 8 -setup -to $sca_clk_en_to
#set_multicycle_path 7 -hold -to $sca_clk_en_to
