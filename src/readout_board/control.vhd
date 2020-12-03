library ipbus;
use ipbus.ipbus.all;
use ipbus.ipbus_decode_etl_test_fw.all;         -- FIXME: need this

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity control is
  generic(
    VERBOSE : boolean := false
    );
  port(

    reset : in  std_logic;
    clock : in  std_logic;
    ipb_w : in  ipb_wbus;
    ipb_r : out ipb_rbus

    );
end control;

architecture behavioral of control is
  signal ipb_w_array : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipb_r_array : ipb_rbus_array(N_SLAVES - 1 downto 0);

  type int_array_t is array (integer range <>) of integer;

begin

  -- ipbus fabric selector

  fabric : entity ipbus.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in          => ipb_w,
      ipb_out         => ipb_r,
      sel             => ipbus_sel_etl(ipb_w.ipb_addr),
      ipb_to_slaves   => ipb_w_array,
      ipb_from_slaves => ipb_r_array
      );

    FW_INFO_wb_interface : entity work.FW_INFO_wb_interface
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
        mon       => fw_info_mon (I),
        ctrl      => fw_info_ctrl (I)
        );

  rbgen : for I in 0 to NUM_RBS-1 generate
    constant RB_BASE : integer := N_SLV_READOUT_BOARD_0;
  begin
    READOUT_BOARD_wb_interface_inst : entity work.READOUT_BOARD_wb_interface
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
        mon       => readout_board_mon (I),
        ctrl      => readout_board_ctrl (I)
        );
  end generate;

end behavioral;
