--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package LPGBT_DOWNLINK_CTRL is
  type LPGBT_DOWNLINK_MON_t is record
    READY                      :std_logic;     -- LPGBT Downlink Ready
  end record LPGBT_DOWNLINK_MON_t;


  type LPGBT_DOWNLINK_CTRL_t is record
    RESET                      :std_logic;     -- Reset this Downlink
  end record LPGBT_DOWNLINK_CTRL_t;


  constant DEFAULT_LPGBT_DOWNLINK_CTRL_t : LPGBT_DOWNLINK_CTRL_t := (
                                                                     RESET => '0'
                                                                    );


end package LPGBT_DOWNLINK_CTRL;