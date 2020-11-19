--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.SCA_RX_Ctrl.all;
entity SCA_RX_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  SCA_RX_Mon_t
    );
end entity SCA_RX_interface;
architecture behavioral of SCA_RX_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 2);
  constant Default_reg_data : slv32_array_t(integer range 0 to 2) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteReg
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => slave_readMOSI,
      readMISO    => slave_readMISO,
      writeMOSI   => slave_writeMOSI,
      writeMISO   => slave_writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

  latch_reads: process (clk_axi) is
  begin  -- process latch_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localRdReq = '1' then
        localRdData_latch <= localRdData;        
      end if;
    end if;
  end process latch_reads;
  reads: process (localRdReq,localAddress,reg_data) is
  begin  -- process reads
    localRdAck  <= '0';
    localRdData <= x"00000000";
    if localRdReq = '1' then
      localRdAck  <= '1';
      case to_integer(unsigned(localAddress(1 downto 0))) is

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
  end process reads;





end architecture behavioral;