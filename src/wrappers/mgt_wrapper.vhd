library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity mgt_wrapper is
  --generic(
  --  );
  port(
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
    gtwiz_userdata_tx_in               : in  std_logic_vector(319 downto 0);
    gtwiz_userdata_rx_out              : out std_logic_vector(319 downto 0);
    gtrefclk00_in                      : in  std_logic_vector(2 downto 0);
    qpll0outclk_out                    : out std_logic_vector(2 downto 0);
    qpll0outrefclk_out                 : out std_logic_vector(2 downto 0);
    gthrxn_in                          : in  std_logic_vector(9 downto 0);
    gthrxp_in                          : in  std_logic_vector(9 downto 0);
    gthtxn_out                         : out std_logic_vector(9 downto 0);
    gthtxp_out                         : out std_logic_vector(9 downto 0);
    gtpowergood_out                    : out std_logic_vector(9 downto 0);
    rxpmaresetdone_out                 : out std_logic_vector(9 downto 0);
    txpmaresetdone_out                 : out std_logic_vector(9 downto 0)

    );
end mgt_wrapper;

architecture behavioral of mgt_wrapper is

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
      gtwiz_userdata_tx_in               : in  std_logic_vector(319 downto 0);
      gtwiz_userdata_rx_out              : out std_logic_vector(319 downto 0);
      gtrefclk00_in                      : in  std_logic_vector(2 downto 0);
      qpll0outclk_out                    : out std_logic_vector(2 downto 0);
      qpll0outrefclk_out                 : out std_logic_vector(2 downto 0);
      gthrxn_in                          : in  std_logic_vector(9 downto 0);
      gthrxp_in                          : in  std_logic_vector(9 downto 0);
      gthtxn_out                         : out std_logic_vector(9 downto 0);
      gthtxp_out                         : out std_logic_vector(9 downto 0);
      gtpowergood_out                    : out std_logic_vector(9 downto 0);
      rxpmaresetdone_out                 : out std_logic_vector(9 downto 0);
      txpmaresetdone_out                 : out std_logic_vector(9 downto 0)
      );
  end component;

begin

  your_instance_name : kcu105_mgts
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
