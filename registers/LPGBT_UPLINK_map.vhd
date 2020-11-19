--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.LPGBT_UPLINK_Ctrl.all;
entity LPGBT_UPLINK_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  LPGBT_UPLINK_Mon_t;
    Ctrl             : out LPGBT_UPLINK_Ctrl_t
    );
end entity LPGBT_UPLINK_interface;
architecture behavioral of LPGBT_UPLINK_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 1);
  constant Default_reg_data : slv32_array_t(integer range 0 to 1) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(0 downto 0))) is

        when 1 => --0x1
          localRdData( 0)            <=  Mon.READY;            --LPGBT Uplink Ready
          localRdData(31 downto 16)  <=  Mon.FEC_ERR_CNT;      --Data Corrected Count


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.RESET <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(0 downto 0))) is
        when 0 => --0x0
          Ctrl.RESET  <=  localWrData( 0);     

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;