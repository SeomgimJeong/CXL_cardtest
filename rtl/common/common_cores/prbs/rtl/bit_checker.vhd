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
-- Title       : Bit Checker
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : Parameterised Bit checker.
--
--               This module compares two incoming data patterns (input_0 &
--               input_1), any differences are indicated by a '1' on the
--               associated bit position of the 'data' port.
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
use ieee.std_logic_arith.all;


entity bit_checker is
  generic (
    data_width          : integer := 8            -- Width of input data pipe
    );
  port (
    clock               : in  std_logic;
    sync_reset          : in  std_logic;
    enable              : in  std_logic;
    input_0             : in  std_logic_vector(data_width-1 downto 0);
    input_1             : in  std_logic_vector(data_width-1 downto 0);
    data                : out std_logic_vector(data_width-1 downto 0)
    );
end entity bit_checker;


architecture rtl of bit_checker is

  -- Signals
  signal data_i         : std_logic_vector(data_width-1 downto 0)     := (others => '0');


begin
  process(clock)
  begin
    if rising_edge(clock) then
      if sync_reset = '1' then
        data_i <= (others => '0');

      elsif enable = '1' then
        for i in 0 to data_width - 1 loop
          data_i(i) <= input_0(i) xor input_1(i);
        end loop;
      end if;

    end if;
  end process;

  -- Connect up output.
  data <= data_i;


end rtl;
