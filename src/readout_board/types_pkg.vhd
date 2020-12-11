library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library ctrl_lib;
use ctrl_lib.READOUT_BOARD_Ctrl.all;
use ctrl_lib.FW_INFO_Ctrl.all;

package types is
  constant std_logic0 : std_logic := '0';
  constant std_logic1 : std_logic := '1';
  type std32_array_t is array (integer range <>) of std_logic_vector(31 downto 0);
  type READOUT_BOARD_Mon_array_t is array (integer range <>) of READOUT_BOARD_Mon_t;
  type READOUT_BOARD_Ctrl_array_t is array (integer range <>) of READOUT_BOARD_Ctrl_t;
end package types;
