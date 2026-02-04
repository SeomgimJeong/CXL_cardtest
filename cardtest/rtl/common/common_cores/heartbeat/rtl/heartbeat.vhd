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
-- Title       : Heartbeat Generator
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : The heartbeat generator runs continuously from a
--               100MHz clock. It divides the clock down to produce
--               an output that is a double pulse once every second
--               (like a heartbeat).
--
--               Using a 100MHz clock (10ns period), the timing constraints
--               cannot be met while using a single large counter. To
--               overcome this limitation, the counter is constructed
--               by cascading three small counters (8-bit, 9-bit and 10-bit).
--
--
-- <Timing Diagram>
--
-- hrt_beat ___.--.__.--.______________.--.__.--.______________.--.__.--.__
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity heartbeat is
  port (
    clk             : in  std_logic;
    hrt_beat        : out std_logic_vector(4 downto 0)
    );
end heartbeat;


architecture rtl of heartbeat is

  -- Constants
  constant COUNT_1_DECODE     : std_logic_vector(7 downto 0)    := "11111101";
  constant COUNT_2_DECODE     : std_logic_vector(8 downto 0)    := "101111100";

  -- Signals
  signal count_1              : std_logic_vector(7 downto 0)    := (others => '0');
  signal count_2              : std_logic_vector(8 downto 0)    := (others => '0');
  signal count_3              : std_logic_vector(10 downto 0)   := (others => '0');
  signal count_1_early        : std_logic                       := '0';
  signal count_1_carry        : std_logic                       := '0';
  signal count_2_carry        : std_logic                       := '0';
  signal hrt_beat_i           : std_logic_vector(4 downto 0)    := (others => '0');

begin

  process(clk)
  begin
    if rising_edge(clk) then
      -- Free running 8-bit counter (first counter). 
      count_1 <= count_1 + 1;

      -- Look ahead decoding of first counter.
      if count_1 = COUNT_1_DECODE then
        count_1_early <= '1';
      else
        count_1_early <= '0';
      end if;

      -- Create carry signal from first counter.
      count_1_carry <= count_1_early;

      -- Use first counter carry to enable second counter.
      if count_1_carry = '1' then
        if count_2 = COUNT_2_DECODE then
          count_2 <= (others => '0');
        else
          count_2 <= count_2 + 1;
        end if;
      end if;

      -- Create carry signal from second counter (runs at 1024Hz)
      if (count_2 = COUNT_2_DECODE) and (count_1_early = '1') then
        count_2_carry <= '1';
      else
        count_2_carry <= '0';
      end if;

      -- Use second counter carry to enable third counter.
      if count_2_carry = '1' then
        count_3 <= count_3 + 1;
      end if;

      -- Create heartbeat signals.
      hrt_beat_i(0) <= count_3(9) and count_3(7);                                         -- Regular beat
      hrt_beat_i(1) <= count_3(9) and count_3(7) and not count_3(10);                     -- Alternating beat phase #0
      hrt_beat_i(2) <= count_3(9) and count_3(7) and count_3(10);                         -- Alternating beat phase #1
      hrt_beat_i(3) <= count_3(9) and count_3(7) and not count_3(1) and not count_3(10);  -- Alternating beat half brightness (PWM) ph #0
      hrt_beat_i(4) <= count_3(9) and count_3(7) and not count_3(1) and count_3(10);      -- Alternating beat half brightness (PWM) ph #1

    end if;
  end process;


  -- Connect up outputs.
  hrt_beat <= hrt_beat_i;


end rtl;
