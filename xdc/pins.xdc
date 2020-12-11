set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-2 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]

set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

# PCIe connections
set_property PACKAGE_PIN AB6 [get_ports pcie_sys_clk_p];

#set_property PULLUP true [get_ports pcie_sys_rst_n]
set_property PACKAGE_PIN K22 [get_ports pcie_sys_rst];
set_property IOSTANDARD LVCMOS18 [get_ports pcie_sys_rst]
set_false_path -from [get_ports pcie_sys_rst]

set_property PACKAGE_PIN AB2 [get_ports {pcie_rx_p[0]}] ;
set_property PACKAGE_PIN AD2 [get_ports {pcie_rx_p[1]}] ;
set_property PACKAGE_PIN AF2 [get_ports {pcie_rx_p[2]}] ;
set_property PACKAGE_PIN AH2 [get_ports {pcie_rx_p[3]}] ;
set_property PACKAGE_PIN AJ3 [get_ports {pcie_rx_p[4]}] ;
set_property PACKAGE_PIN AK2 [get_ports {pcie_rx_p[5]}] ;
set_property PACKAGE_PIN AM2 [get_ports {pcie_rx_p[6]}] ;
set_property PACKAGE_PIN AP2 [get_ports {pcie_rx_p[7]}] ;

set_property PACKAGE_PIN AC4 [get_ports {pcie_tx_p[0]}] ;
set_property PACKAGE_PIN AE4 [get_ports {pcie_tx_p[1]}] ;
set_property PACKAGE_PIN AG4 [get_ports {pcie_tx_p[2]}] ;
set_property PACKAGE_PIN AH6 [get_ports {pcie_tx_p[3]}] ;
set_property PACKAGE_PIN AJ4 [get_ports {pcie_tx_p[4]}] ;
set_property PACKAGE_PIN AL4 [get_ports {pcie_tx_p[5]}] ;
set_property PACKAGE_PIN AM6 [get_ports {pcie_tx_p[6]}] ;
set_property PACKAGE_PIN AN4 [get_ports {pcie_tx_p[7]}] ;

# EXTERNAL OSCILLATOR:
# - based on an ICS8N4Q001L clock generator,
#   hard-wired to use the first frequency setting, which defaults to 170
#   MHz according to datasheet, or 200 MHz according to user guide and
#   schematics.
# - 1.8V differential signal
# - connected to an HR bank (-> use LVDS_25 instead of LVDS)
set_property IOSTANDARD LVDS [get_ports osc_clk_p]  ;
set_property PACKAGE_PIN G10 [get_ports osc_clk_p] ; # updated
set_property PACKAGE_PIN F10 [get_ports osc_clk_n] ; # updated

set_property PACKAGE_PIN AP8 [get_ports {leds[0]}];
set_property PACKAGE_PIN H23 [get_ports {leds[1]}];
set_property PACKAGE_PIN P20 [get_ports {leds[2]}];
set_property PACKAGE_PIN P21 [get_ports {leds[3]}];
set_property PACKAGE_PIN N22 [get_ports {leds[4]}];
set_property PACKAGE_PIN M22 [get_ports {leds[5]}];
set_property PACKAGE_PIN R23 [get_ports {leds[6]}];
set_property PACKAGE_PIN P23 [get_ports {leds[7]}];
set_property IOSTANDARD LVCMOS18 [get_ports {leds*}]

# refclks
set_property PACKAGE_PIN P6 [get_ports {si570_refclk_p}]; # bank 227 REFCLK0 QUADX0Y3
set_property PACKAGE_PIN V6 [get_ports {sma_refclk_p}]; # bank 226 REFCLK0

# bank 226
set_property PACKAGE_PIN U4 [get_ports {sfp_txp[0]}]; # bank 226
set_property PACKAGE_PIN W4 [get_ports {sfp_txp[1]}]; # bank 226

set_property PACKAGE_PIN T2 [get_ports {sfp_rxp[0]}]; # bank 226
set_property PACKAGE_PIN V2 [get_ports {sfp_rxp[1]}]; # bank 226

# bank 227
set_property PACKAGE_PIN N4 [get_ports {fmc_txp[0]}]; # bank 227
set_property PACKAGE_PIN L4 [get_ports {fmc_txp[1]}]; # bank 227
set_property PACKAGE_PIN J4 [get_ports {fmc_txp[2]}]; # bank 227
set_property PACKAGE_PIN G4 [get_ports {fmc_txp[3]}]; # bank 227
set_property PACKAGE_PIN F6 [get_ports {fmc_txp[4]}]; # bank 228
set_property PACKAGE_PIN D6 [get_ports {fmc_txp[5]}]; # bank 228
set_property PACKAGE_PIN C4 [get_ports {fmc_txp[6]}]; # bank 228
set_property PACKAGE_PIN B6 [get_ports {fmc_txp[7]}]; # bank 228

set_property PACKAGE_PIN M2 [get_ports {fmc_rxp[0]}]; # bank 227
set_property PACKAGE_PIN K2 [get_ports {fmc_rxp[1]}]; # bank 227
set_property PACKAGE_PIN H2 [get_ports {fmc_rxp[2]}]; # bank 227
set_property PACKAGE_PIN F2 [get_ports {fmc_rxp[3]}]; # bank 227
set_property PACKAGE_PIN E4 [get_ports {fmc_rxp[4]}]; # bank 228
set_property PACKAGE_PIN D2 [get_ports {fmc_rxp[5]}]; # bank 228
set_property PACKAGE_PIN B2 [get_ports {fmc_rxp[6]}]; # bank 228
set_property PACKAGE_PIN A4 [get_ports {fmc_rxp[7]}]; # bank 228
