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

    NUM_RBS : integer := 5;             -- Number of readout boards

    NUM_SFP : integer := 2;             -- Number of SFP fibers
    NUM_FMC : integer := 8;             -- Number of FMC fibers

    NUM_LPGBTS_DAQ  : integer := 1;     -- Number of DAQ / Rb
    NUM_LPGBTS_TRIG : integer := 1;     -- Number of Trig / Rb
    NUM_DOWNLINKS   : integer := 1;     -- Number of Downlinks / Rb
    NUM_SCAS        : integer := 1;     -- Number of SCAs / Downlink

    NUM_REFCLK : integer := 2;

    -- these generics get set by hog at synthesis
    GLOBAL_FWDATE       : std_logic_vector (31 downto 0) := x"00000000";
    GLOBAL_FWTIME       : std_logic_vector (31 downto 0) := x"00000000";
    OFFICIAL            : std_logic_vector (31 downto 0) := x"00000000";
    GLOBAL_FWHASH       : std_logic_vector (31 downto 0) := x"00000000";
    TOP_FWHASH          : std_logic_vector (31 downto 0) := x"00000000";
    XML_HASH            : std_logic_vector (31 downto 0) := x"00000000";
    GLOBAL_FWVERSION    : std_logic_vector (31 downto 0) := x"00000000";
    TOP_FWVERSION       : std_logic_vector (31 downto 0) := x"00000000";
    XML_VERSION         : std_logic_vector (31 downto 0) := x"00000000";
    HOG_FWHASH          : std_logic_vector (31 downto 0) := x"00000000";
    FRAMEWORK_FWVERSION : std_logic_vector (31 downto 0) := x"00000000";
    FRAMEWORK_FWHASH    : std_logic_vector (31 downto 0) := x"00000000"
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
    si570_refclk_p : in std_logic;
    si570_refclk_n : in std_logic;

    sma_refclk_p : in std_logic;
    sma_refclk_n : in std_logic;

--    sfp_tx_p : out std_logic_vector(NUM_SFP - 1 downto 0);
--    sfp_tx_n : out std_logic_vector(NUM_SFP - 1 downto 0);
--    sfp_rx_p : in  std_logic_vector(NUM_SFP - 1 downto 0);
--    sfp_rx_n : in  std_logic_vector(NUM_SFP - 1 downto 0);
--
--    fmc_tx_p : out std_logic_vector(NUM_FMC - 1 downto 0);
--    fmc_tx_n : out std_logic_vector(NUM_FMC - 1 downto 0);
--    fmc_rx_p : in  std_logic_vector(NUM_FMC - 1 downto 0);
--    fmc_rx_n : in  std_logic_vector(NUM_FMC - 1 downto 0);

    -- status LEDs
    leds : out std_logic_vector(7 downto 0)

    );
end etl_test_fw;

architecture behavioral of etl_test_fw is

  signal locked : std_logic;

  signal clk_osc : std_logic;

  constant NUM_GTS : integer := NUM_SFP + NUM_FMC;

  signal tx_p : std_logic_vector(NUM_GTS - 1 downto 0);
  signal tx_n : std_logic_vector(NUM_GTS - 1 downto 0);
  signal rx_p : std_logic_vector(NUM_GTS - 1 downto 0);
  signal rx_n : std_logic_vector(NUM_GTS - 1 downto 0);

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

  signal refclk_p : std_logic_vector(NUM_REFCLK - 1 downto 0);
  signal refclk_n : std_logic_vector(NUM_REFCLK - 1 downto 0);
  signal refclk   : std_logic_vector (NUM_REFCLK-1 downto 0);

  -- control and monitoring
  signal readout_board_mon  : READOUT_BOARD_Mon_array_t (NUM_RBS-1 downto 0);
  signal readout_board_ctrl : READOUT_BOARD_Ctrl_array_t (NUM_RBS-1 downto 0);

  signal mgt_mon  : MGT_Mon_t;
  signal mgt_ctrl : MGT_Ctrl_t;

  signal fw_info_mon : FW_INFO_Mon_t;

  component cylon1 is
    port (
      clock : in  std_logic;
      rate  : in  std_logic_vector (1 downto 0);
      q     : out std_logic_vector (7 downto 0)
      );
  end component;

  signal cylon : std_logic_vector (7 downto 0);

  component system_clocks is
    port (
      reset     : in  std_logic;
      clk_in300 : in  std_logic;
      clk_40    : out std_logic;
      clk_320   : out std_logic;
      locked    : out std_logic
      );
  end component;

  attribute MARK_DEBUG           : string;
  attribute MARK_DEBUG of locked : signal is "TRUE";

