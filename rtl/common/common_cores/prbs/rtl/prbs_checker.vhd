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
-- Title       : PRBS Checker
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : Parameterised PRBS checker.
--
--               XOR feedback chosen, reset to '0'.
--
--               This module detects a selected prbs pattern. When out of PRBS
--               lock it seeds a PRBS generator with the incoming data pattern.
--               The next PRBS is generated and compared with the next incoming
--               PRBS. This seeding continues until the lock width has been
--               satisfied (i.e. a lock_width number of consecutive successful
--               predictions). Thereafter the checker is considered to be locked
--               and the local PRBS generator will not be seeded to the line.
--               The input PRBS data will be compared to the locally generated
--               data, errors being presented on the data port, a '1' indicates
--               an error in that bit position. These may be counted externally.
--
--               Note:
--               Once gained, lock is not released, but however requires to be
--               cleared down by loading a lock context of zero. If reseeding
--               is required the context should be cleared by external control
--               logic to allow the pattern to be re-acquired.
--
--               To select PRBS11, width should be set to 11.
--               To select PRBS15, width should be set to 15.
--               To select PRBS23, width should be set to 23.
--               To select PRBS31, width should be set to 31.
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


entity prbs_checker is
  generic (
    width               : integer := 11;          -- width of prbs
    data_width          : integer := 8;           -- width of input data pipe
    min                 : integer := 3;           -- min prbs supported
    max                 : integer := 64;          -- max prbs supported
    lock_width          : integer := 4            -- size of lock window
    );
  port (
    clock               : in  std_logic;
    sync_reset          : in  std_logic;
    -- should be asserted when new input data is presented
    enable              : in  std_logic;
    -- enables prbs checker context to be loadable to allow for multi-channel
    -- operation
    load                : in  std_logic;
    prbs_context_in     : in  std_logic_vector(lock_width+width-1 downto 0);
    -- context out
    prbs_context_out    : out std_logic_vector(lock_width+width-1 downto 0);
    -- incoming prbs
    prbs                : in  std_logic_vector(data_width-1 downto 0);
    -- indicates errors if any 1's present
    data                : out std_logic_vector(data_width-1 downto 0);
    -- set if the incoming pattern is equal to predicted version
    match               : out std_logic;
    -- indicates if prbs lock width has been met
    prbs_lock           : out std_logic;
    --
    prbs_chk            : out std_logic_vector(data_width-1 downto 0)
    );
end entity prbs_checker;

architecture rtl of prbs_checker is

--  --###########################################################################
--  --###########################################################################
--  -- CHIPSCOPE  : 128-bit wide x 2048 deep
  component icon_one
    port
      (
        control0 : out std_logic_vector(35 downto 0)
        );
  end component;

  component ila128x2048
    port
      (
        control : in std_logic_vector(35 downto 0);
        clk     : in std_logic;
        trig0   : in std_logic_vector(127 downto 0)
        );
  end component;

  signal control0 : std_logic_vector( 35 downto 0);
  signal trig0    : std_logic_vector(127 downto 0);

  signal unused_gnd : std_logic_vector(127 downto 0) := (others => '0');

--  --###########################################################################
--  --###########################################################################



-------------------------------------------------------------------------------
-- Generic PRBS Generation Engine
-------------------------------------------------------------------------------

  function prbs_calc(prbs_state : std_logic_vector; taps : std_logic_vector) return std_logic_vector is

    variable sr_in     : std_logic;
    variable temp_data : std_logic_vector(width-1 downto 0);
    variable prbs_s    : std_logic_vector(width-1 downto 0);

  begin

    prbs_s := prbs_state;

    ---------------------------------------------------------------------------
    -- XOR feedback together and shift into register
    ---------------------------------------------------------------------------

    for i in 0 to data_width-1 loop

      -- pick off bits for xor feedback
      temp_data := (prbs_s and taps(width-1 downto 0));

      -- perform a bit wise xor
      sr_in := xor_reduce(temp_data);

      -- result is shifted into least significant bit of counter
      prbs_s := prbs_s(width-2 downto 0) & sr_in;

    end loop;

    return prbs_s;

  end prbs_calc;


  signal next_data            : std_logic_vector(width-1 downto 0);
  signal prbs_state           : std_logic_vector(width-1 downto 0)        := (others => '0');
  signal next_prbs_state      : std_logic_vector(width-1 downto 0);
  signal next_prbs            : std_logic_vector(data_width-1 downto 0);
  signal locked               : std_logic_vector(lock_width-1 downto 0)   := (others => '0');
  signal prbs_lock_i          : std_logic;
  signal match_i              : std_logic                                 := '0';
  signal data_i               : std_logic_vector(data_width-1 downto 0)   := (others => '0');

  attribute KEEP              : string;
  attribute KEEP of next_prbs : signal is "TRUE";

