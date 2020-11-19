proc range {min max} {
    for {set i $min} {$i < $max} {incr i} {
        lappend result $i
    }
    return $result
}

proc set_slave_property {list prefix suffix val} {
    foreach item $list {
        lappend result  "CONFIG.${prefix}[format %02d ${item}]_${suffix} {$val}"
    }
    return [join $result]
}

# TODO: pull the number of slaves from the firmware
set NMASTERS 1
set NSLAVES 2
set all [range 0 $NSLAVES]
set slaves [range 0 $NSLAVES]
set masters [range 0 $NMASTERS]
set IS_REGISTERED $slaves
set IS_ASYNC $slaves

puts "Creating block design..."
set ip_name "axi_interconnect"
set prjdir [get_property DIRECTORY [current_project]]
create_bd_design -dir "$prjdir../../bd/" $ip_name
create_bd_cell -type ip -vlnv [get_ipdefs -all -filter {NAME == axi_interconnect && UPGRADE_VERSIONS == ""}] $ip_name
set OUTER_AND_AUTO 4

set properties [join [list \
                          "CONFIG.NUM_SI {${NSLAVES}}" \
                          "CONFIG.NUM_MI {${NMASTERS}}" \
                          [set_slave_property $masters "M" "HAS_REGSLICE" $OUTER_AND_AUTO] \
                          [set_slave_property $slaves  "S" "HAS_REGSLICE" $OUTER_AND_AUTO] ]]

set_property -dict $properties [get_bd_cells $ip_name]

puts "Configuring bd pins..."
make_bd_pins_external  [get_bd_pins $ip_name/ARESETN]
make_bd_pins_external  [get_bd_pins axi_interconnect/ACLK]

foreach i $masters {
    set num [format %02d $i]
    make_bd_intf_pins_external  [get_bd_intf_pins "$ip_name/M${num}_AXI"]
    make_bd_pins_external  [get_bd_pins "$ip_name/m${num}_aclk"]
    make_bd_pins_external  [get_bd_pins "$ip_name/m${num}_aresetn"]
    make_bd_pins_external  [get_bd_pins "$ip_name/m${num}_aclk"]
    make_bd_pins_external  [get_bd_pins "$ip_name/m${num}_aresetn"]
    set_property -dict [list CONFIG.PROTOCOL {AXI4LITE}] [get_bd_intf_ports "M${num}_AXI_0"]
}

foreach i $slaves {
    set num [format %02d $i]
    make_bd_intf_pins_external  [get_bd_intf_pins "$ip_name/S${num}_AXI"]
    make_bd_pins_external  [get_bd_pins "$ip_name/s${num}_aclk"]
    make_bd_pins_external  [get_bd_pins "$ip_name/s${num}_aresetn"]
    make_bd_pins_external  [get_bd_pins "$ip_name/s${num}_aclk"]
    make_bd_pins_external  [get_bd_pins "$ip_name/s${num}_aresetn"]
    set_property -dict [list CONFIG.MAX_BURST_LENGTH {1} \
                            CONFIG.SUPPORTS_NARROW_BURST {0} \
                            CONFIG.FREQ_HZ {40.0} \
                            CONFIG.PROTOCOL {AXI4LITE}] \
        [get_bd_intf_ports "S${num}_AXI_0"]
    set_property -dict [list CONFIG.ASSOCIATED_RESET "{S${num}_ARESETN_0}"] [get_bd_ports "S${num}_ACLK_0"]
}

puts "Setting bd addresses..."
assign_bd_address
set block_size 64 ; # kb
foreach i $slaves {
    set seg [get_bd_addr_segs "S[format %02d $i]_AXI_0/SEG_M00_AXI_0_Reg"]
    set_property offset [expr {0 + $i * $block_size * 1024}] $seg
    set_property range ${block_size}k $seg
}


puts "Validating bd design.."
validate_bd_design

puts "Creating bd wrapper.."
make_wrapper -files [get_files ${ip_name}.bd] -top -import -force

save_bd_design
