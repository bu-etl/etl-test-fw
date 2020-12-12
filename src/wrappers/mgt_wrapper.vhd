library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library ctrl_lib;
use ctrl_lib.MGT_Ctrl.all;

library work;
use work.types.all;

entity mgt_wrapper is
  generic(
    NUM_GTS   : integer := 10;
    NUM_QUADS : integer := 3
    );
  port(

    drp_clk : in std_logic;

    rxn_in  : in  std_logic_vector(NUM_GTS-1 downto 0);
    rxp_in  : in  std_logic_vector(NUM_GTS-1 downto 0);
    txn_out : out std_logic_vector(NUM_GTS-1 downto 0);
    txp_out : out std_logic_vector(NUM_GTS-1 downto 0);

    data_in  : in  std32_array_t (NUM_GTS-1 downto 0);
    data_out : out std32_array_t (NUM_GTS-1 downto 0);

    rxslide_in : in  std_logic_vector(NUM_GTS-1 downto 0);

    userclk_rx_usrclk_out  : out std_logic;
    userclk_rx_usrclk2_out : out std_logic;

    userclk_tx_usrclk_out  : out std_logic;
    userclk_tx_usrclk2_out : out std_logic;

    gtrefclk00_in      : in  std_logic_vector(2 downto 0);

    mon  : out MGT_Mon_t;
    ctrl : in  MGT_Ctrl_t
    );
end mgt_wrapper;

architecture behavioral of mgt_wrapper is

  constant addr_len : integer := 9;
  constant clk_len  : integer := 1;
  constant di_len   : integer := 16;
  constant en_len   : integer := 1;
  constant we_len   : integer := 1;
  constant do_len   : integer := 16;
  constant rdy_len  : integer := 1;

  component kcu105_mgts
    port (
      gtwiz_userclk_tx_reset_in          : in  std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_srcclk_out        : out std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_usrclk_out        : out std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_usrclk2_out       : out std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_active_out        : out std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_reset_in          : in  std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_srcclk_out        : out std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_usrclk_out        : out std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_usrclk2_out       : out std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_active_out        : out std_logic_vector(0 downto 0);
      gtwiz_reset_clk_freerun_in         : in  std_logic_vector(0 downto 0);
      gtwiz_reset_all_in                 : in  std_logic_vector(0 downto 0);
      gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
      gtwiz_reset_tx_datapath_in         : in  std_logic_vector(0 downto 0);
      gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
      gtwiz_reset_rx_datapath_in         : in  std_logic_vector(0 downto 0);
      gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_userdata_tx_in               : in  std_logic_vector(NUM_GTS*32-1 downto 0);
      gtwiz_userdata_rx_out              : out std_logic_vector(NUM_GTS*32-1 downto 0);

      gtrefclk00_in : in std_logic_vector(2 downto 0);

      rxslide_in : in  std_logic_vector(NUM_GTS-1 downto 0);

      drpaddr_common_in : in  std_logic_vector(9*NUM_QUADS-1 downto 0);
      drpclk_common_in  : in  std_logic_vector(NUM_QUADS-1 downto 0);
      drpdi_common_in   : in  std_logic_vector(16*NUM_QUADS-1 downto 0);
      drpen_common_in   : in  std_logic_vector(NUM_QUADS-1 downto 0);
      drpwe_common_in   : in  std_logic_vector(NUM_QUADS-1 downto 0);
      drpdo_common_out  : out std_logic_vector(16*NUM_QUADS-1 downto 0);
      drprdy_common_out : out std_logic_vector(NUM_QUADS-1 downto 0);

      drpaddr_in : in  std_logic_vector(addr_len*NUM_GTS-1 downto 0);
      drpclk_in  : in  std_logic_vector(clk_len*NUM_GTS-1 downto 0);
      drpdi_in   : in  std_logic_vector(di_len*NUM_GTS-1 downto 0);
      drpen_in   : in  std_logic_vector(en_len*NUM_GTS-1 downto 0);
      drpwe_in   : in  std_logic_vector(we_len*NUM_GTS-1 downto 0);
      drpdo_out  : out std_logic_vector(do_len*NUM_GTS-1 downto 0);
      drprdy_out : out std_logic_vector(rdy_len*NUM_GTS-1 downto 0);

      gthrxn_in          : in  std_logic_vector(9 downto 0);
      gthrxp_in          : in  std_logic_vector(9 downto 0);
      gthtxn_out         : out std_logic_vector(9 downto 0);
      gthtxp_out         : out std_logic_vector(9 downto 0);
      gtpowergood_out    : out std_logic_vector(9 downto 0);
      rxpmaresetdone_out : out std_logic_vector(9 downto 0);
      txpmaresetdone_out : out std_logic_vector(9 downto 0)
      );
  end component;

  signal drpaddr_common : std_logic_vector(26 downto 0) := (others => '0');
  signal drpclk_common  : std_logic_vector(2 downto 0)  := (others => '0');
  signal drpdi_common   : std_logic_vector(47 downto 0) := (others => '0');
  signal drpen_common   : std_logic_vector(2 downto 0)  := (others => '0');
  signal drpwe_common   : std_logic_vector(2 downto 0)  := (others => '0');

  signal drpaddr : std_logic_vector(addr_len*NUM_GTS-1 downto 0);
  signal drpclk  : std_logic_vector(clk_len *NUM_GTS-1 downto 0);
  signal drpdi   : std_logic_vector(di_len *NUM_GTS-1 downto 0);
  signal drpen   : std_logic_vector(en_len *NUM_GTS-1 downto 0);
  signal drpwe   : std_logic_vector(we_len *NUM_GTS-1 downto 0);
  signal drpdo   : std_logic_vector(do_len *NUM_GTS-1 downto 0);
  signal drprdy  : std_logic_vector(rdy_len *NUM_GTS-1 downto 0);

  signal gtwiz_userdata_tx_in  : std_logic_vector(32*NUM_GTS-1 downto 0);
  signal gtwiz_userdata_rx_out : std_logic_vector(32*NUM_GTS-1 downto 0);

