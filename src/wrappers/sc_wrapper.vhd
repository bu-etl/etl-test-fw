library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library gbt_sc;
use gbt_sc.sca_pkg.all;

library ctrl_lib;
use ctrl_lib.READOUT_BOARD_Ctrl.all;

entity gbt_controller_wrapper is
  generic(
    g_CLK_FREQ       : integer := 40;
    g_SCAS_PER_LPGBT : integer := 3
    );
  port(
    -- reset
    reset_i : in std_logic;

    mon  : out READOUT_BOARD_SC_MON_t;
    ctrl : in  READOUT_BOARD_SC_CTRL_t;

    -- master
    ic_data_i : in  std_logic_vector (1 downto 0);
    ic_data_o : out std_logic_vector (1 downto 0);

    -- sca
    sca0_data_i : in  std_logic_vector (1 downto 0);
    sca0_data_o : out std_logic_vector (1 downto 0);

    clk320  : in std_logic;
    clk40   : in std_logic;
    valid_i : in std_logic
    );
end gbt_controller_wrapper;

architecture common_controller of gbt_controller_wrapper is

  signal clk : std_logic;

  -- EC line
  signal ec_data_down : reg2_arr((g_SCAS_PER_LPGBT-1) downto 0);  --! (TX) Array of bits to be mapped to the TX GBT-Frame
  signal ec_data_up   : reg2_arr((g_SCAS_PER_LPGBT-1) downto 0);  --! (RX) Array of bits to be mapped to the RX GBT-Frame

  -- IC lines
  signal ic_data_down : std_logic_vector(1 downto 0);  --! (TX) Array of bits to be mapped to the TX GBT-Frame (bits 83/84)
  signal ic_data_up   : std_logic_vector(1 downto 0);  --! (RX) Array of bits to be mapped to the RX GBT-Frame (bits 83/84)

  -- master
  signal ic_data_i_int : std_logic_vector (1 downto 0);
  signal ic_data_o_int : std_logic_vector (1 downto 0);

  signal sca0_data_i_int : std_logic_vector (1 downto 0);
  signal sca0_data_o_int : std_logic_vector (1 downto 0);

  signal tx_reset, rx_reset : std_logic := '0';  -- TODO: connect to AXI

  signal valid : std_logic := '1';

begin

  process (clk) is
  begin
    if (rising_edge(clk)) then

      ic_data_o   <= ic_data_o_int;
      sca0_data_o <= sca0_data_o_int;

      ic_data_i_int   <= ic_data_i;
      sca0_data_i_int <= sca0_data_i;

    end if;
  end process;


  clk40_gen : if (g_CLK_FREQ = 40) generate
    clk   <= clk40;
    valid <= '1';
  end generate;

  clk320_gen : if (g_CLK_FREQ = 320) generate
    clk   <= clk320;
    valid <= valid_i;
  -- alias the valid signal here with a DONT_TOUCH to allow for easy constraint application to logic
  -- using this as a CE
  end generate;

  --------------------------------------------------------------------------------
  -- Master LPGBT (w/SCAs)
  --------------------------------------------------------------------------------

  master_gbtsc_top_inst : entity gbt_sc.gbtsc_top
    generic map (
      g_IC_FIFO_DEPTH => 8,
      g_ToLpGBT       => 1,             -- 1 = LPGBT, 0=GBTX
      g_SCA_COUNT     => g_SCAS_PER_LPGBT
      )
    port map (

      -- tx to lpgbt etc
      tx_clk_i  => clk,
      tx_clk_en => valid_i,

      -- rx from lpgbt etc
      rx_clk_i  => clk,
      rx_clk_en => valid_i,

      -- IC/EC data from controller
      ic_data_i => ic_data_i_int,
      ic_data_o => ic_data_o_int,

      -- multiplexed IC/EC data from all lpgbts

      ec_data_o(0) => sca0_data_o_int,
      ec_data_i(0) => sca0_data_i_int,

      -- reset
      rx_reset_i => rx_reset,
      tx_reset_i => tx_reset,

      -- connect all of the following to AXI slave

      tx_start_write_i => ctrl.master.tx_start_write,
      tx_start_read_i  => ctrl.master.tx_start_read,

      tx_gbtx_address_i  => ctrl.master.tx_gbtx_addr,
      tx_register_addr_i => ctrl.master.tx_register_addr,
      tx_nb_to_be_read_i => ctrl.master.tx_num_bytes_to_read,

      wr_clk_i          => clk,
      tx_wr_i           => ctrl.master.tx_wr,
      tx_data_to_gbtx_i => ctrl.master.tx_data_to_gbtx,

      rd_clk_i            => clk,
      rx_rd_i             => ctrl.master.rx_rd,
      rx_data_from_gbtx_o => mon.master.rx_data_from_gbtx,


      -- SCA Command
      rx_address_o(0)  => mon.master.rx.rx(0).rx_address,
      rx_channel_o(0)  => mon.master.rx.rx(0).rx_channel,
      rx_control_o(0)  => mon.master.rx.rx(0).rx_control,
      rx_data_o(0)     => mon.master.rx.rx(0).rx_data,
      rx_error_o(0)    => mon.master.rx.rx(0).rx_err,
      rx_len_o(0)      => mon.master.rx.rx(0).rx_len,
      rx_received_o(0) => mon.master.rx.rx(0).rx_received,
      rx_transID_o(0)  => mon.master.rx.rx(0).rx_transID,

      --
      tx_ready_o          => mon.master.tx_ready,  --! IC core ready for a transaction
      rx_empty_o          => mon.master.rx_empty,
      sca_enable_i(0)     => ctrl.master.sca_enable,
      start_reset_cmd_i   => ctrl.master.start_reset,
      start_connect_cmd_i => ctrl.master.start_connect,
      start_command_i     => ctrl.master.start_command,
      inject_crc_error    => ctrl.master.inj_crc_err,
      tx_address_i        => ctrl.master.tx_address,
      tx_transID_i        => ctrl.master.tx_transID,
      tx_channel_i        => ctrl.master.tx_channel,
      tx_command_i        => ctrl.master.tx_cmd,
      tx_data_i           => ctrl.master.tx_data
      );

end common_controller;
