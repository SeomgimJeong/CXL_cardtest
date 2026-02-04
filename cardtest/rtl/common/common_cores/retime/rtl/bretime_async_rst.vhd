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
-- Title       : Bit Retime
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component passes a signal through a series of registers.
--                 * The number of registers is set by the generic 'DEPTH'
--
--               Typical uses of this component include:
--                 * Meta-stability protection when crossing clock domains.
--                 * Adding a pipeline delay to a signal.
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity bretime_async_rst is
  generic (
    DEPTH     : integer := 2           -- depth of retime (in clock cycles)
    );
  port (
    clock     : in  std_logic;
    d         : in  std_logic;
    q         : out std_logic
    );
end bretime_async_rst;


architecture rtl of bretime_async_rst is

  -----------
  -- Signals
  -----------
  signal shift_reg            : std_logic_vector(DEPTH-1 downto 0)    := (others => '0');

begin

  process(clock)
  begin
    if rising_edge(clock) then
      if DEPTH = 1 then
        shift_reg(0) <= d;
      else
        shift_reg <= (shift_reg(DEPTH-2 downto 0) & d);
      end if;

    end if;
  end process;


  -- Connect up output.
  q <= shift_reg(DEPTH-1);


end rtl;
