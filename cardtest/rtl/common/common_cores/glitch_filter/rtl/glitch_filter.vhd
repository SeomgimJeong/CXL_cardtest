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
-- Title       : Glitch Filter
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : 
--
-- The input to this block needs to be high for DEPTH number of consecutive
-- cycles before it is passed to the output. 
-- 
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pkg_global.all;

entity glitch_filter is
  generic (
    DEPTH :     integer := 2);           -- depth of compare (in clock cycles)
  port (
    reset : in  std_logic;
    clock : in  std_logic;
    d     : in  std_logic;
    q     : out std_logic);

end glitch_filter;

architecture rtl of glitch_filter is

  signal q_i : std_logic_vector(DEPTH-1 downto 0);

begin

  process (clock) is


  begin
    if rising_edge(clock) then
    
      if (reset = '1') then
        q_i        <= (others => '0');
        q          <= '0';
      else
        for i in 0 to DEPTH-1 loop
          if i = 0 then
            q_i(i) <= d;
          else
            q_i(i) <= q_i(i-1);
          end if;
        end loop;

        q <= and_reduce(q_i);
       
      end if;
    end if;  
  end process;


end rtl;




