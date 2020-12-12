library ipbus;
use ipbus.ipbus.all;
use ipbus.ipbus_decode_etl_test_fw.all;

library ctrl_lib;
use ctrl_lib.READOUT_BOARD_Ctrl.all;
use ctrl_lib.FW_INFO_Ctrl.all;
use ctrl_lib.MGT_Ctrl.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.types.all;

entity control is
  generic(
    NUM_RBS : integer := 8
    );
  port(

    reset : in std_logic;
    clock : in std_logic;

    fw_info_mon : in FW_INFO_Mon_t;

    readout_board_mon  : in  READOUT_BOARD_Mon_array_t (NUM_RBS-1 downto 0);
    readout_board_ctrl : out READOUT_BOARD_Ctrl_array_t (NUM_RBS-1 downto 0);

    mgt_mon  : in  MGT_Mon_t;
    mgt_ctrl : out MGT_Ctrl_t;

    ipb_w : in  ipb_wbus;
    ipb_r : out ipb_rbus

    );
end control;

architecture behavioral of control is

  signal loopback : std_logic_vector (31 downto 0) := x"01234567";

  signal ipb_w_array : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipb_r_array : ipb_rbus_array(N_SLAVES - 1 downto 0);

  component ila_ipb
    port (
      clk    : in std_logic;
      probe0 : in std_logic_vector(31 downto 0);
      probe1 : in std_logic_vector(31 downto 0);
      probe2 : in std_logic_vector(0 downto 0);
      probe3 : in std_logic_vector(0 downto 0);
      probe4 : in std_logic_vector(31 downto 0);
      probe5 : in std_logic_vector(0 downto 0);
      probe6 : in std_logic_vector(0 downto 0)
      );
  end component;

