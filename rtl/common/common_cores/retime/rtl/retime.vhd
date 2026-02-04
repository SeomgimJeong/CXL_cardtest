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
-- Title       : Retime
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component piplines a bus by number of clock cycles:
--
--                 WIDTH = Width of the bus
--                 DEPTH = Number of clock cycles of delay
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity retime is
  generic (
    DEPTH     : integer := 2;           -- depth of retime (in clock cycles)
    WIDTH     : integer := 1            -- width of retime (in bits)
    );
  port (
    reset     : in  std_logic;
    clock     : in  std_logic;
    d         : in  std_logic_vector(WIDTH-1 downto 0);
    q         : out std_logic_vector(WIDTH-1 downto 0)
    );
end retime;

architecture rtl of retime is

  ---------
  -- Types
  ---------
  type retType is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);

  -----------
  -- Signals
  -----------
  signal q_i            : retType       := (others => (others => '0'));

begin

  process (clock) is
  begin
    if rising_edge(clock) then
      if (reset = '1') then
        q_i        <= (others => (others => '0'));
      else
        for i in 0 to DEPTH-1 loop
          if i = 0 then
            q_i(i) <= d;
          else
            q_i(i) <= q_i(i-1);
          end if;
        end loop;
      end if;
    end if;
  end process;

  -- Connect up output.
  q <= q_i(DEPTH-1);

end rtl;
