--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package LPGBT_UPLINK_CTRL is
  type LPGBT_UPLINK_MON_t is record
    READY                      :std_logic;     -- LPGBT Uplink Ready
    FEC_ERR_CNT                :std_logic_vector(15 downto 0);  -- Data Corrected Count
  end record LPGBT_UPLINK_MON_t;


  type LPGBT_UPLINK_CTRL_t is record
    RESET                      :std_logic;     -- Reset this Uplink
  end record LPGBT_UPLINK_CTRL_t;


  constant DEFAULT_LPGBT_UPLINK_CTRL_t : LPGBT_UPLINK_CTRL_t := (
                                                                 RESET => '0'
                                                                );


end package LPGBT_UPLINK_CTRL;