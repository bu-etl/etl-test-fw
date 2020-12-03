library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpgbt_fpga;
use lpgbt_fpga.lpgbtfpga_package.all;

package lpgbt_pkg is


  --------------------------------------------------------------------------------
  -- Downlink
  --------------------------------------------------------------------------------

  constant c_DOWNLINK_WORD_WIDTH       : integer := 32;  -- IC + EC + User Data + FEC
  constant c_DOWNLINK_MULTICYCLE_DELAY : integer := 4;   -- Multicycle delay: USEd to relax the timing constraints
  constant c_DOWNLINK_CLOCK_RATIO      : integer := 8;   -- Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)

  --------------------------------------------------------------------------------
  -- Uplink
  --------------------------------------------------------------------------------

  constant c_UPLINK_DATARATE                   : integer := DATARATE_10G24;
  constant c_UPLINK_FEC                        : integer := FEC5;
  constant c_UPLINK_MULTICYCLE_DELAY           : integer := 4;  -- --! Multicycle delay: Used to relax the timing constraints
  constant c_UPLINK_CLOCK_RATIO                : integer := 8;  -- Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
  constant c_UPLINK_WORD_WIDTH                 : integer := 32;
  constant c_UPLINK_ALLOWED_FALSE_HEADER       : integer := 5;
  constant c_UPLINK_ALLOWED_FALSE_HEADER_OVERN : integer := 64;
  constant c_UPLINK_REQUIRED_TRUE_HEADER       : integer := 30;
  constant c_UPLINK_BITSLIP_MINDLY             : integer := 1;
  constant c_UPLINK_BITSLIP_WAITDLY            : integer := 40;

  constant c_BYPASS_FEC         : std_logic := '0';
  constant c_BYPASS_SCRAMBLER   : std_logic := '0';
  constant c_BYPASS_INTERLEAVER : std_logic := '0';

  type std2_array_t is array (integer range <>) of std_logic_vector(1 downto 0);
  type std224_array_t is array (integer range <>) of std_logic_vector(223 downto 0);

  type lpgbt_uplink_data_rt is record
    ec    : std_logic_vector (1 downto 0);
    ic    : std_logic_vector (1 downto 0);
    data  : std_logic_vector (223 downto 0);
    valid : std_logic;
  end record;

  type lpgbt_downlink_data_rt is record
    ec    : std_logic_vector (1 downto 0);
    ic    : std_logic_vector (1 downto 0);
    data  : std_logic_vector (31 downto 0);
    valid : std_logic;
  end record;

  constant lpgbt_downlink_data_rt_zero : lpgbt_downlink_data_rt := (
    ec    => (others => '0'),
    ic    => (others => '0'),
    data  => (others => '0'),
    valid => '0');

  type lpgbt_uplink_data_rt_array is array (integer range <>) of lpgbt_uplink_data_rt;
  type lpgbt_downlink_data_rt_array is array (integer range <>) of lpgbt_downlink_data_rt;

end lpgbt_pkg;