begin

  combLFSR : process (prbs_state, next_prbs, next_prbs_state, locked, prbs_lock_i)

    constant MAX_WIDTH : integer := 168;

    variable taps      : std_logic_vector(MAX_WIDTH-1 downto 0);
    variable temp_data : std_logic_vector(width-1 downto 0);
    variable sr_in     : std_logic;

  begin

    case width is

      -- the EXT function chops off the leading zeros in the
      -- hex notation for the taps.

      when 3  => taps(width-1 downto 0) := EXT( X"6", 3);
      when 4  => taps(width-1 downto 0) := EXT( X"C", 4);
      when 5  => taps(width-1 downto 0) := EXT( X"14", 5);
      when 6  => taps(width-1 downto 0) := EXT( X"30", 6);
      when 7  => taps(width-1 downto 0) := EXT( X"60", 7);
      when 8  => taps(width-1 downto 0) := EXT( X"B8", 8);
      when 9  => taps(width-1 downto 0) := EXT( X"110", 9);
      when 10 => taps(width-1 downto 0) := EXT( X"240", 10);
      when 11 => taps(width-1 downto 0) := EXT( X"500", 11);
      when 12 => taps(width-1 downto 0) := EXT( X"829", 12);
      when 13 => taps(width-1 downto 0) := EXT( X"100D", 13);
      when 14 => taps(width-1 downto 0) := EXT( X"2015", 14);
      when 15 => taps(width-1 downto 0) := EXT( X"6000", 15);
      when 16 => taps(width-1 downto 0) := EXT( X"D008", 16);
      when 17 => taps(width-1 downto 0) := EXT( X"12000", 17);
      when 18 => taps(width-1 downto 0) := EXT( X"20400", 18);
      when 19 => taps(width-1 downto 0) := EXT( X"40023", 19);
      when 20 => taps(width-1 downto 0) := EXT( X"90000", 20);
      when 21 => taps(width-1 downto 0) := EXT( X"140000", 21);
      when 22 => taps(width-1 downto 0) := EXT( X"300000", 22);
      when 23 => taps(width-1 downto 0) := EXT( X"420000", 23);
      when 24 => taps(width-1 downto 0) := EXT( X"E10000", 24);
      when 25 => taps(width-1 downto 0) := EXT( X"1200000", 25);
      when 26 => taps(width-1 downto 0) := EXT( X"2000023", 26);
      when 27 => taps(width-1 downto 0) := EXT( X"4000013", 27);
      when 28 => taps(width-1 downto 0) := EXT( X"9000000", 28);
      when 29 => taps(width-1 downto 0) := EXT( X"14000000", 29);
      when 30 => taps(width-1 downto 0) := EXT( X"20000029", 30);
      when 31 => taps(width-1 downto 0) := EXT( X"48000000", 31);
      when 32 => taps(width-1 downto 0) := EXT( X"80200003", 32);
      when 33 => taps(width-1 downto 0) := EXT( X"100080000", 33);
      when 34 => taps(width-1 downto 0) := EXT( X"204000003", 34);
      when 35 => taps(width-1 downto 0) := EXT( X"500000000", 35);
      when 36 => taps(width-1 downto 0) := EXT( X"801000000", 36);
      when 37 => taps(width-1 downto 0) := EXT( X"100000001F", 37);
      when 38 => taps(width-1 downto 0) := EXT( X"2000000031", 38);
      when 39 => taps(width-1 downto 0) := EXT( X"4400000000", 39);
      when 40 => taps(width-1 downto 0) := EXT( X"A000140000", 40);
      when 41 => taps(width-1 downto 0) := EXT( X"12000000000", 41);
      when 42 => taps(width-1 downto 0) := EXT( X"300000C0000", 42);
      when 43 => taps(width-1 downto 0) := EXT( X"63000000000", 43);
      when 44 => taps(width-1 downto 0) := EXT( X"C0000030000", 44);
      when 45 => taps(width-1 downto 0) := EXT( X"1B0000000000", 45);
      when 46 => taps(width-1 downto 0) := EXT( X"300003000000", 46);
      when 47 => taps(width-1 downto 0) := EXT( X"420000000000", 47);
      when 48 => taps(width-1 downto 0) := EXT( X"C00000180000", 48);
      when 49 => taps(width-1 downto 0) := EXT( X"1008000000000", 49);
      when 50 => taps(width-1 downto 0) := EXT( X"3000000C00000", 50);
      when 51 => taps(width-1 downto 0) := EXT( X"6000C00000000", 51);
      when 52 => taps(width-1 downto 0) := EXT( X"9000000000000", 52);
      when 53 => taps(width-1 downto 0) := EXT( X"18003000000000", 53);
      when 54 => taps(width-1 downto 0) := EXT( X"30000000030000", 54);
      when 55 => taps(width-1 downto 0) := EXT( X"40000040000000", 55);
      when 56 => taps(width-1 downto 0) := EXT( X"C0000600000000", 56);
      when 57 => taps(width-1 downto 0) := EXT( X"102000000000000", 57);
      when 58 => taps(width-1 downto 0) := EXT( X"200004000000000", 58);
      when 59 => taps(width-1 downto 0) := EXT( X"600003000000000", 59);
      when 60 => taps(width-1 downto 0) := EXT( X"C00000000000000", 60);
      when 61 => taps(width-1 downto 0) := EXT( X"1800300000000000", 61);
      when 62 => taps(width-1 downto 0) := EXT( X"3000000000000030", 62);
      when 63 => taps(width-1 downto 0) := EXT( X"6000000000000000", 63);
      when 64 => taps(width-1 downto 0) := EXT( X"D800000000000000", 64);

      when others =>
        null;

    end case;


    -- call prbs generation function
    next_prbs_state <= prbs_calc(prbs_state, taps(width-1 downto 0));
    -- pick off top of prbs for transmission
    next_prbs       <= next_prbs_state(width-1 downto width-data_width);
    prbs_chk        <= next_prbs;

    -- prbs_lock generation
    prbs_lock_i <= and_reduce(locked);

    prbs_lock <= prbs_lock_i;

    prbs_context_out <= (locked & prbs_state);

  end process combLFSR;

