library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library lpgbt_fpga;
use lpgbt_fpga.lpgbtfpga_package.all;

library ctrl_lib;
use ctrl_lib.READOUT_BOARD_ctrl.all;

library work;
use work.types.all;
use work.lpgbt_pkg.all;

entity readout_board is
  generic(
    NUM_LPGBTS_DAQ  : integer := 1;
    NUM_LPGBTS_TRIG : integer := 1;
    NUM_DOWNLINKS   : integer := 1;
    NUM_SCAS        : integer := 1
    );
  port(

    clk40  : in std_logic;
    clk320 : in std_logic;

    reset : in std_logic;

    mon   : out  READOUT_BOARD_MON_t;
    ctrl  : in READOUT_BOARD_CTRL_t;

    trig_uplink_mgt_word_array : in  std32_array_t (NUM_LPGBTS_TRIG-1 downto 0);
    daq_uplink_mgt_word_array  : in  std32_array_t (NUM_LPGBTS_DAQ-1 downto 0);
    downlink_mgt_word_array    : out std32_array_t (NUM_DOWNLINKS-1 downto 0)

    );
end readout_board;

architecture behavioral of readout_board is

  --------------------------------------------------------------------------------
  -- LPGBT Glue
  --------------------------------------------------------------------------------

  signal trig_uplink_data    : lpgbt_uplink_data_rt_array (NUM_LPGBTS_TRIG-1 downto 0);
  signal trig_uplink_reset   : std_logic_vector (NUM_LPGBTS_TRIG-1 downto 0);
  signal trig_uplink_ready   : std_logic_vector (NUM_LPGBTS_TRIG-1 downto 0);
  signal trig_uplink_bitslip : std_logic_vector (NUM_LPGBTS_TRIG-1 downto 0);
  signal trig_uplink_fec_err : std_logic_vector (NUM_LPGBTS_TRIG-1 downto 0);

  signal daq_uplink_data    : lpgbt_uplink_data_rt_array (NUM_LPGBTS_DAQ-1 downto 0);
  signal daq_uplink_reset   : std_logic_vector (NUM_LPGBTS_DAQ-1 downto 0);
  signal daq_uplink_ready   : std_logic_vector (NUM_LPGBTS_DAQ-1 downto 0);
  signal daq_uplink_bitslip : std_logic_vector (NUM_LPGBTS_DAQ-1 downto 0);
  signal daq_uplink_fec_err : std_logic_vector (NUM_LPGBTS_DAQ-1 downto 0);

  signal downlink_data  : lpgbt_downlink_data_rt_array (NUM_DOWNLINKS-1 downto 0);
  signal downlink_reset : std_logic_vector (NUM_DOWNLINKS-1 downto 0);
  signal downlink_ready : std_logic_vector (NUM_DOWNLINKS-1 downto 0);

  attribute MARK_DEBUG                     : string;
  attribute MARK_DEBUG of trig_uplink_data : signal is "TRUE";
  attribute MARK_DEBUG of daq_uplink_data  : signal is "TRUE";
  attribute MARK_DEBUG of downlink_data    : signal is "TRUE";

  -- FIXME: connect these

  -- master
  signal ic_data_i : std_logic_vector (1 downto 0);
  signal ic_data_o : std_logic_vector (1 downto 0);

  signal sca0_data_i : std_logic_vector (1 downto 0);
  signal sca0_data_o : std_logic_vector (1 downto 0);

begin

  gbt_controller_wrapper_inst : entity work.gbt_controller_wrapper
    generic map (
      g_CLK_FREQ       => 40,
      g_SCAS_PER_LPGBT => NUM_SCAS
      )
    port map (
      reset_i     => reset,
      mon         => mon.sc,
      ctrl        => ctrl.sc,
      clk320      => clk320,
      clk40       => clk40,
      valid_i     => '1',

      -- FIXME: parameterize these outputs in an array to avoid hardcoded sizes
      ic_data_i   => ic_data_i,
      ic_data_o   => ic_data_o,

      sca0_data_i => sca0_data_i,
      sca0_data_o => sca0_data_o
      );

  lpgbt_link_wrapper : entity work.lpgbt_link_wrapper
    generic map (
      g_UPLINK_FEC       => FEC5,
      g_NUM_DOWNLINKS    => NUM_DOWNLINKS,
      g_NUM_UPLINKS      => NUM_LPGBTS_DAQ,
      g_PIPELINE_BITSLIP => true,
      g_PIPELINE_LPGBT   => true,
      g_PIPELINE_MGT     => true
      )
    port map (
      reset => reset,

      downlink_clk => clk320,
      uplink_clk   => clk320,

      downlink_reset_i => (others => reset),
      uplink_reset_i   => (others => reset),

      downlink_data_i => downlink_data,
      uplink_data_o   => daq_uplink_data,

      downlink_mgt_word_array_o => downlink_mgt_word_array,
      uplink_mgt_word_array_i   => daq_uplink_mgt_word_array,

      downlink_ready_o => downlink_ready,
      uplink_ready_o   => daq_uplink_ready,

      uplink_bitslip_o => daq_uplink_bitslip,
      uplink_fec_err_o => daq_uplink_fec_err
      );

  trig_lpgbt_link_wrapper : entity work.lpgbt_link_wrapper
    generic map (
      g_UPLINK_FEC       => FEC5,
      g_NUM_DOWNLINKS    => 0,
      g_NUM_UPLINKS      => NUM_LPGBTS_TRIG,
      g_PIPELINE_BITSLIP => true,
      g_PIPELINE_LPGBT   => true,
      g_PIPELINE_MGT     => true
      )
    port map (
      reset => reset,

      downlink_clk => clk320,
      uplink_clk   => clk320,

      downlink_reset_i => (others => reset),
      uplink_reset_i   => (others => reset),

      downlink_data_i => (others => lpgbt_downlink_data_rt_zero),
      uplink_data_o   => trig_uplink_data,

      downlink_mgt_word_array_o => open,
      uplink_mgt_word_array_i   => trig_uplink_mgt_word_array,

      downlink_ready_o => open,
      uplink_ready_o   => trig_uplink_ready,

      uplink_bitslip_o => trig_uplink_bitslip,
      uplink_fec_err_o => trig_uplink_fec_err
      );

end behavioral;
