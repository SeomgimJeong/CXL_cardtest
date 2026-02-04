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
-- Title       : GPIO_TEST driver
-- Project     : IA-420F
--------------------------------------------------------------------------------
-- Description : A simple test output driver
--               On a positive edge clock cycle, the bit values increment,
--               rolling over.
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
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;


entity gpio_test_output is
  generic (
    data_width         : integer := 4
    );
  port (
    clock           : in    std_logic;
    sync_reset      : in    std_logic;
    enable          : in    std_logic;
    data            : out   std_logic_vector(data_width-1 downto 0)
    );
end entity gpio_test_output;

architecture rtl of gpio_test_output is

    signal data_out      : std_logic_vector(data_width-1 downto 0)    := (others => '0');

begin

process (clock)
begin
    if rising_edge (clock) then
     if (sync_reset) = '1' then
       data_out       <= (others => '0');
      else
       if (enable = '1') then
         if (and_reduce(data_out) = '1') then
            data_out <= (others => '0');
          else
            data_out <= data_out + 1;
            end if;
        end if;
      end if;
    end if;
end process;

--connect outputs
  data <= data_out;

end architecture rtl;
