--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FW_INFO_Ctrl.all;
entity FW_INFO_wb_interface is
  port (
    clk         : in  std_logic;
    reset       : in  std_logic;
    wb_addr     : in  std_logic_vector(31 downto 0);
    wb_wdata    : in  std_logic_vector(31 downto 0);
    wb_strobe   : in  std_logic;
    wb_write    : in  std_logic;
    wb_rdata    : out std_logic_vector(31 downto 0);
    wb_ack      : out std_logic;
    wb_err      : out std_logic;
    mon         : in  FW_INFO_Mon_t
    );
end entity FW_INFO_wb_interface;
architecture behavioral of FW_INFO_wb_interface is
  type slv32_array_t  is array (integer range <>) of std_logic_vector( 31 downto 0);
  signal localRdData : std_logic_vector (31 downto 0) := (others => '0');
  signal localWrData : std_logic_vector (31 downto 0) := (others => '0');
  signal reg_data :  slv32_array_t(integer range 0 to 49);
  constant DEFAULT_REG_DATA : slv32_array_t(integer range 0 to 49) := (others => x"00000000");
begin  -- architecture behavioral

  wb_rdata <= localRdData;
  localWrData <= wb_wdata;

  -- acknowledge
  process (clk) is
  begin
    if (rising_edge(clk)) then
      if (reset='1') then
        wb_ack  <= '0';
      else
        wb_ack  <= wb_strobe;
      end if;
    end if;
  end process;

  -- reads from slave
  reads: process (clk) is
  begin  -- process reads
    if rising_edge(clk) then  -- rising clock edge
      localRdData <= x"00000000";
      if wb_strobe='1' then
        case to_integer(unsigned(wb_addr(5 downto 0))) is
          when 32 => --0x20
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.GLOBAL_FWDATE;            --
        when 33 => --0x21
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.GLOBAL_FWTIME;            --
        when 34 => --0x22
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.OFFICIAL;                 --
        when 35 => --0x23
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.GLOBAL_FWHASH;            --
        when 36 => --0x24
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.TOP_FWHASH;               --
        when 37 => --0x25
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.XML_HASH;                 --
        when 38 => --0x26
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.GLOBAL_FWVERSION;         --
        when 39 => --0x27
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.TOP_FWVERSION;            --
        when 40 => --0x28
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.XML_VERSION;              --
        when 41 => --0x29
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.HOG_FWHASH;               --
        when 48 => --0x30
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.FRAMEWORK_FWVERSION;      --
        when 49 => --0x31
          localRdData(31 downto  0)  <=  Mon.HOG_INFO.FRAMEWORK_FWHASH;         --

        when others =>
          localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;



end architecture behavioral;