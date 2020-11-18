library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library hal;
use hal.lpgbt_pkg.all;
use hal.system_types_pkg.all;
use hal.constants_pkg.all;
use hal.board_pkg.all;
use hal.board_pkg_common.all;

library lpgbt_emul;
use lpgbt_emul.all;

entity lpgbtemul_wrapper is
  generic(
    g_NUM_LPGBT_EMUL_UPLINKS   : integer := 0;
    g_NUM_LPGBT_EMUL_DOWNLINKS : integer := 0;
    g_BYPASS_INTERLEAVER       : integer := 0;
    g_BYPASS_FEC               : integer := 0;
    g_BYPASS_SCRAMBLER         : integer := 0
    );
  port(

    reset : in std_logic;

    --------------------------------------------------------------------------------
    -- Uplink 10.24 Gbps
    --------------------------------------------------------------------------------

    -- 320 MHz Uplink Fabric Clock
    lpgbt_uplink_clk_i : in std_logic;  -- 320 MHz

    -- 32 bit mgt data @ 320 MHz
    lpgbt_uplink_mgt_word_array_o : out std32_array_t (g_NUM_LPGBT_EMUL_UPLINKS-1 downto 0);

    -- 1 bit valid output (strobes at 40MHz)
    -- 224 bits / bx to fabric
    -- 2 bits ic
    -- 2 bits ec

    lpgbt_uplink_data_i : in lpgbt_uplink_data_rt_array (g_NUM_LPGBT_EMUL_UPLINKS-1 downto 0);

    lpgbt_uplink_ready_o : out std_logic_vector (g_NUM_LPGBT_EMUL_UPLINKS-1 downto 0);

    lpgbt_rst_uplink_i : in std_logic_vector (g_NUM_LPGBT_EMUL_UPLINKS-1 downto 0);

    --------------------------------------------------------------------------------
    -- Downlink 2.56 Gbps
    --------------------------------------------------------------------------------

    -- 320 Mhz Downlink Fabric Clock
    lpgbt_downlink_clk_i : in std_logic;

    -- 32 bit lpgbt formatted data to mgt @ 40MHz
    lpgbt_downlink_mgt_word_array_i : in std32_array_t (g_NUM_LPGBT_EMUL_DOWNLINKS-1 downto 0);

    -- 1 bit valid (strobe at 40MHz)
    -- 32 bits / bx from fabric
    -- 2 bits ic
    -- 2 bits ec
    lpgbt_downlink_data_o : out lpgbt_downlink_data_rt_array (g_NUM_LPGBT_EMUL_DOWNLINKS-1 downto 0);

    lpgbt_downlink_ready_o : out std_logic_vector (g_NUM_LPGBT_EMUL_DOWNLINKS-1 downto 0);

    -- bitslip flag to connect to mgt rxslide for alignment
    lpgbt_downlink_bitslip_o : out std_logic_vector (g_NUM_LPGBT_EMUL_DOWNLINKS-1 downto 0);

    lpgbt_rst_downlink_i : in std_logic_vector (g_NUM_LPGBT_EMUL_DOWNLINKS-1 downto 0)
    );
end lpgbtemul_wrapper;

architecture Behavioral of lpgbtemul_wrapper is

begin

  assert (g_NUM_LPGBT_EMUL_UPLINKS = g_NUM_LPGBT_EMUL_DOWNLINKS) report "You must set lpgbt emul uplinks equal to the number of downlinks. no assymetry allowed" severity error;

  mgt_gen : for I in 0 to g_NUM_MGTS-1 generate
    constant idx : integer := emul_idx_array(I);
  begin
    emul_gen : if (idx /= -1) generate
    begin
      lpgbtemul_top_inst : entity lpgbt_emul.lpgbtemul_top
        generic map (
          rxslide_pulse_duration => 2,
          FEC_MODE               => std_logic0,  -- 0 = fec5, 1 = fec12
          rxslide_pulse_delay    => 128
          )
        port map (
          rst_downlink_i => lpgbt_rst_downlink_i(idx),
          rst_uplink_i   => lpgbt_rst_uplink_i(idx),

          downlinkclken_o             => lpgbt_downlink_data_o(idx).valid,
          downlinkdatagroup0          => lpgbt_downlink_data_o(idx).data(15 downto 0),
          downlinkdatagroup1          => lpgbt_downlink_data_o(idx).data(31 downto 16),
          downlinkdataec              => lpgbt_downlink_data_o(idx).ec,
          downlinkdataic              => lpgbt_downlink_data_o(idx).ic,
          downlinkbypassdeinterleaver => g_BYPASS_INTERLEAVER,
          downlinkbypassfecdecoder    => g_BYPASS_FEC,
          downlinkbypassdescsrambler  => g_BYPASS_SCRAMBLER,
          enablefecerrcounter         => std_logic1,
          feccorrectioncount          => open,
          downlinkrdy_o               => lpgbt_downlink_ready_o(idx),

          uplinkclken_i => lpgbt_uplink_data_i(idx).valid,
          uplinkdata0   => lpgbt_uplink_data_i(idx).data(31 downto 0),
          uplinkdata1   => lpgbt_uplink_data_i(idx).data(63 downto 32),
          uplinkdata2   => lpgbt_uplink_data_i(idx).data(95 downto 64),
          uplinkdata3   => lpgbt_uplink_data_i(idx).data(127 downto 96),
          uplinkdata4   => lpgbt_uplink_data_i(idx).data(159 downto 128),
          uplinkdata5   => lpgbt_uplink_data_i(idx).data(191 downto 160),
          uplinkdata6   => lpgbt_uplink_data_i(idx).data(223 downto 192),
          uplinkdataic  => lpgbt_uplink_data_i(idx).ic,
          uplinkdataec  => lpgbt_uplink_data_i(idx).ec,
          uplinkrdy_o   => lpgbt_uplink_ready_o(idx),

          gt_rxusrclk_in       => lpgbt_downlink_clk_i,
          gt_txusrclk_in       => lpgbt_uplink_clk_i,
          gt_rxslide_out       => lpgbt_downlink_bitslip_o(idx),
          gt_txready_in        => not reset,
          gt_rxready_in        => not reset,
          gt_txdata_out        => lpgbt_uplink_mgt_word_array_o(idx),    -- 32 bit transmit data to mgt
          gt_rxdata_in         => lpgbt_downlink_mgt_word_array_i(idx),  -- 32 bit receive data word from mgt
          uplinkscramblerreset => std_logic0,

          uplinkinterleaverbypass => g_BYPASS_INTERLEAVER,
          uplinkfecbypass         => g_BYPASS_FEC,
          uplinkscramblerbypass   => g_BYPASS_SCRAMBLER,
          txdatarate              => std_logic1  -- 0 = 5.24 gbps, 1 = 10.24
          );
    end generate;
  end generate;

end Behavioral;
