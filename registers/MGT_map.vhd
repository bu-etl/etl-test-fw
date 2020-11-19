--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.MGT_Ctrl.all;
entity MGT_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  MGT_Mon_t;
    Ctrl             : out MGT_Ctrl_t
    );
end entity MGT_interface;
architecture behavioral of MGT_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 5);
  constant Default_reg_data : slv32_array_t(integer range 0 to 5) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(2 downto 0))) is

        when 0 => --0x0
          localRdData( 0)            <=  Mon.STATUS.rxcdr_stable;                 --
          localRdData( 1)            <=  Mon.STATUS.powergood;                    --
          localRdData( 2)            <=  Mon.STATUS.txready;                      --
          localRdData( 3)            <=  Mon.STATUS.rxready;                      --
          localRdData( 4)            <=  Mon.STATUS.rx_pma_reset_done;            --
          localRdData( 5)            <=  Mon.STATUS.tx_pma_reset_done;            --
          localRdData( 6)            <=  Mon.STATUS.tx_reset_done;                --
          localRdData( 7)            <=  Mon.STATUS.rx_reset_done;                --
          localRdData( 8)            <=  Mon.STATUS.buffbypass_tx_done_out;       --
          localRdData( 9)            <=  Mon.STATUS.buffbypass_tx_error_out;      --
          localRdData(10)            <=  Mon.STATUS.buffbypass_rx_done_out;       --
          localRdData(11)            <=  Mon.STATUS.buffbypass_rx_error_out;      --
        when 2 => --0x2
          localRdData( 9 downto  0)  <=  reg_data( 2)( 9 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data( 2)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.rd_rdy;                          --DRP Enable
        when 3 => --0x3
          localRdData(15 downto  0)  <=  Mon.DRP.rd_data;                         --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data( 3)(31 downto 16);              --DRP Write Data
        when 4 => --0x4
          localRdData( 0)            <=  reg_data( 4)( 0);                        --
          localRdData( 1)            <=  reg_data( 4)( 1);                        --
          localRdData( 2)            <=  reg_data( 4)( 2);                        --
          localRdData( 3)            <=  reg_data( 4)( 3);                        --
        when 5 => --0x5
          localRdData( 0)            <=  reg_data( 5)( 0);                        --
          localRdData( 1)            <=  reg_data( 5)( 1);                        --
          localRdData( 2)            <=  reg_data( 5)( 2);                        --
          localRdData( 3)            <=  reg_data( 5)( 3);                        --


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.DRP.wr_addr                       <=  reg_data( 2)( 9 downto  0);     
  Ctrl.DRP.en                            <=  reg_data( 2)(12);               
  Ctrl.DRP.wr_data                       <=  reg_data( 3)(31 downto 16);     
  Ctrl.TX_RESETS.reset                   <=  reg_data( 4)( 0);               
  Ctrl.TX_RESETS.reset_pll_and_datapath  <=  reg_data( 4)( 1);               
  Ctrl.TX_RESETS.reset_datapath          <=  reg_data( 4)( 2);               
  Ctrl.TX_RESETS.reset_bufbypass         <=  reg_data( 4)( 3);               
  Ctrl.RX_RESETS.reset                   <=  reg_data( 5)( 0);               
  Ctrl.RX_RESETS.reset_pll_and_datapath  <=  reg_data( 5)( 1);               
  Ctrl.RX_RESETS.reset_datapath          <=  reg_data( 5)( 2);               
  Ctrl.RX_RESETS.reset_bufbypass         <=  reg_data( 5)( 3);               


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 2)( 9 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.wr_addr;
      reg_data( 2)(12)  <= DEFAULT_MGT_CTRL_t.DRP.en;
      reg_data( 3)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.wr_data;
      reg_data( 4)( 0)  <= DEFAULT_MGT_CTRL_t.TX_RESETS.reset;
      reg_data( 4)( 1)  <= DEFAULT_MGT_CTRL_t.TX_RESETS.reset_pll_and_datapath;
      reg_data( 4)( 2)  <= DEFAULT_MGT_CTRL_t.TX_RESETS.reset_datapath;
      reg_data( 4)( 3)  <= DEFAULT_MGT_CTRL_t.TX_RESETS.reset_bufbypass;
      reg_data( 5)( 0)  <= DEFAULT_MGT_CTRL_t.RX_RESETS.reset;
      reg_data( 5)( 1)  <= DEFAULT_MGT_CTRL_t.RX_RESETS.reset_pll_and_datapath;
      reg_data( 5)( 2)  <= DEFAULT_MGT_CTRL_t.RX_RESETS.reset_datapath;
      reg_data( 5)( 3)  <= DEFAULT_MGT_CTRL_t.RX_RESETS.reset_bufbypass;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.DRP.wr_en <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(2 downto 0))) is
        when 1 => --0x1
          Ctrl.DRP.wr_en              <=  localWrData( 0);               
        when 2 => --0x2
          reg_data( 2)( 9 downto  0)  <=  localWrData( 9 downto  0);      --DRP Address
          reg_data( 2)(12)            <=  localWrData(12);                --DRP Enable
        when 3 => --0x3
          reg_data( 3)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 4 => --0x4
          reg_data( 4)( 0)            <=  localWrData( 0);                --
          reg_data( 4)( 1)            <=  localWrData( 1);                --
          reg_data( 4)( 2)            <=  localWrData( 2);                --
          reg_data( 4)( 3)            <=  localWrData( 3);                --
        when 5 => --0x5
          reg_data( 5)( 0)            <=  localWrData( 0);                --
          reg_data( 5)( 1)            <=  localWrData( 1);                --
          reg_data( 5)( 2)            <=  localWrData( 2);                --
          reg_data( 5)( 3)            <=  localWrData( 3);                --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;