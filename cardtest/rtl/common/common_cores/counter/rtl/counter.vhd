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
-- Title       : Counter
-- Project     : Common Gateware
---------------------------------------------------------------------------
-- Description : Parametised counter 
--
---------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is
generic (
      WIDTH   : integer := 31
      );
port (
      reset   : in  std_logic;
      enable  : in  std_logic;
      clock   : in  std_logic;
      count   : out std_logic_vector(WIDTH-1 downto 0)
      );
end counter;

architecture rtl of counter is

signal count_i : std_logic_vector(WIDTH-1 downto 0);

begin

process (clock) is
begin
      if rising_edge(clock) then
        if (reset = '1') then
          count_i <= (others => '0');
        elsif enable = '1' then
          count_i <= count_i + '1';
        end if;
      end if;
end process;

count <= count_i;

end rtl;