begin

  datagen : for I in 0 to NUM_GTS-1 generate
  begin
    gtwiz_userdata_tx_in (32*(I+1)-1 downto 32*I) <= data_in(I);

    data_out(I) <= gtwiz_userdata_rx_out (32*(I+1)-1 downto 32*I);
  end generate;

  drpgen : for I in 0 to NUM_GTS-1 generate
  begin

    drpaddr (addr_len*(I+1)-1 downto addr_len*I) <= ctrl.drp.drp(I).wr_addr;
    drpclk (I)                                   <= drp_clk;
    drpdi (di_len*(I+1)-1 downto di_len*I)       <= ctrl.drp.drp(I).wr_data;
    drpen(I)                                     <= ctrl.drp.drp(I).en;
    drpwe(I)                                     <= ctrl.drp.drp(I).wr_en;

    mon.drp.drp(I).rd_data <= drpdo(do_len*(I+1)-1 downto do_len*I);
    mon.drp.drp(I).rd_rdy  <= drprdy(I);

  end generate;


  mgts_inst : kcu105_mgts
    port map (
      gtwiz_userclk_tx_reset_in(0)          => ctrl.userclk_tx_reset_in,
      gtwiz_userclk_rx_reset_in(0)          => ctrl.userclk_rx_reset_in,
      gtwiz_reset_clk_freerun_in(0)         => ctrl.reset_clk_freerun_in,
      gtwiz_reset_all_in(0)                 => ctrl.reset_all_in,
      gtwiz_reset_tx_pll_and_datapath_in(0) => ctrl.reset_tx_pll_and_datapath_in,
      gtwiz_reset_tx_datapath_in(0)         => ctrl.reset_tx_datapath_in,
      gtwiz_reset_rx_pll_and_datapath_in(0) => ctrl.reset_rx_pll_and_datapath_in,
      gtwiz_reset_rx_datapath_in(0)         => ctrl.reset_rx_datapath_in,

      gtwiz_userclk_tx_srcclk_out     => open,
      gtwiz_userclk_tx_usrclk_out(0)  => userclk_tx_usrclk_out,
      gtwiz_userclk_tx_usrclk2_out(0) => userclk_tx_usrclk2_out,
      gtwiz_userclk_rx_srcclk_out     => open,
      gtwiz_userclk_rx_usrclk_out(0)  => userclk_rx_usrclk_out,
      gtwiz_userclk_rx_usrclk2_out(0) => userclk_rx_usrclk2_out,

      gtwiz_userclk_tx_active_out(0)   => mon.status.userclk_tx_active_out,
      gtwiz_userclk_rx_active_out(0)   => mon.status.userclk_rx_active_out,
      gtwiz_reset_rx_cdr_stable_out(0) => mon.status.reset_rx_cdr_stable_out,
      gtwiz_reset_tx_done_out(0)       => mon.status.reset_tx_done_out,
      gtwiz_reset_rx_done_out(0)       => mon.status.reset_rx_done_out,

      gtwiz_userdata_tx_in  => gtwiz_userdata_tx_in,
      gtwiz_userdata_rx_out => gtwiz_userdata_rx_out,

      gtrefclk00_in => gtrefclk00_in,

      gthrxn_in  => rxn_in,
      gthrxp_in  => rxp_in,
      gthtxn_out => txn_out,
      gthtxp_out => txp_out,

      drpaddr_common_in => drpaddr_common,
      drpclk_common_in  => drpclk_common,
      drpdi_common_in   => drpdi_common,
      drpen_common_in   => drpen_common,
      drpwe_common_in   => drpwe_common,

      drpaddr_in => drpaddr,
      drpclk_in  => drpclk,
      drpdi_in   => drpdi,
      drpen_in   => drpen,
      drpwe_in   => drpwe,
      drpdo_out  => drpdo,
      drprdy_out => drprdy,

      rxslide_in => rxslide_in,

      gtpowergood_out    => mon.status.gtpowergood_out,
      rxpmaresetdone_out => mon.status.rxpmaresetdone_out,
      txpmaresetdone_out => mon.status.txpmaresetdone_out
      );

end behavioral;