begin

  cylon1_inst : cylon1
    port map (
      clock => clk40,
      rate  => "00",
      q     => cylon
      );

  nuke           <= '0';
  soft_rst       <= '0';
  pcie_sys_rst_n <= not pcie_sys_rst;

  leds(7 downto 0) <= cylon (7 downto 0);

  osc_clk_ibuf : IBUFDS
    port map(
      i  => osc_clk_p,
      ib => osc_clk_n,
      o  => clk_osc
      );
  -- Infrastructure

  infra : entity ipbus.pcie_infra
    port map(
      pcie_sys_clk_p => pcie_sys_clk_p,
      pcie_sys_clk_n => pcie_sys_clk_n,
      pcie_sys_rst_n => pcie_sys_rst_n,
      pcie_rx_p      => pcie_rx_p,
      pcie_rx_n      => pcie_rx_n,
      pcie_tx_p      => pcie_tx_p,
      pcie_tx_n      => pcie_tx_n,
      clk_osc        => clk_osc,
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

  system_clocks_inst : system_clocks
    port map (
      reset     => std_logic0,
      clk_in300 => clk_osc,
      clk_40    => clk40,
      clk_320   => clk320,
      locked    => locked
      );

  control_inst : entity work.control
    generic map (
      NUM_RBS => NUM_RBS
      )
    port map (
      reset              => ipb_rst,
      clock              => ipb_clk,
      fw_info_mon        => fw_info_mon,
      readout_board_mon  => readout_board_mon,
      readout_board_ctrl => readout_board_ctrl,
      mgt_mon            => mgt_mon,
      mgt_ctrl           => mgt_ctrl,
      ipb_w              => ipb_w,
      ipb_r              => ipb_r
      );

  refclk_p(0) <= si570_refclk_p;
  refclk_n(0) <= si570_refclk_n;
  refclk_p(1) <= sma_refclk_p;
  refclk_n(1) <= sma_refclk_n;

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
        I     => refclk_p(I),
        IB    => refclk_n(I)
        );

  end generate;

  --fmc_tx_p <= tx_p(9 downto 2);
  --fmc_tx_n <= tx_p(9 downto 2);
  --sfp_tx_p <= tx_p(1 downto 0);
  --sfp_tx_n <= tx_p(1 downto 0);
  --rx_p <= fmc_rx_p & sfp_rx_p;
  --rx_n <= fmc_rx_n & sfp_rx_n;

  -- FIXME: map this correctly
  rbdata : for I in 0 to NUM_RBS-1 generate
  begin
    mgt_data_in(I*2)              <= downlink_mgt_word_array(I);
    mgt_data_in(I*2+1)            <= downlink_mgt_word_array(I);
    trig_uplink_mgt_word_array(I) <= mgt_data_out(I*2);
    daq_uplink_mgt_word_array(I)  <= mgt_data_out(I*2+1);
  end generate;

  mgt_wrapper_inst : entity work.mgt_wrapper
    generic map (
      NUM_GTS => NUM_GTS
      )
    port map (
      drp_clk => ipb_clk,
      rxp_in  => rx_p,
      rxn_in  => rx_n,

      txp_out => tx_p,
      txn_out => tx_n,

      data_in  => mgt_data_in,
      data_out => mgt_data_out,

      gtrefclk00_in => (others => refclk(0)),

      rxslide_in => (others => '0'),

      mon  => mgt_mon,
      ctrl => mgt_ctrl

      );

  fw_info_mon.HOG_INFO.GLOBAL_FWDATE       <= GLOBAL_FWDATE;
  fw_info_mon.HOG_INFO.GLOBAL_FWTIME       <= GLOBAL_FWTIME;
  fw_info_mon.HOG_INFO.OFFICIAL            <= OFFICIAL;
  fw_info_mon.HOG_INFO.GLOBAL_FWHASH       <= GLOBAL_FWHASH;
  fw_info_mon.HOG_INFO.TOP_FWHASH          <= TOP_FWHASH;
  fw_info_mon.HOG_INFO.XML_HASH            <= XML_HASH;
  fw_info_mon.HOG_INFO.GLOBAL_FWVERSION    <= GLOBAL_FWVERSION;
  fw_info_mon.HOG_INFO.TOP_FWVERSION       <= TOP_FWVERSION;
  fw_info_mon.HOG_INFO.XML_VERSION         <= XML_VERSION;
  fw_info_mon.HOG_INFO.HOG_FWHASH          <= HOG_FWHASH;
  fw_info_mon.HOG_INFO.FRAMEWORK_FWVERSION <= FRAMEWORK_FWVERSION;
  fw_info_mon.HOG_INFO.FRAMEWORK_FWHASH    <= FRAMEWORK_FWHASH;

end behavioral;
