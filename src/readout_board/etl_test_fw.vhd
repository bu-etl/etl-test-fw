library ctrl_lib;
use ctrl_lib.READOUT_BOARD_Ctrl.all;
use ctrl_lib.FW_INFO_Ctrl.all;

library work;
use work.types.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library ipbus;
use ipbus.ipbus.all;

entity etl_test_fw is
  generic(
    NSLAVES        : integer := 1;
    SCAS_PER_LPGBT : integer := 1;
    NUM_SIMPLEX    : integer := 0;
    NUM_EMUL       : integer := 1;
    NUM_DUPLEX     : integer := 1;
    NUM_RBS        : integer := 1;
    NUM_TX         : integer := 2;
    NUM_RX         : integer := 2;

    NUM_LPGBTS_DAQ  : integer := 1;
    NUM_LPGBTS_TRIG : integer := 1;
    NUM_SCAS        : integer := 1;
    NUM_DOWNLINKS   : integer := 1;

    NUM_REFCLK : integer := 1
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

  signal trig_uplink_mgt_word_array : std32_array_t (NUM_RBS*NUM_LPGBTS_TRIG-1 downto 0);
  signal daq_uplink_mgt_word_array  : std32_array_t (NUM_RBS*NUM_LPGBTS_DAQ-1 downto 0);
  signal downlink_mgt_word_array    : std32_array_t (NUM_RBS*NUM_DOWNLINKS-1 downto 0);

  signal readout_board_mon  : READOUT_BOARD_Mon_array_t (NUM_RBS-1 downto 0);
  signal readout_board_ctrl : READOUT_BOARD_Ctrl_array_t (NUM_RBS-1 downto 0);

  signal fw_info_mon  : FW_INFO_Mon_t;

  signal clk40, clk320 : std_logic := '0';
  signal reset         : std_logic := '0';

  signal ipb_clk, ipb_rst : std_logic;
  signal nuke, soft_rst   : std_logic;
  signal pcie_sys_rst_n   : std_logic;

  signal ipb_w : ipb_wbus;
  signal ipb_r  : ipb_rbus;

  signal gtwiz_userclk_tx_reset_in          : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_tx_srcclk_out        : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_tx_usrclk_out        : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_tx_usrclk2_out       : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_tx_active_out        : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_rx_reset_in          : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_rx_srcclk_out        : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_rx_usrclk_out        : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_rx_usrclk2_out       : std_logic_vector(0 downto 0);
  signal gtwiz_userclk_rx_active_out        : std_logic_vector(0 downto 0);
  signal gtwiz_reset_clk_freerun_in         : std_logic_vector(0 downto 0);
  signal gtwiz_reset_all_in                 : std_logic_vector(0 downto 0);
  signal gtwiz_reset_tx_pll_and_datapath_in : std_logic_vector(0 downto 0);
  signal gtwiz_reset_tx_datapath_in         : std_logic_vector(0 downto 0);
  signal gtwiz_reset_rx_pll_and_datapath_in : std_logic_vector(0 downto 0);
  signal gtwiz_reset_rx_datapath_in         : std_logic_vector(0 downto 0);
  signal gtwiz_reset_rx_cdr_stable_out      : std_logic_vector(0 downto 0);
  signal gtwiz_reset_tx_done_out            : std_logic_vector(0 downto 0);
  signal gtwiz_reset_rx_done_out            : std_logic_vector(0 downto 0);
  signal gtwiz_userdata_tx_in               : std_logic_vector(319 downto 0);
  signal gtwiz_userdata_rx_out              : std_logic_vector(319 downto 0);
  signal gtrefclk00_in                      : std_logic_vector(2 downto 0);
  signal qpll0outclk_out                    : std_logic_vector(2 downto 0);
  signal qpll0outrefclk_out                 : std_logic_vector(2 downto 0);
  signal gthrxn_in                          : std_logic_vector(9 downto 0);
  signal gthrxp_in                          : std_logic_vector(9 downto 0);
  signal gthtxn_out                         : std_logic_vector(9 downto 0);
  signal gthtxp_out                         : std_logic_vector(9 downto 0);
  signal gtpowergood_out                    : std_logic_vector(9 downto 0);
  signal rxpmaresetdone_out                 : std_logic_vector(9 downto 0);
  signal txpmaresetdone_out                 : std_logic_vector(9 downto 0);

begin

  nuke           <= '0';
  soft_rst       <= '0';
  pcie_sys_rst_n <= not pcie_sys_rst;

  leds(3 downto 2) <= "00";
  leds(7 downto 3) <= "00000";


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
      --leds           => leds(1 downto 0),
      ipb_in         => ipb_r,
      ipb_out        => ipb_w
      );


  rbgen : for I in 0 to NUM_RBS-1 generate
    constant NT : integer := NUM_LPGBTS_TRIG;
    constant ND : integer := NUM_LPGBTS_DAQ;
  begin
    readout_board_inst : entity work.readout_board
      generic map (
        NUM_LPGBTS_DAQ  => NUM_LPGBTS_DAQ,
        NUM_LPGBTS_TRIG => NUM_LPGBTS_TRIG,
        NUM_DOWNLINKS   => NUM_DOWNLINKS,
        NUM_SCAS        => NUM_SCAS
        )
      port map (
        clk40                      => clk40,
        clk320                     => clk320,
        reset                      => reset,
        mon                        => readout_board_mon(I),
        ctrl                       => readout_board_ctrl(I),
        trig_uplink_mgt_word_array => trig_uplink_mgt_word_array(NT*(I+1)-1 downto NT*I),
        daq_uplink_mgt_word_array  => daq_uplink_mgt_word_array(ND*(I+1)-1 downto ND*I),
        downlink_mgt_word_array    => downlink_mgt_word_array(I downto I)
        );
  end generate;

  control_inst : entity work.control
    generic map (
      NUM_RBS => NUM_RBS
      )
    port map (
      reset              => reset,
      clock              => clk40,
      fw_info_mon        => fw_info_mon,
      readout_board_mon  => readout_board_mon,
      readout_board_ctrl => readout_board_ctrl,
      ipb_w              => ipb_w,
      ipb_r              => ipb_r
      );


  mgt_wrapper_inst : entity work.mgt_wrapper
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
