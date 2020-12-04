--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package MGT_CTRL is
  type MGT_STATUS_MON_t is record
    userclk_tx_active_out      :std_logic;   
    userclk_rx_active_out      :std_logic;   
    reset_rx_cdr_stable_out    :std_logic;   
    reset_tx_done_out          :std_logic;   
    reset_rx_done_out          :std_logic;   
    rxpmaresetdone_out         :std_logic_vector( 9 downto 0);
    txpmaresetdone_out         :std_logic_vector( 9 downto 0);
    gtpowergood_out            :std_logic_vector( 9 downto 0);
  end record MGT_STATUS_MON_t;


  type MGT_DRP_DRP_MON_t is record
    rd_rdy                     :std_logic;     -- DRP Enable
    rd_data                    :std_logic_vector(15 downto 0);  -- DRP Read Data
  end record MGT_DRP_DRP_MON_t;
  type MGT_DRP_DRP_MON_t_ARRAY is array(0 to 9) of MGT_DRP_DRP_MON_t;

  type MGT_DRP_DRP_CTRL_t is record
    wr_en                      :std_logic;     -- DRP Write Enable
    wr_addr                    :std_logic_vector( 8 downto 0);  -- DRP Address
    en                         :std_logic;                      -- DRP Enable
    wr_data                    :std_logic_vector(15 downto 0);  -- DRP Write Data
  end record MGT_DRP_DRP_CTRL_t;
  type MGT_DRP_DRP_CTRL_t_ARRAY is array(0 to 9) of MGT_DRP_DRP_CTRL_t;

  constant DEFAULT_MGT_DRP_DRP_CTRL_t : MGT_DRP_DRP_CTRL_t := (
                                                               wr_en => '0',
                                                               wr_addr => (others => '0'),
                                                               en => '0',
                                                               wr_data => (others => '0')
                                                              );
  type MGT_DRP_MON_t is record
    DRP                        :MGT_DRP_DRP_MON_t_ARRAY;
  end record MGT_DRP_MON_t;


  type MGT_DRP_CTRL_t is record
    DRP                        :MGT_DRP_DRP_CTRL_t_ARRAY;
  end record MGT_DRP_CTRL_t;


  constant DEFAULT_MGT_DRP_CTRL_t : MGT_DRP_CTRL_t := (
                                                       DRP => (others => DEFAULT_MGT_DRP_DRP_CTRL_t )
                                                      );
  type MGT_MON_t is record
    STATUS                     :MGT_STATUS_MON_t;
    DRP                        :MGT_DRP_MON_t;   
  end record MGT_MON_t;


  type MGT_CTRL_t is record
    userclk_tx_reset_in        :std_logic;   
    userclk_rx_reset_in        :std_logic;   
    reset_clk_freerun_in       :std_logic;   
    reset_all_in               :std_logic;   
    reset_tx_pll_and_datapath_in  :std_logic;   
    reset_tx_datapath_in          :std_logic;   
    reset_rx_pll_and_datapath_in  :std_logic;   
    reset_rx_datapath_in          :std_logic;   
    DRP                           :MGT_DRP_CTRL_t;
  end record MGT_CTRL_t;


  constant DEFAULT_MGT_CTRL_t : MGT_CTRL_t := (
                                               userclk_tx_reset_in => '0',
                                               userclk_rx_reset_in => '0',
                                               reset_clk_freerun_in => '0',
                                               reset_all_in => '0',
                                               reset_tx_pll_and_datapath_in => '0',
                                               reset_tx_datapath_in => '0',
                                               reset_rx_pll_and_datapath_in => '0',
                                               reset_rx_datapath_in => '0',
                                               DRP => DEFAULT_MGT_DRP_CTRL_t
                                              );


end package MGT_CTRL;