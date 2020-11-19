library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity axi_interconnect is
  generic(
    ----- Start : Generics
     NUM_MASTERS : natural := 1;
     NUM_SLAVES  : natural := 2
     ----- End : Generics
    );
  port(

    clk  : in std_logic;
    rstn : in std_logic;

    master_axi_clk    : in std_logic_vector (NUM_MASTERS-1 downto 0);
    master_axi_resetn : in std_logic_vector (NUM_MASTERS-1 downto 0);

    slave_axi_clk    : in std_logic_vector (NUM_SLAVES-1 downto 0);
    slave_axi_resetn : in std_logic_vector (NUM_SLAVES-1 downto 0);

    master_axi_read_mosi  : axireadmosi_array_t (NUM_MASTERS - 1 downto 0);
    master_axi_read_miso  : axireadmiso_array_t (NUM_MASTERS - 1 downto 0);
    master_axi_write_mosi : axiwritemosi_array_t (NUM_MASTERS - 1 downto 0);
    master_axi_write_miso : axiwritemiso_array_t (NUM_MASTERS - 1 downto 0);

    axi_read_mosi  : axireadmosi_array_t (NUM_SLAVES - 1 downto 0);
    axi_read_miso  : axireadmiso_array_t (NUM_SLAVES - 1 downto 0);
    axi_write_mosi : axiwritemosi_array_t (NUM_SLAVES - 1 downto 0);
    axi_write_miso : axiwritemiso_array_t (NUM_SLAVES - 1 downto 0)

    );
end axi_interconnect;

architecture behavioral of axi_interconnect is

begin


  axi_interconnect_wrapper_1 : entity work.axi_interconnect_wrapper
    port map (

      ----- Start : Masters
      M00_ACLK_0    => master_axi_clk(0),
      M00_ARESETN_0 => master_axi_resetn(0),

      M00_AXI_0_araddr  => master_axi_read_mosi(0).address,
      M00_AXI_0_arprot  => master_axi_read_mosi(0).protection_type,
      M00_AXI_0_arready => master_axi_read_miso(0).ready_for_address,
      M00_AXI_0_arvalid => master_axi_read_mosi(0).address_valid,
      M00_AXI_0_awaddr  => master_axi_write_mosi(0).address,
      M00_AXI_0_awprot  => master_axi_write_mosi(0).protection_type,
      M00_AXI_0_awready => master_axi_write_miso(0).ready_for_address,
      M00_AXI_0_awvalid => master_axi_write_mosi(0).address_valid,
      M00_AXI_0_bready  => master_axi_write_mosi(0).ready_for_response,
      M00_AXI_0_bresp   => master_axi_write_miso(0).response,
      M00_AXI_0_bvalid  => master_axi_write_miso(0).response_valid,
      M00_AXI_0_rdata   => master_axi_read_miso(0).data,
      M00_AXI_0_rready  => master_axi_read_mosi(0).ready_for_data,
      M00_AXI_0_rresp   => master_axi_read_miso(0).response,
      M00_AXI_0_rvalid  => master_axi_read_miso(0).data_valid,
      M00_AXI_0_wdata   => master_axi_write_mosi(0).data,
      M00_AXI_0_wready  => master_axi_write_miso(0).ready_for_data,
      M00_AXI_0_wstrb   => master_axi_write_mosi(0).data_write_strobe,
      M00_AXI_0_wvalid  => master_axi_write_mosi(0).data_valid,

      ----- End : Masters

      ----- Start : Slaves
      S00_ACLK_0    => axi_clk(0),
      S00_ARESETN_0 => axi_resetn(0),

      S00_AXI_0_araddr  => axi_read_mosi(0).address,
      S00_AXI_0_arprot  => axi_read_mosi(0).protection_type,
      S00_AXI_0_arready => axi_read_miso(0).ready_for_address,
      S00_AXI_0_arvalid => axi_read_mosi(0).address_valid,
      S00_AXI_0_awaddr  => axi_write_mosi(0).address,
      S00_AXI_0_awprot  => axi_write_mosi(0).protection_type,
      S00_AXI_0_awready => axi_write_miso(0).ready_for_address,
      S00_AXI_0_awvalid => axi_write_mosi(0).address_valid,
      S00_AXI_0_bready  => axi_write_mosi(0).ready_for_response,
      S00_AXI_0_bresp   => axi_write_miso(0).response,
      S00_AXI_0_bvalid  => axi_write_miso(0).response_valid,
      S00_AXI_0_rdata   => axi_read_miso(0).data,
      S00_AXI_0_rready  => axi_read_mosi(0).ready_for_data,
      S00_AXI_0_rresp   => axi_read_miso(0).response,
      S00_AXI_0_rvalid  => axi_read_miso(0).data_valid,
      S00_AXI_0_wdata   => axi_write_mosi(0).data,
      S00_AXI_0_wready  => axi_write_miso(0).ready_for_data,
      S00_AXI_0_wstrb   => axi_write_mosi(0).data_write_strobe,
      S00_AXI_0_wvalid  => axi_write_mosi(0).data_valid,

      S01_ACLK_0    => axi_clk(1),
      S01_ARESETN_0 => axi_resetn(1),

      S01_AXI_0_araddr  => axi_read_mosi(1).address,
      S01_AXI_0_arprot  => axi_read_mosi(1).protection_type,
      S01_AXI_0_arready => axi_read_miso(1).ready_for_address,
      S01_AXI_0_arvalid => axi_read_mosi(1).address_valid,
      S01_AXI_0_awaddr  => axi_write_mosi(1).address,
      S01_AXI_0_awprot  => axi_write_mosi(1).protection_type,
      S01_AXI_0_awready => axi_write_miso(1).ready_for_address,
      S01_AXI_0_awvalid => axi_write_mosi(1).address_valid,
      S01_AXI_0_bready  => axi_write_mosi(1).ready_for_response,
      S01_AXI_0_bresp   => axi_write_miso(1).response,
      S01_AXI_0_bvalid  => axi_write_miso(1).response_valid,
      S01_AXI_0_rdata   => axi_read_miso(1).data,
      S01_AXI_0_rready  => axi_read_mosi(1).ready_for_data,
      S01_AXI_0_rresp   => axi_read_miso(1).response,
      S01_AXI_0_rvalid  => axi_read_miso(1).data_valid,
      S01_AXI_0_wdata   => axi_write_mosi(1).data,
      S01_AXI_0_wready  => axi_write_miso(1).ready_for_data,
      S01_AXI_0_wstrb   => axi_write_mosi(1).data_write_strobe,
      S01_AXI_0_wvalid  => axi_write_mosi(1).data_valid,

      ----- End : Slaves

      ACLK_0    => clk,
      ARESETN_0 => resetn


      );

end behavioral;
