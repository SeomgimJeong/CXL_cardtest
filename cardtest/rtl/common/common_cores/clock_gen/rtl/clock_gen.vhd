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
-- Title       : Clock Generator
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : The clock generator runs continuously from 'clk'.
--               It divides 'clk' to produce an output at the desired
--               frequency with a 50/50 mark/space ratio.
--
--               Example
--               -------
--               For a 'clk' frequency of 100MHz and a desired 'clk_out'
--               frequency of 1kHz, set DIVISOR = 100000000/1000 = 100000
--
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


entity clock_gen is
  generic (
    DIVISOR             : integer       := 100000
    );
  port (
    clk                 : in  std_logic;
    clk_out             : out std_logic
    );
end clock_gen;


architecture rtl of clock_gen is
  -----------
  -- Signals
  -----------
  signal count                : std_logic_vector(15 downto 0)         := (others => '0');
  signal clk_out_a1           : std_logic                             := '0';
  signal clk_out_i            : std_logic                             := '0';

begin

  process(clk)
  begin
    if rising_edge(clk) then
      -- Counter to divide the 'clk' input
      if (count = (DIVISOR/2) - 1) then
        count      <= (others => '0');
        clk_out_a1 <= not clk_out_a1;
      else
        count      <= count + 1;
      end if;

      -- Pipeline the output so it can be mapped into a GPIO register
      clk_out_i <= clk_out_a1;

    end if;
  end process;


  -- Connect up output
  clk_out <= clk_out_i;


end rtl;