begin


  process (clock) is
  begin
    if (rising_edge(clock)) then
      ipb_r_array(N_SLV_LOOPBACK).ipb_ack <= '0';
      ipb_r_array(N_SLV_LOOPBACK).ipb_err <= '0';
      if (ipb_w_array(N_SLV_LOOPBACK).ipb_strobe) then
        ipb_r_array(N_SLV_LOOPBACK).ipb_ack <= '1';
        if (ipb_w_array(N_SLV_LOOPBACK).ipb_write) then
          loopback <= ipb_w_array(N_SLV_LOOPBACK).ipb_wdata;
        else
          ipb_r_array(N_SLV_LOOPBACK).ipb_rdata <= loopback;
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------
  -- ipbus fabric selector
  --------------------------------------------------------------------------------

  ila_ipb_master_inst : ila_ipb
    port map (
      clk       => clock,
      probe0    => ipb_w.ipb_addr,
      probe1    => ipb_w.ipb_wdata,
      probe2(0) => ipb_w.ipb_strobe,
      probe3(0) => ipb_w.ipb_write,
      probe4    => ipb_r.ipb_rdata,
      probe5(0) => ipb_r.ipb_ack,
      probe6(0) => ipb_r.ipb_err
      );

  fabric : entity ipbus.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in          => ipb_w,
      ipb_out         => ipb_r,
      sel             => ipbus_sel_etl_test_fw(ipb_w.ipb_addr),
      ipb_to_slaves   => ipb_w_array,
      ipb_from_slaves => ipb_r_array
      );

  --------------------------------------------------------------------------------
  -- MGT Interface
  --------------------------------------------------------------------------------

  ila_mgt_inst : ila_ipb
    port map (
      clk       => clock,
      probe0    => ipb_w_array(N_SLV_FW_INFO).ipb_addr,
      probe1    => ipb_w_array(N_SLV_FW_INFO).ipb_wdata,
      probe2(0) => ipb_w_array(N_SLV_FW_INFO).ipb_strobe,
      probe3(0) => ipb_w_array(N_SLV_FW_INFO).ipb_write,
      probe4    => ipb_r_array(N_SLV_FW_INFO).ipb_rdata,
      probe5(0) => ipb_r_array(N_SLV_FW_INFO).ipb_ack,
      probe6(0) => ipb_r_array(N_SLV_FW_INFO).ipb_err
      );

  MGT_wb_interface : entity ctrl_lib.MGT_wb_interface
    port map (
      clk       => clock,
      reset     => reset,
      wb_addr   => ipb_w_array(N_SLV_MGT).ipb_addr,
      wb_wdata  => ipb_w_array(N_SLV_MGT).ipb_wdata,
      wb_strobe => ipb_w_array(N_SLV_MGT).ipb_strobe,
      wb_write  => ipb_w_array(N_SLV_MGT).ipb_write,
      wb_rdata  => ipb_r_array(N_SLV_MGT).ipb_rdata,
      wb_ack    => ipb_r_array(N_SLV_MGT).ipb_ack,
      wb_err    => ipb_r_array(N_SLV_MGT).ipb_err,
      mon       => mgt_mon,
      ctrl      => mgt_ctrl
      );

  --------------------------------------------------------------------------------
  -- FW Info
  --------------------------------------------------------------------------------

  ila_ipb_fwinfo_inst : ila_ipb
    port map (
      clk       => clock,
      probe0    => ipb_w_array(N_SLV_FW_INFO).ipb_addr,
      probe1    => ipb_w_array(N_SLV_FW_INFO).ipb_wdata,
      probe2(0) => ipb_w_array(N_SLV_FW_INFO).ipb_strobe,
      probe3(0) => ipb_w_array(N_SLV_FW_INFO).ipb_write,
      probe4    => ipb_r_array(N_SLV_FW_INFO).ipb_rdata,
      probe5(0) => ipb_r_array(N_SLV_FW_INFO).ipb_ack,
      probe6(0) => ipb_r_array(N_SLV_FW_INFO).ipb_err
      );

  FW_INFO_wb_interface : entity ctrl_lib.FW_INFO_wb_interface
    port map (
      clk       => clock,
      reset     => reset,
      wb_addr   => ipb_w_array(N_SLV_FW_INFO).ipb_addr,
      wb_wdata  => ipb_w_array(N_SLV_FW_INFO).ipb_wdata,
      wb_strobe => ipb_w_array(N_SLV_FW_INFO).ipb_strobe,
      wb_write  => ipb_w_array(N_SLV_FW_INFO).ipb_write,
      wb_rdata  => ipb_r_array(N_SLV_FW_INFO).ipb_rdata,
      wb_ack    => ipb_r_array(N_SLV_FW_INFO).ipb_ack,
      wb_err    => ipb_r_array(N_SLV_FW_INFO).ipb_err,
      mon       => fw_info_mon
      );

  --------------------------------------------------------------------------------
  -- Readout Board
  --------------------------------------------------------------------------------

  rbgen : for I in 0 to NUM_RBS-1 generate
    constant RB_BASE : integer := N_SLV_READOUT_BOARD_0;
  begin
    READOUT_BOARD_wb_interface_inst : entity ctrl_lib.READOUT_BOARD_wb_interface
      port map (
        clk       => clock,
        reset     => reset,
        wb_addr   => ipb_w_array(RB_BASE+I).ipb_addr,
        wb_wdata  => ipb_w_array(RB_BASE+I).ipb_wdata,
        wb_strobe => ipb_w_array(RB_BASE+I).ipb_strobe,
        wb_write  => ipb_w_array(RB_BASE+I).ipb_write,
        wb_rdata  => ipb_r_array(RB_BASE+I).ipb_rdata,
        wb_ack    => ipb_r_array(RB_BASE+I).ipb_ack,
        wb_err    => ipb_r_array(RB_BASE+I).ipb_err,
        mon       => readout_board_mon(I),
        ctrl      => readout_board_ctrl(I)
        );

    ila_ipb_rb_inst : ila_ipb
      port map (
        clk       => clock,
        probe0    => ipb_w_array(RB_BASE+I).ipb_addr,
        probe1    => ipb_w_array(RB_BASE+I).ipb_wdata,
        probe2(0) => ipb_w_array(RB_BASE+I).ipb_strobe,
        probe3(0) => ipb_w_array(RB_BASE+I).ipb_write,
        probe4    => ipb_r_array(RB_BASE+I).ipb_rdata,
        probe5(0) => ipb_r_array(RB_BASE+I).ipb_ack,
        probe6(0) => ipb_r_array(RB_BASE+I).ipb_err
        );
  end generate;

end behavioral;
