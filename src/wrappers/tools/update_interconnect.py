#!/usr/bin/env python3

from insert_code import insert_code

import sys

def update_interconnect (filename, nmasters, nslaves):

    def write_generics(filename):

        f = filename

        padding = "    "
        f.write("%s NUM_MASTERS : natural := %d;\n"% (padding, nmasters))
        f.write("%s NUM_SLAVES  : natural := %d\n" % (padding, nslaves))

    def write_slaves(filename):

        f = filename
        padding = "      "
        for i in range(nslaves):
            f.write("%sS%02d_ACLK_0    => axi_clk(%d),\n" % (padding,i,i))
            f.write("%sS%02d_ARESETN_0 => axi_resetn(%d),\n" % (padding, i, i))
            f.write("\n")
            f.write("%sS%02d_AXI_0_araddr  => axi_read_mosi(%d).address,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_arprot  => axi_read_mosi(%d).protection_type,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_arready => axi_read_miso(%d).ready_for_address,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_arvalid => axi_read_mosi(%d).address_valid,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_awaddr  => axi_write_mosi(%d).address,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_awprot  => axi_write_mosi(%d).protection_type,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_awready => axi_write_miso(%d).ready_for_address,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_awvalid => axi_write_mosi(%d).address_valid,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_bready  => axi_write_mosi(%d).ready_for_response,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_bresp   => axi_write_miso(%d).response,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_bvalid  => axi_write_miso(%d).response_valid,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_rdata   => axi_read_miso(%d).data,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_rready  => axi_read_mosi(%d).ready_for_data,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_rresp   => axi_read_miso(%d).response,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_rvalid  => axi_read_miso(%d).data_valid,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_wdata   => axi_write_mosi(%d).data,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_wready  => axi_write_miso(%d).ready_for_data,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_wstrb   => axi_write_mosi(%d).data_write_strobe,\n" % (padding, i, i))
            f.write("%sS%02d_AXI_0_wvalid  => axi_write_mosi(%d).data_valid,\n" % (padding, i, i))
            f.write("\n")

    def write_masters(filename):

        f = filename
        padding = "      "
        for i in range(nmasters):
            f.write("%sM%02d_ACLK_0    => master_axi_clk(%d),\n" % (padding,i,i))
            f.write("%sM%02d_ARESETN_0 => master_axi_resetn(%d),\n" % (padding, i, i))
            f.write("\n")
            f.write("%sM%02d_AXI_0_araddr  => master_axi_read_mosi(%d).address,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_arprot  => master_axi_read_mosi(%d).protection_type,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_arready => master_axi_read_miso(%d).ready_for_address,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_arvalid => master_axi_read_mosi(%d).address_valid,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_awaddr  => master_axi_write_mosi(%d).address,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_awprot  => master_axi_write_mosi(%d).protection_type,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_awready => master_axi_write_miso(%d).ready_for_address,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_awvalid => master_axi_write_mosi(%d).address_valid,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_bready  => master_axi_write_mosi(%d).ready_for_response,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_bresp   => master_axi_write_miso(%d).response,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_bvalid  => master_axi_write_miso(%d).response_valid,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_rdata   => master_axi_read_miso(%d).data,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_rready  => master_axi_read_mosi(%d).ready_for_data,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_rresp   => master_axi_read_miso(%d).response,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_rvalid  => master_axi_read_miso(%d).data_valid,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_wdata   => master_axi_write_mosi(%d).data,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_wready  => master_axi_write_miso(%d).ready_for_data,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_wstrb   => master_axi_write_mosi(%d).data_write_strobe,\n" % (padding, i, i))
            f.write("%sM%02d_AXI_0_wvalid  => master_axi_write_mosi(%d).data_valid,\n" % (padding, i, i))
            f.write("\n")


    print("NUM_MASTERS = %d" % nmasters)
    print("NUM_SLAVES = %d" % nslaves)
    MARKER_START = "----- Start : Generics"
    MARKER_END   = "----- End : Generics"
    insert_code (filename, filename, MARKER_START, MARKER_END, write_generics)

    MARKER_START = "----- Start : Masters"
    MARKER_END   = "----- End : Masters"
    insert_code (filename, filename, MARKER_START, MARKER_END, write_masters)

    MARKER_START = "----- Start : Slaves"
    MARKER_END   = "----- End : Slaves"
    insert_code (filename, filename, MARKER_START, MARKER_END, write_slaves)

filename = "../interconnect_wrapper.vhd"
if (len(sys.argv) != 3):
    print("Run as update_interconnect.py NUM_MASTERS NUM_SLAVES")
    sys.exit(1)
update_interconnect (filename, int(sys.argv[1]), int(sys.argv[2]))
