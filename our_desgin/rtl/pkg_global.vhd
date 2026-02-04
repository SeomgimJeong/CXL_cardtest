--------------------------------------------------------------------------------
--
--      This source code is provided to you (the Licensee) under license
--      by BittWare, a Molex Company. To view or use this source code,
--      the Licensee must accept a Software License Agreement (viewable
--      at developer.bittware.com), which is commonly provided as a click-
--      through license agreement. The terms of the Software License
--      Agreement govern all use and distribution of this file unless an
--      alternative superseding license has been executed with BittWare.
--      This source code and its derivatives may not be distributed to
--      third parties in source code form. Software including or derived
--      from this source code, including derivative works thereof created
--      by Licensee, may be distributed to third parties with BittWare
--      hardware only and in executable form only.
--
--      The click-through license is available here:
--        https://developer.bittware.com/software_license.txt
--
--------------------------------------------------------------------------------
--      UNCLASSIFIED//FOR OFFICIAL USE ONLY
--------------------------------------------------------------------------------
-- Title       : Package Global
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description :
-- 
-- This package is intended to hold custom functions that have been created to make
-- designs more readable.
-- 
--
-----------------------------------------------------------------------------
-- Known Issues and Omissions :
--  - none
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

package pkg_global is

  -------------------------------------------------------------------------------
  -- function prototypes
  -------------------------------------------------------------------------------

  -- Converts from binary to gray code
  function bin_to_gray (b : std_logic_vector) return std_logic_vector;

  -- Converts from gray to binary code
  function gray_to_bin (g : std_logic_vector) return std_logic_vector;

  -- returns difference between two vectors
  function gray_diff (g1, g2 : std_logic_vector) return natural;

  function to_std_logic (b : boolean) return std_logic;

  function to_boolean (s : std_logic) return boolean;

  function boolean_to_int (b : boolean) return integer;

  function int_to_boolean (i : integer) return boolean;

  function to_natural (b : boolean) return natural;

  function or_reduce (V : std_logic_vector) return std_logic;

  function and_reduce (V : std_logic_vector) return std_logic;

  function xor_reduce (V : std_logic_vector) return std_logic;

  function swap_dw (qw : std_logic_vector) return std_logic_vector;

  function swap_bytes (dw : std_logic_vector(31 downto 0)) return std_logic_vector;

  function swap_bits (v : std_logic_vector) return std_logic_vector;

  function conv_endian (dw : std_logic_vector) return std_logic_vector;

  function swap_nybble_bits (dw : std_logic_vector) return std_logic_vector;

  function conv_dual_to_quad (v : std_logic_vector(31 downto 0)) return std_logic_vector;

  function conv_quad_to_dual (v : std_logic_vector(31 downto 0)) return std_logic_vector;

  -- Function to repeat a vector N times to create a new larger vector V
  function repeat(N : natural; V : std_logic_vector) return std_logic_vector;

  function conv_slv(arg : integer; size : integer) return std_logic_vector;

  function swap_msb_lsb(arg : std_logic_vector) return std_logic_vector;

  function to_string(arg : std_logic_vector) return string;

  function string_to_slv(arg : string) return std_logic_vector;


end package pkg_global;

