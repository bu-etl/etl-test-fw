--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package MGT_CTRL is
  type MGT_STATUS_MON_t is record
    rxcdr_stable               :std_logic;   
    powergood                  :std_logic;   
    txready                    :std_logic;   
    rxready                    :std_logic;   
    rx_pma_reset_done          :std_logic;   
    tx_pma_reset_done          :std_logic;   
    tx_reset_done              :std_logic;   
    rx_reset_done              :std_logic;   
    buffbypass_tx_done_out     :std_logic;   
    buffbypass_tx_error_out    :std_logic;   
    buffbypass_rx_done_out     :std_logic;   
    buffbypass_rx_error_out    :std_logic;   
  end record MGT_STATUS_MON_t;


  type MGT_DRP_MON_t is record
    rd_rdy                     :std_logic;     -- DRP Enable
    rd_data                    :std_logic_vector(15 downto 0);  -- DRP Read Data
  end record MGT_DRP_MON_t;


  type MGT_DRP_CTRL_t is record
    wr_en                      :std_logic;     -- DRP Write Enable
    wr_addr                    :std_logic_vector( 9 downto 0);  -- DRP Address
    en                         :std_logic;                      -- DRP Enable
    wr_data                    :std_logic_vector(15 downto 0);  -- DRP Write Data
  end record MGT_DRP_CTRL_t;


  constant DEFAULT_MGT_DRP_CTRL_t : MGT_DRP_CTRL_t := (
                                                       wr_en => '0',
                                                       wr_addr => (others => '0'),
                                                       en => '0',
                                                       wr_data => (others => '0')
                                                      );
  type MGT_TX_RESETS_CTRL_t is record
    reset                      :std_logic;   
    reset_pll_and_datapath     :std_logic;   
    reset_datapath             :std_logic;   
    reset_bufbypass            :std_logic;   
  end record MGT_TX_RESETS_CTRL_t;


  constant DEFAULT_MGT_TX_RESETS_CTRL_t : MGT_TX_RESETS_CTRL_t := (
                                                                   reset => '0',
                                                                   reset_pll_and_datapath => '0',
                                                                   reset_datapath => '0',
                                                                   reset_bufbypass => '0'
                                                                  );
  type MGT_RX_RESETS_CTRL_t is record
    reset                      :std_logic;   
    reset_pll_and_datapath     :std_logic;   
    reset_datapath             :std_logic;   
    reset_bufbypass            :std_logic;   
  end record MGT_RX_RESETS_CTRL_t;


  constant DEFAULT_MGT_RX_RESETS_CTRL_t : MGT_RX_RESETS_CTRL_t := (
                                                                   reset => '0',
                                                                   reset_pll_and_datapath => '0',
                                                                   reset_datapath => '0',
                                                                   reset_bufbypass => '0'
                                                                  );
  type MGT_MON_t is record
    STATUS                     :MGT_STATUS_MON_t;
    DRP                        :MGT_DRP_MON_t;   
  end record MGT_MON_t;


  type MGT_CTRL_t is record
    DRP                        :MGT_DRP_CTRL_t;
    TX_RESETS                  :MGT_TX_RESETS_CTRL_t;
    RX_RESETS                  :MGT_RX_RESETS_CTRL_t;
  end record MGT_CTRL_t;


  constant DEFAULT_MGT_CTRL_t : MGT_CTRL_t := (
                                               DRP => DEFAULT_MGT_DRP_CTRL_t,
                                               TX_RESETS => DEFAULT_MGT_TX_RESETS_CTRL_t,
                                               RX_RESETS => DEFAULT_MGT_RX_RESETS_CTRL_t
                                              );


end package MGT_CTRL;