-- ---------------------------------------------------------------------
-- Sequential Logic

  seqLFSR : process (clock)

  begin
    if rising_edge (clock) then
      if (sync_reset = '1') then
        match_i    <= '0';
        prbs_state <= (others => '0');
        locked     <= (others => '0');
      elsif (enable = '1') then

        if (load = '1') then
          -- context load
          prbs_state <= prbs_context_in(width-1 downto 0);
        elsif (prbs_lock_i = '0') then
          -- If not yet achieved lock, seed the prbs calc engine with the
          -- input data in order to predict the next value.
          prbs_state <= prbs & next_prbs_state(width-data_width-1 downto 0);
        else
          -- once locked, independently generate prbs
          prbs_state <= next_prbs_state;
        end if;

        -- compare incoming prbs to predicted prbs. Match is asserted on
        -- every equivalent pattern. When out of lock, locked is used to
        -- capture the number of consecutive matches. Once locked this is
        -- no longer checked, reseeding must be provoked externally.
        -- Additionally, during a pattern match must check that incoming
        -- data is not all zero's as the checker will lock to this otherwise.
        if (load = '1') then
          locked    <= prbs_context_in(lock_width+width-1 downto width);
        elsif (next_prbs = prbs) then
          match_i   <= '1';
          if (prbs_lock_i = '0') then
            locked  <= locked(locked'high-1 downto 0) & (or_reduce(prbs));
          end if;
        elsif (prbs_lock_i = '0') and (next_prbs /= prbs) then
          locked    <= (others => '0');
        else
          -- Once locked if pattern doesn't match this must be reflected
          -- in the error mask until the controller decides that a resync
          -- is necessary
          if (prbs_lock_i = '0') or ((prbs_lock_i = '1') and (next_prbs /= prbs)) then
            match_i <= '0';
          end if;

        end if;

        -- any '1's indicate an error in that bit position, these can be counted externally.
        data_i <= next_prbs xor prbs;
      end if;


    end if;
  end process seqLFSR;


  match <= match_i;
  data  <= data_i;


  g1 : if false generate

    i_icon : icon_one
      port map
      (
        control0 => control0
        );

    i_ila : ila128x2048
      port map
      (
        control => control0,
        clk     => clock,
        trig0   => trig0
        );

    trig0 <= (
      unused_gnd(127 downto 69) &
      enable &                          -- 68
      load &                            -- 67
      sync_reset &                      -- 66
      prbs_lock_i &                     -- 65
      match_i &                         -- 64
      prbs &                            -- 32 to 63
      next_prbs                         -- 0 to 31
      );

  end generate g1;


end architecture rtl;
