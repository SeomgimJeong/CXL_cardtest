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
-- Title       : Error Counter (64-bit)
-- Project     : Multi
--------------------------------------------------------------------------------
-- Description : An pipelined Error Counter component that takes in a 64-bit
--               'data' vector where every '1' indicates an error. The total
--               number of errors indicated on each enabled 'data' vector are
--               added to a 16-bit accumulator. The accumulator stops when it
--               reaches full scale (0xFFFF).
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


entity err_count_64 is
  port (
    clock               : in  std_logic;
    sync_reset          : in  std_logic;
    enable              : in  std_logic;
    data                : in  std_logic_vector(63 downto 0);
    count               : out std_logic_vector(15 downto 0)
    );
end err_count_64;


architecture rtl of err_count_64 is
  ---------
  -- Types
  ---------
  type T_sum_error_8x4 is array (0 to 7) of std_logic_vector(3 downto 0);
  type T_sum_error_2x6 is array (0 to 1) of std_logic_vector(5 downto 0);

  -----------
  -- Signals
  -----------
  signal sum_error_8x4        : T_sum_error_8x4                       := (others => (others => '0'));
  signal sum_error_2x6        : T_sum_error_2x6                       := (others => (others => '0'));
  signal sum_error            : std_logic_vector(6 downto 0)          := (others => '0');
  signal err_count            : std_logic_vector(15 downto 0)         := (others => '0');


begin
  process(clock)

    variable sum_error_v      : std_logic_vector(3 downto 0);

  begin
    if rising_edge(clock) then
      if sync_reset = '1' then
        sum_error_8x4 <= (others => (others => '0'));
        sum_error_2x6 <= (others => (others => '0'));
        sum_error     <= (others => '0');
        err_count     <= (others => '0');

      elsif enable = '1' then
        -- First stage adders (8) - each sums 8-bits of the 'data' vector.
        for j in 0 to 7 loop
          sum_error_v := (others => '0');
          for i in 0 to 7 loop
            if data(i+(j*8)) = '1' then
              sum_error_v := sum_error_v + 1;
            end if;
          end loop;
          sum_error_8x4(j) <= sum_error_v;
        end loop;

        -- Second stage adders (2) - each sums the outputs of 4 first stage adders.
        for i in 0 to 1 loop
          sum_error_2x6(i) <= ("00" & sum_error_8x4(0+(i*4))) +
                              ("00" & sum_error_8x4(1+(i*4))) +
                              ("00" & sum_error_8x4(2+(i*4))) +
                              ("00" & sum_error_8x4(3+(i*4)));
        end loop;

        -- Third stage adder (1) - sums the outputs of the 2 second stage adders.
        sum_error <= ('0' & sum_error_2x6(0)) +
                     ('0' & sum_error_2x6(1));

        -- Stop error count from wrapping around. This is done by parking the counter 
        -- at its maximum count (0xFFFF) when it reaches a value of greater than its 
        -- maximum count minus 64.
        if err_count > x"FFBF" then
          err_count <= x"FFFF";
        else
          err_count <= err_count + sum_error;
        end if;
      end if;

    end if;
  end process;


  count <= err_count;


end rtl;
