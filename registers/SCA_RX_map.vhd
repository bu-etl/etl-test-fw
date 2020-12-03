--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SCA_RX_Ctrl.all;
entity SCA_RX_wb_interface is
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
    mon         : in  SCA_RX_Mon_t
    );
end entity SCA_RX_wb_interface;
architecture behavioral of SCA_RX_wb_interface is
  type slv32_array_t  is array (integer range <>) of std_logic_vector( 31 downto 0);
  signal localRdData : std_logic_vector (31 downto 0) := (others => '0');
  signal localWrData : std_logic_vector (31 downto 0) := (others => '0');
  signal reg_data :  slv32_array_t(integer range 0 to 2);
  constant DEFAULT_REG_DATA : slv32_array_t(integer range 0 to 2) := (others => x"00000000");
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
        case to_integer(unsigned(wb_addr(1 downto 0))) is
          when 0 => --0x0
          localRdData( 7 downto  0)  <=  Mon.RX_LEN;           --Reply: The length qualifier field specifies the number of bytes contained in the DATA field.
          localRdData(15 downto  8)  <=  Mon.RX_ADDRESS;       --Reply: It represents the packet destination address. The address is one-bytelong. By default, the GBT-SCA use address 0x00.
          localRdData(23 downto 16)  <=  Mon.RX_CONTROL;       --Reply: The control field is 1 byte in length and contains frame sequence numbers of the currently transmitted frame and the last correctly received frame. The control field is also used to convey three supervisory level commands: Connect, Reset, and Test.
          localRdData(31 downto 24)  <=  Mon.RX_TRANSID;       --Reply: transaction ID field (According to the SCA manual)
        when 1 => --0x1
          localRdData( 7 downto  0)  <=  Mon.RX_ERR;           --Reply: The Error Flag field is present in the channel reply frames to indicate error conditions encountered in the execution of a command. If no errors are found, its value is 0x00.
          localRdData( 8)            <=  Mon.RX_RECEIVED;      --Reply received flag (pulse)
          localRdData(19 downto 12)  <=  Mon.RX_CHANNEL;       --Reply: The channel field specifies the destination interface of the request message (ctrl/spi/gpio/i2c/jtag/adc/dac).
        when 2 => --0x2
          localRdData(31 downto  0)  <=  Mon.RX_DATA;          --Reply: The Data field is command dependent field whose length is defined by the length qualifier field. For example, in the case of a read/write operation on a GBT-SCA internal register, it contains the value written/read from the register.

        when others =>
          localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;



end architecture behavioral;