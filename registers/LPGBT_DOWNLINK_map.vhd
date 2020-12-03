--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LPGBT_DOWNLINK_Ctrl.all;
entity LPGBT_DOWNLINK_wb_interface is
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
    mon         : in  LPGBT_DOWNLINK_Mon_t;
    ctrl        : out LPGBT_DOWNLINK_Ctrl_t
    );
end entity LPGBT_DOWNLINK_wb_interface;
architecture behavioral of LPGBT_DOWNLINK_wb_interface is
  type slv32_array_t  is array (integer range <>) of std_logic_vector( 31 downto 0);
  signal localRdData : std_logic_vector (31 downto 0) := (others => '0');
  signal localWrData : std_logic_vector (31 downto 0) := (others => '0');
  signal reg_data :  slv32_array_t(integer range 0 to 1);
  constant DEFAULT_REG_DATA : slv32_array_t(integer range 0 to 1) := (others => x"00000000");
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
        case to_integer(unsigned(wb_addr(0 downto 0))) is
          when 1 => --0x1
          localRdData( 0)  <=  Mon.READY;      --LPGBT Downlink Ready

        when others =>
          localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;


  -- Register mapping to ctrl structures


  -- writes to slave
  reg_writes: process (clk) is
  begin  -- process reg_writes
    if (rising_edge(clk)) then  -- rising clock edge

      -- Write on strobe=write=1
      if wb_strobe='1' and wb_write = '1' then
        case to_integer(unsigned(wb_addr(0 downto 0))) is
        when 0 => --0x0
          Ctrl.RESET  <=  localWrData( 0);     

        when others => null;

        end case;
      end if; -- write

      -- synchronous reset (active high)
      if reset = '1' then

      Ctrl.RESET <= '0';
      

      Ctrl.RESET <= '0';
      

      end if; -- reset
    end if; -- clk
  end process reg_writes;


end architecture behavioral;