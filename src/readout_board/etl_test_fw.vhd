
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library ipbus;
use ipbus.ipbus.all;

--use work.types_pkg.all;
--use work.ipbus_pkg.all;

entity etl_test_fw is
  generic(
    SCAS_PER_LPGBT : integer := 1;
    NUM_SIMPLEX    : integer := 0;
    NUM_EMUL       : integer := 1;
    NUM_DUPLEX     : integer := 1;
    NUM_TX         : integer := 2;
    NUM_RX         : integer := 2;
    NUM_REFCLK     : integer := 1
    );
  port(

    -- PCIe clock and reset
    pcie_sys_clk_p : in std_logic;
    pcie_sys_clk_n : in std_logic;
    pcie_sys_rst   : in std_logic;

    -- PCIe lanes
    pcie_rx_p : in  std_logic_vector(0 downto 0);
    pcie_rx_n : in  std_logic_vector(0 downto 0);
    pcie_tx_p : out std_logic_vector(0 downto 0);
    pcie_tx_n : out std_logic_vector(0 downto 0);

    -- external oscillator
    osc_clk_p : in std_logic;
    osc_clk_n : in std_logic;

    -- Transceiver ref-clocks
    refclkp : in  std_logic_vector(NUM_REFCLK - 1 downto 0);
    refclkn : in  std_logic_vector(NUM_REFCLK - 1 downto 0);
    txp     : out std_logic_vector(NUM_TX - 1 downto 0);
    txn     : out std_logic_vector(NUM_TX - 1 downto 0);
    rxp     : in  std_logic_vector(NUM_RX - 1 downto 0);
    rxn     : in  std_logic_vector(NUM_RX - 1 downto 0);

    -- status LEDs
    leds : out std_logic_vector(7 downto 0)

    );
end etl_test_fw;

architecture behavioral of etl_test_fw is

  signal ipb_clk, ipb_rst : std_logic;
  signal nuke, soft_rst   : std_logic;
  signal pcie_sys_rst_n   : std_logic;

  signal ipb_out : ipb_wbus;
  signal ipb_in  : ipb_rbus;

  signal ipb_w_array : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipb_r_array : ipb_rbus_array(N_SLAVES - 1 downto 0);

begin

  nuke     <= '0';
  soft_rst <= '0';
  pcie_sys_rst_n <= not pcie_sys_rst;

  leds(3 downto 2) <= "00";
  leds(7 downto 3) <= "0000";


  -- Infrastructure

  infra : entity ipbus.k800_infra
    port map(
      pcie_sys_clk_p => pcie_sys_clk_p,
      pcie_sys_clk_n => pcie_sys_clk_n,
      pcie_sys_rst_n => pcie_sys_rst_n,
      pcie_rx_p      => pcie_rx_p,
      pcie_rx_n      => pcie_rx_n,
      pcie_tx_p      => pcie_tx_p,
      pcie_tx_n      => pcie_tx_n,
      osc_clk_p      => osc_clk_p,
      osc_clk_n      => osc_clk_n,
      ipb_clk        => ipb_clk,
      ipb_rst        => ipb_rst,
      nuke           => nuke,
      soft_rst       => soft_rst,
      leds           => leds(1 downto 0),
      ipb_in         => ipb_in,
      ipb_out        => ipb_out
      );

  -- ipbus fabric selector

  fabric : entity ipbus.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in          => ipb_w,
      ipb_out         => ipb_r,
      sel             => ipbus_sel_top_emp_slim(ipb_w.ipb_addr),
      ipb_to_slaves   => ipb_w_array,
      ipb_from_slaves => ipb_r_array
      );

  readout_board_1 : entity work.readout_board
    generic map (
      NUM_LPGBTS_DAQ  => NUM_LPGBTS_DAQ,
      NUM_LPGBTS_TRIG => NUM_LPGBTS_TRIG,
      NUM_DOWNLINKS   => NUM_DOWNLINKS,
      NUM_SCAS        => NUM_SCAS)
    port map (
      clock                      => clock,
      clk40                      => clk40,
      clk320                     => clk320,
      reset                      => reset,
      clock_ipb                  => clock_ipb,
      ipb_mosi_i                 => ipb_mosi_i,
      ipb_miso_o                 => ipb_miso_o,
      trig_uplink_mgt_word_array => trig_uplink_mgt_word_array,
      daq_uplink_mgt_word_array  => daq_uplink_mgt_word_array,
      downlink_mgt_word_array    => downlink_mgt_word_array);

  mgt_wrapper_1: entity work.mgt_wrapper
    port map (
      gtwiz_userclk_tx_reset_in          => gtwiz_userclk_tx_reset_in,
      gtwiz_userclk_tx_srcclk_out        => gtwiz_userclk_tx_srcclk_out,
      gtwiz_userclk_tx_usrclk_out        => gtwiz_userclk_tx_usrclk_out,
      gtwiz_userclk_tx_usrclk2_out       => gtwiz_userclk_tx_usrclk2_out,
      gtwiz_userclk_tx_active_out        => gtwiz_userclk_tx_active_out,
      gtwiz_userclk_rx_reset_in          => gtwiz_userclk_rx_reset_in,
      gtwiz_userclk_rx_srcclk_out        => gtwiz_userclk_rx_srcclk_out,
      gtwiz_userclk_rx_usrclk_out        => gtwiz_userclk_rx_usrclk_out,
      gtwiz_userclk_rx_usrclk2_out       => gtwiz_userclk_rx_usrclk2_out,
      gtwiz_userclk_rx_active_out        => gtwiz_userclk_rx_active_out,
      gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
      gtwiz_reset_all_in                 => gtwiz_reset_all_in,
      gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
      gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
      gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
      gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
      gtwiz_reset_rx_cdr_stable_out      => gtwiz_reset_rx_cdr_stable_out,
      gtwiz_reset_tx_done_out            => gtwiz_reset_tx_done_out,
      gtwiz_reset_rx_done_out            => gtwiz_reset_rx_done_out,
      gtwiz_userdata_tx_in               => gtwiz_userdata_tx_in,
      gtwiz_userdata_rx_out              => gtwiz_userdata_rx_out,
      gtrefclk00_in                      => gtrefclk00_in,
      qpll0outclk_out                    => qpll0outclk_out,
      qpll0outrefclk_out                 => qpll0outrefclk_out,
      gthrxn_in                          => gthrxn_in,
      gthrxp_in                          => gthrxp_in,
      gthtxn_out                         => gthtxn_out,
      gthtxp_out                         => gthtxp_out,
      gtpowergood_out                    => gtpowergood_out,
      rxpmaresetdone_out                 => rxpmaresetdone_out,
      txpmaresetdone_out                 => txpmaresetdone_out
      );

end behavioral;
