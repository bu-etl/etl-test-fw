--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.FW_INFO_Ctrl.all;
entity FW_INFO_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  FW_INFO_Mon_t
    );
end entity FW_INFO_interface;
architecture behavioral of FW_INFO_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 75);
  constant Default_reg_data : slv32_array_t(integer range 0 to 75) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(6 downto 0))) is

        when 0 => --0x0
          localRdData( 1)            <=  Mon.FW_INFO.GIT_VALID;                 --
        when 1 => --0x1
          localRdData(31 downto  0)  <=  Mon.FW_INFO.GIT_HASH_1;                --
        when 2 => --0x2
          localRdData(31 downto  0)  <=  Mon.FW_INFO.GIT_HASH_2;                --
        when 3 => --0x3
          localRdData(31 downto  0)  <=  Mon.FW_INFO.GIT_HASH_3;                --
        when 4 => --0x4
          localRdData(31 downto  0)  <=  Mon.FW_INFO.GIT_HASH_4;                --
        when 5 => --0x5
          localRdData(31 downto  0)  <=  Mon.FW_INFO.GIT_HASH_5;                --
        when 16 => --0x10
          localRdData( 7 downto  0)  <=  Mon.FW_INFO.BUILD_DATE.DAY;            --
          localRdData(15 downto  8)  <=  Mon.FW_INFO.BUILD_DATE.MONTH;          --
          localRdData(31 downto 16)  <=  Mon.FW_INFO.BUILD_DATE.YEAR;           --
        when 17 => --0x11
          localRdData( 7 downto  0)  <=  Mon.FW_INFO.BUILD_TIME.SEC;            --
          localRdData(15 downto  8)  <=  Mon.FW_INFO.BUILD_TIME.MIN;            --
          localRdData(23 downto 16)  <=  Mon.FW_INFO.BUILD_TIME.HOUR;           --
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
        when 64 => --0x40
          localRdData( 0)            <=  Mon.CONFIG.MAIN_CFG_COMPILE_HW;        --
          localRdData( 1)            <=  Mon.CONFIG.MAIN_CFG_COMPILE_UL;        --
          localRdData( 2)            <=  Mon.CONFIG.SECTOR_SIDE;                --
          localRdData( 3)            <=  Mon.CONFIG.ST_nBARREL_ENDCAP;          --
          localRdData( 4)            <=  Mon.CONFIG.ENDCAP_nSMALL_LARGE;        --
          localRdData( 5)            <=  Mon.CONFIG.ENABLE_NEIGHBORS;           --
        when 70 => --0x46
          localRdData( 0)            <=  Mon.CONFIG.HPS_ENABLE_ST_INN;          --
          localRdData( 1)            <=  Mon.CONFIG.HPS_ENABLE_ST_EXT;          --
          localRdData( 2)            <=  Mon.CONFIG.HPS_ENABLE_ST_MID;          --
          localRdData( 3)            <=  Mon.CONFIG.HPS_ENABLE_ST_OUT;          --
        when 73 => --0x49
          localRdData( 0)            <=  Mon.CONFIG.UCM_ENABLED;                --
          localRdData( 1)            <=  Mon.CONFIG.MPL_ENABLED;                --
          localRdData( 2)            <=  Mon.CONFIG.SF_ENABLED;                 --
          localRdData( 3)            <=  Mon.CONFIG.SF_TYPE;                    --
        when 71 => --0x47
          localRdData( 7 downto  0)  <=  Mon.CONFIG.HPS_NUM_MDT_CH_INN;         --
          localRdData(15 downto  8)  <=  Mon.CONFIG.HPS_NUM_MDT_CH_EXT;         --
          localRdData(23 downto 16)  <=  Mon.CONFIG.HPS_NUM_MDT_CH_MID;         --
          localRdData(31 downto 24)  <=  Mon.CONFIG.HPS_NUM_MDT_CH_OUT;         --
        when 72 => --0x48
          localRdData( 7 downto  0)  <=  Mon.CONFIG.NUM_MTC;                    --
          localRdData(15 downto  8)  <=  Mon.CONFIG.NUM_NSP;                    --
        when 74 => --0x4a
          localRdData( 7 downto  0)  <=  Mon.CONFIG.NUM_DAQ_STREAMS;            --
          localRdData(15 downto  8)  <=  Mon.CONFIG.MAX_NUM_HP;                 --
          localRdData(23 downto 16)  <=  Mon.CONFIG.MAX_NUM_HPS;                --
        when 75 => --0x4b
          localRdData( 7 downto  0)  <=  Mon.CONFIG.NUM_SF_INPUTS;              --
          localRdData(15 downto  8)  <=  Mon.CONFIG.NUM_SF_OUTPUTS;             --
          localRdData(23 downto 16)  <=  Mon.CONFIG.MAX_NUM_SL;                 --
          localRdData(31 downto 24)  <=  Mon.CONFIG.NUM_THREADS;                --
        when 65 => --0x41
          localRdData(31 downto  0)  <=  Mon.CONFIG.SECTOR_ID;                  --
        when 66 => --0x42
          localRdData(31 downto  0)  <=  Mon.CONFIG.PHY_BARREL_R0;              --
        when 67 => --0x43
          localRdData(31 downto  0)  <=  Mon.CONFIG.PHY_BARREL_R1;              --
        when 68 => --0x44
          localRdData(31 downto  0)  <=  Mon.CONFIG.PHY_BARREL_R2;              --
        when 69 => --0x45
          localRdData(31 downto  0)  <=  Mon.CONFIG.PHY_BARREL_R3;              --


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;





end architecture behavioral;