--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MGT_Ctrl.all;
entity MGT_wb_interface is
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
    mon         : in  MGT_Mon_t;
    ctrl        : out MGT_Ctrl_t
    );
end entity MGT_wb_interface;
architecture behavioral of MGT_wb_interface is
  type slv32_array_t  is array (integer range <>) of std_logic_vector( 31 downto 0);
  signal localRdData : std_logic_vector (31 downto 0) := (others => '0');
  signal localWrData : std_logic_vector (31 downto 0) := (others => '0');
  signal reg_data :  slv32_array_t(integer range 0 to 50);
  constant DEFAULT_REG_DATA : slv32_array_t(integer range 0 to 50) := (others => x"00000000");
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
          when 0 => --0x0
          localRdData( 0)            <=  reg_data( 0)( 0);                        --
          localRdData( 1)            <=  reg_data( 0)( 1);                        --
          localRdData( 2)            <=  reg_data( 0)( 2);                        --
          localRdData( 3)            <=  reg_data( 0)( 3);                        --
          localRdData( 4)            <=  reg_data( 0)( 4);                        --
          localRdData( 5)            <=  reg_data( 0)( 5);                        --
          localRdData( 6)            <=  reg_data( 0)( 6);                        --
          localRdData( 7)            <=  reg_data( 0)( 7);                        --
        when 1 => --0x1
          localRdData( 1)            <=  Mon.STATUS.userclk_tx_active_out;        --
          localRdData( 2)            <=  Mon.STATUS.userclk_rx_active_out;        --
          localRdData( 3)            <=  Mon.STATUS.reset_rx_cdr_stable_out;      --
          localRdData( 4)            <=  Mon.STATUS.reset_tx_done_out;            --
          localRdData( 5)            <=  Mon.STATUS.reset_rx_done_out;            --
        when 2 => --0x2
          localRdData( 9 downto  0)  <=  Mon.STATUS.rxpmaresetdone_out;           --
          localRdData(19 downto 10)  <=  Mon.STATUS.txpmaresetdone_out;           --
          localRdData(29 downto 20)  <=  Mon.STATUS.gtpowergood_out;              --
        when 4 => --0x4
          localRdData( 8 downto  0)  <=  reg_data( 4)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data( 4)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(0).rd_rdy;                   --DRP Enable
        when 5 => --0x5
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(0).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data( 5)(31 downto 16);              --DRP Write Data
        when 9 => --0x9
          localRdData( 8 downto  0)  <=  reg_data( 9)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data( 9)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(1).rd_rdy;                   --DRP Enable
        when 10 => --0xa
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(1).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(10)(31 downto 16);              --DRP Write Data
        when 14 => --0xe
          localRdData( 8 downto  0)  <=  reg_data(14)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data(14)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(2).rd_rdy;                   --DRP Enable
        when 15 => --0xf
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(2).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(15)(31 downto 16);              --DRP Write Data
        when 19 => --0x13
          localRdData( 8 downto  0)  <=  reg_data(19)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data(19)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(3).rd_rdy;                   --DRP Enable
        when 20 => --0x14
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(3).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(20)(31 downto 16);              --DRP Write Data
        when 24 => --0x18
          localRdData( 8 downto  0)  <=  reg_data(24)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data(24)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(4).rd_rdy;                   --DRP Enable
        when 25 => --0x19
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(4).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(25)(31 downto 16);              --DRP Write Data
        when 29 => --0x1d
          localRdData( 8 downto  0)  <=  reg_data(29)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data(29)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(5).rd_rdy;                   --DRP Enable
        when 30 => --0x1e
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(5).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(30)(31 downto 16);              --DRP Write Data
        when 34 => --0x22
          localRdData( 8 downto  0)  <=  reg_data(34)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data(34)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(6).rd_rdy;                   --DRP Enable
        when 35 => --0x23
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(6).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(35)(31 downto 16);              --DRP Write Data
        when 39 => --0x27
          localRdData( 8 downto  0)  <=  reg_data(39)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data(39)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(7).rd_rdy;                   --DRP Enable
        when 40 => --0x28
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(7).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(40)(31 downto 16);              --DRP Write Data
        when 44 => --0x2c
          localRdData( 8 downto  0)  <=  reg_data(44)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data(44)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(8).rd_rdy;                   --DRP Enable
        when 45 => --0x2d
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(8).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(45)(31 downto 16);              --DRP Write Data
        when 49 => --0x31
          localRdData( 8 downto  0)  <=  reg_data(49)( 8 downto  0);              --DRP Address
          localRdData(12)            <=  reg_data(49)(12);                        --DRP Enable
          localRdData(13)            <=  Mon.DRP.DRP(9).rd_rdy;                   --DRP Enable
        when 50 => --0x32
          localRdData(15 downto  0)  <=  Mon.DRP.DRP(9).rd_data;                  --DRP Read Data
          localRdData(31 downto 16)  <=  reg_data(50)(31 downto 16);              --DRP Write Data

        when others =>
          localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;


  -- Register mapping to ctrl structures
  Ctrl.userclk_tx_reset_in           <=  reg_data( 0)( 0);               
  Ctrl.userclk_rx_reset_in           <=  reg_data( 0)( 1);               
  Ctrl.reset_clk_freerun_in          <=  reg_data( 0)( 2);               
  Ctrl.reset_all_in                  <=  reg_data( 0)( 3);               
  Ctrl.reset_tx_pll_and_datapath_in  <=  reg_data( 0)( 4);               
  Ctrl.reset_tx_datapath_in          <=  reg_data( 0)( 5);               
  Ctrl.reset_rx_pll_and_datapath_in  <=  reg_data( 0)( 6);               
  Ctrl.reset_rx_datapath_in          <=  reg_data( 0)( 7);               
  Ctrl.DRP.DRP(0).wr_addr            <=  reg_data( 4)( 8 downto  0);     
  Ctrl.DRP.DRP(0).en                 <=  reg_data( 4)(12);               
  Ctrl.DRP.DRP(0).wr_data            <=  reg_data( 5)(31 downto 16);     
  Ctrl.DRP.DRP(1).wr_addr            <=  reg_data( 9)( 8 downto  0);     
  Ctrl.DRP.DRP(1).en                 <=  reg_data( 9)(12);               
  Ctrl.DRP.DRP(1).wr_data            <=  reg_data(10)(31 downto 16);     
  Ctrl.DRP.DRP(2).wr_addr            <=  reg_data(14)( 8 downto  0);     
  Ctrl.DRP.DRP(2).en                 <=  reg_data(14)(12);               
  Ctrl.DRP.DRP(2).wr_data            <=  reg_data(15)(31 downto 16);     
  Ctrl.DRP.DRP(3).wr_addr            <=  reg_data(19)( 8 downto  0);     
  Ctrl.DRP.DRP(3).en                 <=  reg_data(19)(12);               
  Ctrl.DRP.DRP(3).wr_data            <=  reg_data(20)(31 downto 16);     
  Ctrl.DRP.DRP(4).wr_addr            <=  reg_data(24)( 8 downto  0);     
  Ctrl.DRP.DRP(4).en                 <=  reg_data(24)(12);               
  Ctrl.DRP.DRP(4).wr_data            <=  reg_data(25)(31 downto 16);     
  Ctrl.DRP.DRP(5).wr_addr            <=  reg_data(29)( 8 downto  0);     
  Ctrl.DRP.DRP(5).en                 <=  reg_data(29)(12);               
  Ctrl.DRP.DRP(5).wr_data            <=  reg_data(30)(31 downto 16);     
  Ctrl.DRP.DRP(6).wr_addr            <=  reg_data(34)( 8 downto  0);     
  Ctrl.DRP.DRP(6).en                 <=  reg_data(34)(12);               
  Ctrl.DRP.DRP(6).wr_data            <=  reg_data(35)(31 downto 16);     
  Ctrl.DRP.DRP(7).wr_addr            <=  reg_data(39)( 8 downto  0);     
  Ctrl.DRP.DRP(7).en                 <=  reg_data(39)(12);               
  Ctrl.DRP.DRP(7).wr_data            <=  reg_data(40)(31 downto 16);     
  Ctrl.DRP.DRP(8).wr_addr            <=  reg_data(44)( 8 downto  0);     
  Ctrl.DRP.DRP(8).en                 <=  reg_data(44)(12);               
  Ctrl.DRP.DRP(8).wr_data            <=  reg_data(45)(31 downto 16);     
  Ctrl.DRP.DRP(9).wr_addr            <=  reg_data(49)( 8 downto  0);     
  Ctrl.DRP.DRP(9).en                 <=  reg_data(49)(12);               
  Ctrl.DRP.DRP(9).wr_data            <=  reg_data(50)(31 downto 16);     


  -- writes to slave
  reg_writes: process (clk) is
  begin  -- process reg_writes
    if (rising_edge(clk)) then  -- rising clock edge

      -- Write on strobe=write=1
      if wb_strobe='1' and wb_write = '1' then
        case to_integer(unsigned(wb_addr(5 downto 0))) is
        when 0 => --0x0
          reg_data( 0)( 0)            <=  localWrData( 0);                --
          reg_data( 0)( 1)            <=  localWrData( 1);                --
          reg_data( 0)( 2)            <=  localWrData( 2);                --
          reg_data( 0)( 3)            <=  localWrData( 3);                --
          reg_data( 0)( 4)            <=  localWrData( 4);                --
          reg_data( 0)( 5)            <=  localWrData( 5);                --
          reg_data( 0)( 6)            <=  localWrData( 6);                --
          reg_data( 0)( 7)            <=  localWrData( 7);                --
        when 3 => --0x3
          Ctrl.DRP.DRP(0).wr_en       <=  localWrData( 0);               
        when 4 => --0x4
          reg_data( 4)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data( 4)(12)            <=  localWrData(12);                --DRP Enable
        when 5 => --0x5
          reg_data( 5)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 8 => --0x8
          Ctrl.DRP.DRP(1).wr_en       <=  localWrData( 0);               
        when 9 => --0x9
          reg_data( 9)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data( 9)(12)            <=  localWrData(12);                --DRP Enable
        when 10 => --0xa
          reg_data(10)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 13 => --0xd
          Ctrl.DRP.DRP(2).wr_en       <=  localWrData( 0);               
        when 14 => --0xe
          reg_data(14)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data(14)(12)            <=  localWrData(12);                --DRP Enable
        when 15 => --0xf
          reg_data(15)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 18 => --0x12
          Ctrl.DRP.DRP(3).wr_en       <=  localWrData( 0);               
        when 19 => --0x13
          reg_data(19)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data(19)(12)            <=  localWrData(12);                --DRP Enable
        when 20 => --0x14
          reg_data(20)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 23 => --0x17
          Ctrl.DRP.DRP(4).wr_en       <=  localWrData( 0);               
        when 24 => --0x18
          reg_data(24)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data(24)(12)            <=  localWrData(12);                --DRP Enable
        when 25 => --0x19
          reg_data(25)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 28 => --0x1c
          Ctrl.DRP.DRP(5).wr_en       <=  localWrData( 0);               
        when 29 => --0x1d
          reg_data(29)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data(29)(12)            <=  localWrData(12);                --DRP Enable
        when 30 => --0x1e
          reg_data(30)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 33 => --0x21
          Ctrl.DRP.DRP(6).wr_en       <=  localWrData( 0);               
        when 34 => --0x22
          reg_data(34)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data(34)(12)            <=  localWrData(12);                --DRP Enable
        when 35 => --0x23
          reg_data(35)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 38 => --0x26
          Ctrl.DRP.DRP(7).wr_en       <=  localWrData( 0);               
        when 39 => --0x27
          reg_data(39)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data(39)(12)            <=  localWrData(12);                --DRP Enable
        when 40 => --0x28
          reg_data(40)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 43 => --0x2b
          Ctrl.DRP.DRP(8).wr_en       <=  localWrData( 0);               
        when 44 => --0x2c
          reg_data(44)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data(44)(12)            <=  localWrData(12);                --DRP Enable
        when 45 => --0x2d
          reg_data(45)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data
        when 48 => --0x30
          Ctrl.DRP.DRP(9).wr_en       <=  localWrData( 0);               
        when 49 => --0x31
          reg_data(49)( 8 downto  0)  <=  localWrData( 8 downto  0);      --DRP Address
          reg_data(49)(12)            <=  localWrData(12);                --DRP Enable
        when 50 => --0x32
          reg_data(50)(31 downto 16)  <=  localWrData(31 downto 16);      --DRP Write Data

        when others => null;

        end case;
      end if; -- write

      -- synchronous reset (active high)
      if reset = '1' then
      reg_data( 0)( 0)  <= DEFAULT_MGT_CTRL_t.userclk_tx_reset_in;
      reg_data( 0)( 1)  <= DEFAULT_MGT_CTRL_t.userclk_rx_reset_in;
      reg_data( 0)( 2)  <= DEFAULT_MGT_CTRL_t.reset_clk_freerun_in;
      reg_data( 0)( 3)  <= DEFAULT_MGT_CTRL_t.reset_all_in;
      reg_data( 0)( 4)  <= DEFAULT_MGT_CTRL_t.reset_tx_pll_and_datapath_in;
      reg_data( 0)( 5)  <= DEFAULT_MGT_CTRL_t.reset_tx_datapath_in;
      reg_data( 0)( 6)  <= DEFAULT_MGT_CTRL_t.reset_rx_pll_and_datapath_in;
      reg_data( 0)( 7)  <= DEFAULT_MGT_CTRL_t.reset_rx_datapath_in;
      reg_data( 4)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(0).wr_addr;
      reg_data( 4)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(0).en;
      reg_data( 5)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(0).wr_data;
      reg_data( 9)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(1).wr_addr;
      reg_data( 9)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(1).en;
      reg_data(10)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(1).wr_data;
      reg_data(14)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(2).wr_addr;
      reg_data(14)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(2).en;
      reg_data(15)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(2).wr_data;
      reg_data(19)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(3).wr_addr;
      reg_data(19)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(3).en;
      reg_data(20)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(3).wr_data;
      reg_data(24)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(4).wr_addr;
      reg_data(24)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(4).en;
      reg_data(25)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(4).wr_data;
      reg_data(29)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(5).wr_addr;
      reg_data(29)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(5).en;
      reg_data(30)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(5).wr_data;
      reg_data(34)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(6).wr_addr;
      reg_data(34)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(6).en;
      reg_data(35)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(6).wr_data;
      reg_data(39)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(7).wr_addr;
      reg_data(39)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(7).en;
      reg_data(40)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(7).wr_data;
      reg_data(44)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(8).wr_addr;
      reg_data(44)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(8).en;
      reg_data(45)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(8).wr_data;
      reg_data(49)( 8 downto  0)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(9).wr_addr;
      reg_data(49)(12)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(9).en;
      reg_data(50)(31 downto 16)  <= DEFAULT_MGT_CTRL_t.DRP.DRP(9).wr_data;

      Ctrl.DRP.DRP(0).wr_en <= '0';
      Ctrl.DRP.DRP(1).wr_en <= '0';
      Ctrl.DRP.DRP(2).wr_en <= '0';
      Ctrl.DRP.DRP(3).wr_en <= '0';
      Ctrl.DRP.DRP(4).wr_en <= '0';
      Ctrl.DRP.DRP(5).wr_en <= '0';
      Ctrl.DRP.DRP(6).wr_en <= '0';
      Ctrl.DRP.DRP(7).wr_en <= '0';
      Ctrl.DRP.DRP(8).wr_en <= '0';
      Ctrl.DRP.DRP(9).wr_en <= '0';
      

      Ctrl.DRP.DRP(0).wr_en <= '0';
      Ctrl.DRP.DRP(1).wr_en <= '0';
      Ctrl.DRP.DRP(2).wr_en <= '0';
      Ctrl.DRP.DRP(3).wr_en <= '0';
      Ctrl.DRP.DRP(4).wr_en <= '0';
      Ctrl.DRP.DRP(5).wr_en <= '0';
      Ctrl.DRP.DRP(6).wr_en <= '0';
      Ctrl.DRP.DRP(7).wr_en <= '0';
      Ctrl.DRP.DRP(8).wr_en <= '0';
      Ctrl.DRP.DRP(9).wr_en <= '0';
      

      end if; -- reset
    end if; -- clk
  end process reg_writes;


end architecture behavioral;