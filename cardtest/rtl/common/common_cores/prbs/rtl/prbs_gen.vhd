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
-- Title       : PRBS Generator
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : Parameterised PRBS generator.
--
--               The prbs context is loadable allowing this to be used in a
--               multi-channel context switched environment.
--
--               XOR feedback chosen, so reset to '1'.
--
--               To select prbs 2**11 -1, width should be set to 11.
--               To select prbs 2**15 -1, width should be set to 15.
--               To select prbs 2**23 -1, width should be set to 23.
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;


entity prbs_gen is
  generic (
    width               : integer := 11;          -- width of prbs 
    data_width          : integer := 8;           -- width of output data pipe
    min                 : integer := 3;           -- min prbs supported
    max                 : integer := 64           -- max prbs supported
    );
  port (
    clock               : in  std_logic;
    sync_reset          : in  std_logic;
    enable              : in  std_logic;
    load                : in  std_logic;
    prbs_context_in     : in  std_logic_vector(width-1 downto 0);
    prbs_context_out    : out std_logic_vector(width-1 downto 0);
    data                : out std_logic_vector(data_width-1 downto 0)
    );
end entity prbs_gen;

architecture rtl of prbs_gen is

-------------------------------------------------------------------------------
--  Generic PRBS Generation Engine
-------------------------------------------------------------------------------

  function prbs_calc(prbs_state : std_logic_vector; taps : std_logic_vector) return std_logic_vector is

    variable sr_in     : std_logic;
    variable temp_data : std_logic_vector(width-1 downto 0);
    variable prbs_s    : std_logic_vector(width-1 downto 0);

  begin

    prbs_s := prbs_state;

    -------------------------------------------------------------------------------
    -- XOR feedback together and shift into register
    -------------------------------------------------------------------------------

    for i in 0 to data_width-1 loop

      -- pick off bits for xnor feedback
      temp_data := (prbs_s and taps(width-1 downto 0));

      -- perform a bit wise xor
      sr_in := xor_reduce(temp_data);

      -- result is shifted into least significant bit of counter
      prbs_s := prbs_s(width-2 downto 0) & sr_in;

    end loop;

    return prbs_s;
    
  end prbs_calc;


  signal next_prbs            : std_logic_vector(data_width-1 downto 0);
  signal prbs                 : std_logic_vector(data_width-1 downto 0)   := (others => '1');
  signal next_prbs_state      : std_logic_vector(width-1 downto 0);
  signal prbs_state           : std_logic_vector(width-1 downto 0)        := (others => '1');

  
