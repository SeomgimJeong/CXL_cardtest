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
-- Title       : Counter32
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component provides a 32-bit counter with a synchronous
--               reset and an enable. The counter resets to 0x00000000 and
--               counts (when enabled) up to 0xFFFFFFFF, the count does not
--               roll over.
--
--               If the counter reaches a value of 0xFFFFFFC0 then abort is 
--               asserted until the counter is reset.
--
--               To easily meet timing constraints when the clock frequency is
--               greater that 250MHz, the counter is implemented as two
--               cascaded 16-bit counters.
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

entity counter32 is
  port (
    clock               : in  std_logic;
    reset               : in  std_logic;
    enable              : in  std_logic;
    abort               : out std_logic;
    count               : out std_logic_vector(31 downto 0)
    );
end counter32;

architecture rtl of counter32 is

  -----------
  -- Signals
  -----------
  signal count_1              : std_logic_vector(15 downto 0)        := (others => '0');
  signal count_2              : std_logic_vector(15 downto 0)        := (others => '0');
  signal count_1_carry        : std_logic                            := '0';
  signal count_2_max          : std_logic                            := '0';


begin
  process (clock)
  begin
    if rising_edge(clock) then
      if (reset = '1') then
        count_1       <= (others => '0');
        count_2       <= (others => '0');
        count_1_carry <= '0';
        count_2_max   <= '0';
        abort         <= '0';

      elsif (enable = '1') then
        if (count_1_carry = '0') or (count_2_max = '0') then
          -- Lower 16-bit counter
          count_1 <= count_1 + '1';

          -- Create carry signal from first counter.
          if count_1 = x"FFFE" then
            count_1_carry <= '1';
          else
            count_1_carry <= '0';
          end if;

          -- Upper 16-bit counter
          if count_1_carry = '1' then
            count_2 <= count_2 + '1';
            if (count_2 = x"FFFE") then
              count_2_max <= '1';
            end if;
          end if;

        end if;
        if count_2 = x"FFFF" and count_1 = x"FFC0" then
          abort           <= '1';
        end if;
      end if;
    end if;
  end process;


  -- Connect up output
  count <= (count_2 & count_1);


end rtl;

