-- Address decode logic for ipbus fabric
-- 
-- This file has been AUTOGENERATED from the address table - do not hand edit
-- 
-- We assume the synthesis tool is clever enough to recognise exclusive conditions
-- in the if statement.
-- 
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package ipbus_decode_etl_test_fw is

  constant IPBUS_SEL_WIDTH: positive := 4;
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_etl_test_fw(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Fri Dec 11 20:43:43 2020 
  constant N_SLV_LOOPBACK: integer := 0;
  constant N_SLV_FW_INFO: integer := 1;
  constant N_SLV_READOUT_BOARD_0: integer := 2;
  constant N_SLV_READOUT_BOARD_1: integer := 3;
  constant N_SLV_READOUT_BOARD_2: integer := 4;
  constant N_SLV_READOUT_BOARD_3: integer := 5;
  constant N_SLV_READOUT_BOARD_4: integer := 6;
  constant N_SLV_READOUT_BOARD_5: integer := 7;
  constant N_SLV_READOUT_BOARD_6: integer := 8;
  constant N_SLV_READOUT_BOARD_7: integer := 9;
  constant N_SLV_MGT: integer := 10;
  constant N_SLAVES: integer := 11;
-- END automatically generated VHDL

    
end ipbus_decode_etl_test_fw;

package body ipbus_decode_etl_test_fw is

  function ipbus_sel_etl_test_fw(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically  generated VHDL the Fri Dec 11 20:43:43 2020 
    if    std_match(addr, "----------------0000------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_LOOPBACK, IPBUS_SEL_WIDTH)); -- LOOPBACK / base 0x00000000 / mask 0x0000f000
    elsif std_match(addr, "----------------0001------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_FW_INFO, IPBUS_SEL_WIDTH)); -- FW_INFO / base 0x00001000 / mask 0x0000f000
    elsif std_match(addr, "----------------0010------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_READOUT_BOARD_0, IPBUS_SEL_WIDTH)); -- READOUT_BOARD_0 / base 0x00002000 / mask 0x0000f000
    elsif std_match(addr, "----------------0011------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_READOUT_BOARD_1, IPBUS_SEL_WIDTH)); -- READOUT_BOARD_1 / base 0x00003000 / mask 0x0000f000
    elsif std_match(addr, "----------------0100------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_READOUT_BOARD_2, IPBUS_SEL_WIDTH)); -- READOUT_BOARD_2 / base 0x00004000 / mask 0x0000f000
    elsif std_match(addr, "----------------0101------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_READOUT_BOARD_3, IPBUS_SEL_WIDTH)); -- READOUT_BOARD_3 / base 0x00005000 / mask 0x0000f000
    elsif std_match(addr, "----------------0110------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_READOUT_BOARD_4, IPBUS_SEL_WIDTH)); -- READOUT_BOARD_4 / base 0x00006000 / mask 0x0000f000
    elsif std_match(addr, "----------------0111------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_READOUT_BOARD_5, IPBUS_SEL_WIDTH)); -- READOUT_BOARD_5 / base 0x00007000 / mask 0x0000f000
    elsif std_match(addr, "----------------1000------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_READOUT_BOARD_6, IPBUS_SEL_WIDTH)); -- READOUT_BOARD_6 / base 0x00008000 / mask 0x0000f000
    elsif std_match(addr, "----------------1001------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_READOUT_BOARD_7, IPBUS_SEL_WIDTH)); -- READOUT_BOARD_7 / base 0x00009000 / mask 0x0000f000
    elsif std_match(addr, "----------------1010------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MGT, IPBUS_SEL_WIDTH)); -- MGT / base 0x0000a000 / mask 0x0000f000
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_etl_test_fw;

end ipbus_decode_etl_test_fw;

