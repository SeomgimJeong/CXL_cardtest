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
-- Title       : Clock Generator (fast)
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : The clock divider runs continuously from 'clk'. It divides
--               'clk' by 2, 4, 6, 8 and 10 to produce individual outputs.
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


entity clock_gen_fast is
  port (
    clk                 : in  std_logic;
    clk_out             : out std_logic_vector(4 downto 0)
    );
end clock_gen_fast;


architecture rtl of clock_gen_fast is
  -----------
  -- Signals
  -----------
  signal clk_out_a1           : std_logic_vector(4 downto 0)          := (others => '0');
  signal clk_out_i            : std_logic_vector(4 downto 0)          := (others => '0');
  signal div_2                : std_logic                             := '0';
  signal div_4                : std_logic_vector(1 downto 0)          := (others => '0');
  signal div_6                : std_logic_vector(2 downto 0)          := (others => '0');
  signal div_8                : std_logic_vector(3 downto 0)          := (others => '0');
  signal div_10               : std_logic_vector(4 downto 0)          := (others => '0');

begin

  process(clk)
  begin
    if rising_edge(clk) then
      -- Divide by 2
      div_2         <= not div_2;
      clk_out_a1(0) <= div_2;

      -- Divide by 4
      div_4         <= (div_4(0) & not div_4(1));
      clk_out_a1(1) <= div_4(1);

      -- Divide by 6
      div_6(1 downto 0) <= (div_6(0) & not div_6(2));
      div_6(2)          <= (div_6(0) or div_6(2)) and div_6(1);
      clk_out_a1(2)     <= div_6(2);

      -- Divide by 8
      div_8(1 downto 0) <= (div_8(0) & not div_8(3));
      div_8(2)          <= (div_8(0) or div_8(2)) and div_8(1);
      div_8(3)          <= div_8(2);
      clk_out_a1(3)     <= div_8(3);

      -- Divide by 10
      div_10(1 downto 0) <= (div_10(0) & not div_10(4));
      div_10(2)          <= (div_10(0) or div_10(2)) and div_10(1);
      div_10(4 downto 3) <= (div_10(3) & div_10(2));
      clk_out_a1(4)      <= div_10(4);

      -- Pipeline the output so it can be mapped into a GPIO registers
      clk_out_i <= clk_out_a1;

    end if;
  end process;


  -- Connect up output
  clk_out <= clk_out_i;


end rtl;