begin

  combPRBS_GEN : process (prbs_state, next_prbs_state)

    constant MAX_WIDTH : integer := 168;

    variable taps : std_logic_vector(MAX_WIDTH-1 downto 0);

  begin

    case width is

      -- the EXT function chops off the leading zeros in the
      -- hex notation for the taps.

      when 3   => taps(width-1 downto 0) := EXT(                X"6",  3);
      when 4   => taps(width-1 downto 0) := EXT(                X"C",  4);
      when 5   => taps(width-1 downto 0) := EXT(               X"14",  5);
      when 6   => taps(width-1 downto 0) := EXT(               X"30",  6);
      when 7   => taps(width-1 downto 0) := EXT(               X"60",  7);
      when 8   => taps(width-1 downto 0) := EXT(               X"B8",  8);
      when 9   => taps(width-1 downto 0) := EXT(              X"110",  9);
      when 10  => taps(width-1 downto 0) := EXT(              X"240", 10);
      when 11  => taps(width-1 downto 0) := EXT(              X"500", 11); 
      when 12  => taps(width-1 downto 0) := EXT(              X"829", 12);
      when 13  => taps(width-1 downto 0) := EXT(             X"100D", 13);
      when 14  => taps(width-1 downto 0) := EXT(             X"2015", 14);
      when 15  => taps(width-1 downto 0) := EXT(             X"6000", 15);
      when 16  => taps(width-1 downto 0) := EXT(             X"D008", 16);
      when 17  => taps(width-1 downto 0) := EXT(            X"12000", 17);
      when 18  => taps(width-1 downto 0) := EXT(            X"20400", 18);
      when 19  => taps(width-1 downto 0) := EXT(            X"40023", 19);
      when 20  => taps(width-1 downto 0) := EXT(            X"90000", 20);
      when 21  => taps(width-1 downto 0) := EXT(           X"140000", 21);
      when 22  => taps(width-1 downto 0) := EXT(           X"300000", 22);
      when 23  => taps(width-1 downto 0) := EXT(           X"420000", 23);
      when 24  => taps(width-1 downto 0) := EXT(           X"E10000", 24);
      when 25  => taps(width-1 downto 0) := EXT(          X"1200000", 25);
      when 26  => taps(width-1 downto 0) := EXT(          X"2000023", 26);
      when 27  => taps(width-1 downto 0) := EXT(          X"4000013", 27);
      when 28  => taps(width-1 downto 0) := EXT(          X"9000000", 28);
      when 29  => taps(width-1 downto 0) := EXT(         X"14000000", 29);
      when 30  => taps(width-1 downto 0) := EXT(         X"20000029", 30);
      when 31  => taps(width-1 downto 0) := EXT(         X"48000000", 31);
      when 32  => taps(width-1 downto 0) := EXT(         X"80200003", 32);
      when 33  => taps(width-1 downto 0) := EXT(        X"100080000", 33);
      when 34  => taps(width-1 downto 0) := EXT(        X"204000003", 34);
      when 35  => taps(width-1 downto 0) := EXT(        X"500000000", 35);
      when 36  => taps(width-1 downto 0) := EXT(        X"801000000", 36);
      when 37  => taps(width-1 downto 0) := EXT(       X"100000001F", 37);
      when 38  => taps(width-1 downto 0) := EXT(       X"2000000031", 38);
      when 39  => taps(width-1 downto 0) := EXT(       X"4400000000", 39);
      when 40  => taps(width-1 downto 0) := EXT(       X"A000140000", 40);
      when 41  => taps(width-1 downto 0) := EXT(      X"12000000000", 41);
      when 42  => taps(width-1 downto 0) := EXT(      X"300000C0000", 42);
      when 43  => taps(width-1 downto 0) := EXT(      X"63000000000", 43);
      when 44  => taps(width-1 downto 0) := EXT(      X"C0000030000", 44);
      when 45  => taps(width-1 downto 0) := EXT(     X"1B0000000000", 45);
      when 46  => taps(width-1 downto 0) := EXT(     X"300003000000", 46);
      when 47  => taps(width-1 downto 0) := EXT(     X"420000000000", 47);
      when 48  => taps(width-1 downto 0) := EXT(     X"C00000180000", 48);
      when 49  => taps(width-1 downto 0) := EXT(    X"1008000000000", 49);
      when 50  => taps(width-1 downto 0) := EXT(    X"3000000C00000", 50);
      when 51  => taps(width-1 downto 0) := EXT(    X"6000C00000000", 51);
      when 52  => taps(width-1 downto 0) := EXT(    X"9000000000000", 52);
      when 53  => taps(width-1 downto 0) := EXT(   X"18003000000000", 53);
      when 54  => taps(width-1 downto 0) := EXT(   X"30000000030000", 54);
      when 55  => taps(width-1 downto 0) := EXT(   X"40000040000000", 55);
      when 56  => taps(width-1 downto 0) := EXT(   X"C0000600000000", 56);
      when 57  => taps(width-1 downto 0) := EXT(  X"102000000000000", 57);
      when 58  => taps(width-1 downto 0) := EXT(  X"200004000000000", 58);
      when 59  => taps(width-1 downto 0) := EXT(  X"600003000000000", 59);
      when 60  => taps(width-1 downto 0) := EXT(  X"C00000000000000", 60);
      when 61  => taps(width-1 downto 0) := EXT( X"1800300000000000", 61);
      when 62  => taps(width-1 downto 0) := EXT( X"3000000000000030", 62);
      when 63  => taps(width-1 downto 0) := EXT( X"6000000000000000", 63);
      when 64  => taps(width-1 downto 0) := EXT( X"D800000000000000", 64);

      when others =>
        null;

    end case;


    -- call prbs generation function
    next_prbs_state <= prbs_calc(prbs_state, taps(width-1 downto 0));
    -- pick off top of prbs for transmission
    next_prbs       <= next_prbs_state(width-1 downto width-data_width);
  end process combPRBS_GEN;

-- ---------------------------------------------------------------------
-- Sequential Logic

  seqPRBS_GEN : process (clock)

  begin
    if rising_edge (clock) then
      if (sync_reset = '1') then
        prbs       <= (others => '1');
        prbs_state <= prbs_context_in;
      elsif (enable = '1') then
        if (load = '1') then
          -- context load
          prbs_state <= prbs_context_in;
        else
          prbs_state <= next_prbs_state;
        end if;
        prbs       <= next_prbs;
      end if;
    end if;
  end process seqPRBS_GEN;


  data <= prbs;

  prbs_context_out <= prbs_state;


end architecture rtl;