package body pkg_global is

  -- Converts from binary to gray code
  function bin_to_gray (b : std_logic_vector)
    return std_logic_vector is
    variable r            : std_logic_vector(b'length downto 1) := b;
  begin
    for i in 1 to r'left-1 loop
      r(i)                                                      := r(i) xor r(i+1);
    end loop;
    return (r);
  end;

  -- Converts from gray to binary code
  function gray_to_bin (g : std_logic_vector)
    return std_logic_vector is
    variable r            : std_logic_vector(g'length downto 1) := g;
  begin
    for i in r'left-1 downto 1 loop
      r(i)                                                      := r(i) xor r(i+1);
    end loop;
    return (r);
  end;

  -- returns difference between two gray encoded vectors
  function gray_diff (g1, g2 : std_logic_vector)
    return natural is
  begin
    return conv_integer(gray_to_bin(g1) - gray_to_bin(g2));
  end;

  -- Convert boolean to std_logic
  function to_std_logic(b : boolean)
    return std_logic is
  begin
    if (b) then
      return ('1');
    else
      return ('0');
    end if;
  end;

  -- Convert std_logic to boolean
  function to_boolean(s : std_logic)
    return boolean is
  begin
    if (s = '1') then
      return (true);
    else
      return (false);
    end if;
  end;

  -- Convert boolean to integer flag
  function boolean_to_int(b : boolean)
    return integer is
  begin
    if b then
      return 1;
    else
      return 0;
    end if;
  end;

  -- Convert integer flag to boolean 
  function int_to_boolean(i : integer)
    return boolean is
  begin
    if i = 0 then
      return false;
    else
      return true;
    end if;
  end;


  -- Convert boolean to natural
  function to_natural(b : boolean)
    return natural is
  begin
    if b then
      return (1);
    else
      return (0);
    end if;
  end;

  -- bitwise OR of a vector (i.e. OR all the bits of a vector together)
  function or_reduce(V : std_logic_vector) return std_logic is

    variable result : std_logic;

  begin
    for i in V'range loop
      if i = V'left then                -- first value
        result := V(i);
      else
        result := result or V(i);
      end if;
    end loop;
    return result;
  end or_reduce;

  -- bitwise AND of a vector (i.e. AND all the bits of a vector together)
  function and_reduce(V : std_logic_vector) return std_logic is

    variable result : std_logic;

  begin
    for i in V'range loop
      if i = V'left then
        result := V(i);
      else
        result := result and V(i);
      end if;
    end loop;
    return result;
  end and_reduce;

  -- bitwise XOR of a vector (i.e. XOR all the bits of a vector together)
  function xor_reduce(V : std_logic_vector) return std_logic is

    variable result : std_logic;

  begin
    for i in V'range loop
      if i = V'left then
        result := V(i);
      else
        result := result xor V(i);
      end if;
    end loop;
    return result;
  end xor_reduce;



  function swap_dw (qw : std_logic_vector) return std_logic_vector is
    variable result    : std_logic_vector(63 downto 0);
  begin
    result(63 downto 32) := qw(31 downto 00);
    result(31 downto 00) := qw(63 downto 32);
    return result;
  end swap_dw;

  function swap_bytes (dw : std_logic_vector(31 downto 0)) return std_logic_vector is
    variable result       : std_logic_vector(31 downto 00);
  begin
    result(31 downto 24) := dw(07 downto 00);
    result(23 downto 16) := dw(15 downto 08);
    result(15 downto 08) := dw(23 downto 16);
    result(07 downto 00) := dw(31 downto 24);
    return result;
  end swap_bytes;

  function swap_bits (v : std_logic_vector) return std_logic_vector is

    variable result : std_logic_vector(v'length-1 downto 0);

  begin
    for i in v'range loop
      result(v'high - i) := v(i);
    end loop;

    return result;
  end swap_bits;



  -- Convert big endian to little endian byte format (and vise versa)
  function conv_endian (dw : std_logic_vector) return std_logic_vector is

    variable result : std_logic_vector(31 downto 00);

  begin
    if dw'high = 31 then
      result(31 downto 24) := dw(07 downto 00);
      result(23 downto 16) := dw(15 downto 08);
      result(15 downto 08) := dw(23 downto 16);
      result(07 downto 00) := dw(31 downto 24);
    else
      result(31 downto 24) := dw(07+32 downto 00+32);
      result(23 downto 16) := dw(15+32 downto 08+32);
      result(15 downto 08) := dw(23+32 downto 16+32);
      result(07 downto 00) := dw(31+32 downto 24+32);
    end if;
    return result;
  end conv_endian;

  function swap_nybble_bits (dw : std_logic_vector) return std_logic_vector is
    variable result             : std_logic_vector(31 downto 00);
  begin
    result(31 downto 28) := dw(28) & dw(29) & dw(30) & dw(31);
    result(27 downto 24) := dw(24) & dw(25) & dw(26) & dw(27);
    result(23 downto 20) := dw(20) & dw(21) & dw(22) & dw(23);
    result(19 downto 16) := dw(16) & dw(17) & dw(18) & dw(19);
    result(15 downto 12) := dw(12) & dw(13) & dw(14) & dw(15);
    result(11 downto 08) := dw(08) & dw(09) & dw(10) & dw(11);
    result(07 downto 04) := dw(04) & dw(05) & dw(06) & dw(07);
    result(03 downto 00) := dw(00) & dw(01) & dw(02) & dw(03);
    return result;
  end swap_nybble_bits;

  -- This function performs the bit position conversion required for writes to
  -- the QSPI. Dual writes represented in a Quad fashion.
  function conv_dual_to_quad (v : std_logic_vector(31 downto 00)) return std_logic_vector is
    variable result             : std_logic_vector(31 downto 00);
  begin
    result(00) := v(03);
    result(01) := v(02);
    result(02) := v(07);
    result(03) := v(06);
    result(04) := v(11);
    result(05) := v(10);
    result(06) := v(15);
    result(07) := v(14);
    result(08) := v(19);
    result(09) := v(18);
    result(10) := v(23);
    result(11) := v(22);
    result(12) := v(27);
    result(13) := v(26);
    result(14) := v(31);
    result(15) := v(30);
    result(16) := v(01);
    result(17) := v(00);
    result(18) := v(05);
    result(19) := v(04);
    result(20) := v(09);
    result(21) := v(08);
    result(22) := v(13);
    result(23) := v(12);
    result(24) := v(17);
    result(25) := v(16);
    result(26) := v(21);
    result(27) := v(20);
    result(28) := v(25);
    result(29) := v(24);
    result(30) := v(29);
    result(31) := v(28);
    return result;
  end conv_dual_to_quad;

  -- This function performs the bit position conversion required for reads from
  -- the QSPI. Quad format converted to dual reads.
  function conv_quad_to_dual (v : std_logic_vector(31 downto 0)) return std_logic_vector is
    variable result             : std_logic_vector(31 downto 00);
  begin
    result(03) := v(00);
    result(02) := v(01);
    result(07) := v(02);
    result(06) := v(03);
    result(11) := v(04);
    result(10) := v(05);
    result(15) := v(06);
    result(14) := v(07);
    result(19) := v(08);
    result(18) := v(09);
    result(23) := v(10);
    result(22) := v(11);
    result(27) := v(12);
    result(26) := v(13);
    result(31) := v(14);
    result(30) := v(15);
    result(01) := v(16);
    result(00) := v(17);
    result(05) := v(18);
    result(04) := v(19);
    result(09) := v(20);
    result(08) := v(21);
    result(13) := v(22);
    result(12) := v(23);
    result(17) := v(24);
    result(16) := v(25);
    result(21) := v(26);
    result(20) := v(27);
    result(25) := v(28);
    result(24) := v(29);
    result(29) := v(30);
    result(28) := v(31);
    return result;
  end conv_quad_to_dual;

  ---------------------------------------------------------------------------
  -- Function to repeat a vector N times to create a new larger vector V
  ---------------------------------------------------------------------------
  function repeat(N : natural; V : std_logic_vector) return std_logic_vector is

    constant L : natural := V'length;

    variable result : std_logic_vector(0 to N*L - 1);
  begin
    for i in 0 to N-1 loop
      result(i*L to i*L + L - 1) := V;
    end loop;
    return result;
  end;

  --------------------------------------------------------------------
  -- Function to convert an integer to a std_logic_vector (unsigned)
  --------------------------------------------------------------------
  function conv_slv(arg : integer; size : integer) return std_logic_vector is

    variable result : std_logic_vector (size-1 downto 0);
    variable temp   : integer;

  begin
    temp          := arg;
    for i in 0 to size-1 loop
      if (temp mod 2) = 1 then
        result(i) := '1';
      else
        result(i) := '0';
      end if;
      if temp > 0 then
        temp      := temp / 2;
      elsif (temp > integer'low) then
        temp      := (temp - 1) / 2;
      else
        temp      := temp / 2;
      end if;
    end loop;
    return result;
  end;

  --------------------------------------------------------------------
  -- Function to swap msb to lsb in a std_logic_vector
  --------------------------------------------------------------------
  function swap_msb_lsb(arg : std_logic_vector) return std_logic_vector is

    variable bit_max : integer := arg'high;
    variable bit_min : integer := arg'low;
    variable result  : std_logic_vector(arg'high downto arg'low);

  begin
    for i in bit_min to bit_max loop
      result(i) := arg(bit_min + bit_max - i);
    end loop;
    return result;
  end;

  --------------------------------------------------------------------
  -- Function (private) to convert a nibble to a character
  --------------------------------------------------------------------
  function to_hex(char : std_logic_vector(3 downto 0)) return character is

    variable result : character;

  begin
    case char is
      when x"0"   => result := '0';
      when x"1"   => result := '1';
      when x"2"   => result := '2';
      when x"3"   => result := '3';
      when x"4"   => result := '4';
      when x"5"   => result := '5';
      when x"6"   => result := '6';
      when x"7"   => result := '7';
      when x"8"   => result := '8';
      when x"9"   => result := '9';
      when x"A"   => result := 'A';
      when x"B"   => result := 'B';
      when x"C"   => result := 'C';
      when x"D"   => result := 'D';
      when x"E"   => result := 'E';
      when x"F"   => result := 'F';
      when "ZZZZ" => result := 'Z';
      when others => result := 'X';
    end case;
    return result;
  end;

  --------------------------------------------------------------------
  -- Function to convert a nibble-sized std_logic_vector to a string
  --------------------------------------------------------------------
  function to_string(arg : std_logic_vector) return string is

    variable result : string(1 to arg'length/4);

  begin
    -- check if arg is divisible by 4.
    assert (arg'length rem 4 = 0)
      report "to_string : std_logic_vector must be divisible by 4."
      severity failure;

    -- Convert each nibble into a character in the string
    -- (the most left nibble becomes the first character). 
    for i in 0 to arg'length/4-1 loop
      if arg'ascending then
        result(i+1) := to_hex(arg(arg'low+4*i to arg'low+3+4*i));
      else
        result(i+1) := to_hex(arg(arg'high-4*i downto arg'high-3-4*i));
      end if;
    end loop;
    return result;
  end;

  --------------------------------------------------------------------
  -- Function to convert a hex character string to a std_logic_vector
  --------------------------------------------------------------------
  function string_to_slv(arg : string) return std_logic_vector is

    variable result : std_logic_vector((arg'length*4)-1 downto 0) := (others => '0');

  begin
    for i in 0 to (arg'length-1) loop
      case arg(arg'length-i) is
        when '0'     => result((i*4)+3 downto i*4) := "0000";
        when '1'     => result((i*4)+3 downto i*4) := "0001";
        when '2'     => result((i*4)+3 downto i*4) := "0010";
        when '3'     => result((i*4)+3 downto i*4) := "0011";
        when '4'     => result((i*4)+3 downto i*4) := "0100";
        when '5'     => result((i*4)+3 downto i*4) := "0101";
        when '6'     => result((i*4)+3 downto i*4) := "0110";
        when '7'     => result((i*4)+3 downto i*4) := "0111";
        when '8'     => result((i*4)+3 downto i*4) := "1000";
        when '9'     => result((i*4)+3 downto i*4) := "1001";
        when 'A'|'a' => result((i*4)+3 downto i*4) := "1010";
        when 'B'|'b' => result((i*4)+3 downto i*4) := "1011";
        when 'C'|'c' => result((i*4)+3 downto i*4) := "1100";
        when 'D'|'d' => result((i*4)+3 downto i*4) := "1101";
        when 'E'|'e' => result((i*4)+3 downto i*4) := "1110";
        when 'F'|'f' => result((i*4)+3 downto i*4) := "1111";
        when others  =>
          assert false
            report "Non-hex character encountered in input string."
            severity error;
      end case;
    end loop;
    return result;
  end;


end package body pkg_global;
