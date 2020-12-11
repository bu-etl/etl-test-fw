library unisim;
use unisim.vcomponents.all;

library ctrl_lib;
use ctrl_lib.READOUT_BOARD_Ctrl.all;
use ctrl_lib.FW_INFO_Ctrl.all;
use ctrl_lib.MGT_Ctrl.all;

library work;
use work.types.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library ipbus;
use ipbus.ipbus.all;
use ipbus.ipbus_decode_etl_test_fw.all;

entity etl_test_fw is
  generic(
    SCAS_PER_LPGBT : integer := 1;
    NUM_SIMPLEX    : integer := 0;
    NUM_EMUL       : integer := 1;
    NUM_DUPLEX     : integer := 1;
    NUM_RBS        : integer := 1;
    NUM_TX         : integer := 2;
    NUM_RX         : integer := 2;

    NUM_SFP         : integer := 2;
    NUM_FMC         : integer := 8;
    NUM_LPGBTS_DAQ  : integer := 1;
    NUM_LPGBTS_TRIG : integer := 1;
    NUM_SCAS        : integer := 1;
    NUM_DOWNLINKS   : integer := 1;

    NUM_REFCLK : integer := 2
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
    si570_refclkp : in std_logic;
    si570_refclkn : in std_logic;

    sma_refclkp : in std_logic;
    sma_refclkn : in std_logic;

    sfp_txp : out std_logic_vector(NUM_SFP - 1 downto 0);
    sfp_txn : out std_logic_vector(NUM_SFP - 1 downto 0);
    sfp_rxp : in  std_logic_vector(NUM_SFP - 1 downto 0);
    sfp_rxn : in  std_logic_vector(NUM_SFP - 1 downto 0);

    fmc_txp : out std_logic_vector(NUM_FMC - 1 downto 0);
    fmc_txn : out std_logic_vector(NUM_FMC - 1 downto 0);
    fmc_rxp : in  std_logic_vector(NUM_FMC - 1 downto 0);
    fmc_rxn : in  std_logic_vector(NUM_FMC - 1 downto 0);

    -- status LEDs
    leds : out std_logic_vector(7 downto 0)

    );
end etl_test_fw;

architecture behavioral of etl_test_fw is

  constant NUM_GTS : integer := NUM_SFP + NUM_FMC;

  signal txp : std_logic_vector(NUM_GTS - 1 downto 0);
  signal txn : std_logic_vector(NUM_GTS - 1 downto 0);
  signal rxp : std_logic_vector(NUM_GTS - 1 downto 0);
  signal rxn : std_logic_vector(NUM_GTS - 1 downto 0);

  signal mgt_data_in  : std32_array_t (NUM_GTS-1 downto 0) := (others => (others => '0'));
  signal mgt_data_out : std32_array_t (NUM_GTS-1 downto 0);

  signal trig_uplink_mgt_word_array : std32_array_t (NUM_RBS*NUM_LPGBTS_TRIG-1 downto 0);
  signal daq_uplink_mgt_word_array  : std32_array_t (NUM_RBS*NUM_LPGBTS_DAQ-1 downto 0);
  signal downlink_mgt_word_array    : std32_array_t (NUM_RBS*NUM_DOWNLINKS-1 downto 0);

  signal clk40, clk320 : std_logic := '0';
  signal reset         : std_logic := '0';

  signal ipb_clk, ipb_rst : std_logic;
  signal nuke, soft_rst   : std_logic;
  signal pcie_sys_rst_n   : std_logic;

  signal ipb_w : ipb_wbus;
  signal ipb_r : ipb_rbus;

  signal refclkp : std_logic_vector(NUM_REFCLK - 1 downto 0);
  signal refclkn : std_logic_vector(NUM_REFCLK - 1 downto 0);
  signal refclk   : std_logic_vector (NUM_REFCLK-1 downto 0);

  -- control and monitoring
  signal readout_board_mon  : READOUT_BOARD_Mon_array_t (NUM_RBS-1 downto 0);
  signal readout_board_ctrl : READOUT_BOARD_Ctrl_array_t (NUM_RBS-1 downto 0);

  signal mgt_mon  : MGT_Mon_t;
  signal mgt_ctrl : MGT_Ctrl_t;

  signal fw_info_mon : FW_INFO_Mon_t;

begin

  txp <= fmc_txp & sfp_txp;
  rxp <= fmc_txp & sfp_txp;

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


  system_clocks_inst : entity work.system_clocks
    port map (
      reset     => std_logic0,
      clk_in1_p => osc_clk_p,
      clk_in1_n => osc_clk_n,
      clk_40    => clk40,
      clk_320   => clk320,
      locked    => open
      );


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
      mgt_mon            => mgt_mon,
      mgt_ctrl           => mgt_ctrl,
      ipb_w              => ipb_w,
      ipb_r              => ipb_r
      );

  refclkp(0) <= si570_refclkp;
  refclkn(0) <= si570_refclkn;
  refclkp(1) <= sma_refclkp;
  refclkn(1) <= sma_refclkn;

  refclkgen_inst : for I in 0 to NUM_REFCLK-1 generate
  begin
    refclk_ibufds : ibufds_gte3
      generic map(
        REFCLK_EN_TX_PATH  => '0',
        REFCLK_HROW_CK_SEL => (others => '0'),
        REFCLK_ICNTL_RX    => (others => '0')
        )
      port map (
        O     => refclk(I),
        ODIV2 => open,
        CEB   => '0',
        I     => refclkp(I),
        IB    => refclkn(I)
        );

  end generate;

  mgt_wrapper_inst : entity work.mgt_wrapper
    generic map (
      NUM_GTS => NUM_GTS
      )
    port map (
      drp_clk => clk40,
      rxp_in  => rxp,
      rxn_in  => rxn,

      txp_out => txp,
      txn_out => txn,

      data_in  => mgt_data_in,
      data_out => mgt_data_out,

      gtrefclk00_in => (others => refclk(0)),

      mon  => mgt_mon,
      ctrl => mgt_ctrl

      );
end behavioral;
