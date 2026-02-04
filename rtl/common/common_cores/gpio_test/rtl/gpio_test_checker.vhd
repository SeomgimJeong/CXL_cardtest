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
-- Title       : GPIO_TEST loopback checker
-- Project     : IA-420F
--------------------------------------------------------------------------------
-- Description : A simple test output driver
--               On a positive edge clock cycle, the bit values increment,
--               rolling over where necessary.
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


entity gpio_test_checker is
  generic (
    data_width         : integer := 4;
    lock_window        : integer := 8
    );
  port (
    clock           : in    std_logic;
    sync_reset      : in    std_logic;
    enable          : in    std_logic;
    data            : in    std_logic_vector(data_width-1 downto 0); --incoming data
    data_error      : out   std_logic;                               --data error
    lock            : out   std_logic;
    data_check      : out   std_logic_vector(data_width-1 downto 0)
    );
end entity gpio_test_checker;

architecture rtl of gpio_test_checker is

    signal data_i               : std_logic_vector(data_width-1 downto 0)    := (others => '0');
    signal data_expected        : std_logic_vector(data_width-1 downto 0)    := (others => '0');
    signal data_error_i         : std_logic := '0';
    signal lock_i               : std_logic := '0';
    signal lock_o               : std_logic := '0';
    signal lock_window_i        : std_logic_vector(lock_window-1 downto 0)   := (others => '0');

begin

--reset condition and data sampling
process (clock)
  begin
  if rising_edge (clock) then

    if (sync_reset) = '1' then
      data_expected       <= (others => '0');
      data_i              <= (others => '0');
      data_error_i        <= '0';
      lock_i              <= '0';
      lock_window_i       <= (others => '0');
      lock_o              <= '0';
    else
      data_i                                  <= data;
      lock_window_i(lock_window-1 downto 1)   <= lock_window_i(lock_window-2 downto 0);
      lock_window_i(0)                        <= lock_i;

      if (enable = '0') then
      lock_o <= '0';
      lock_window_i       <= (others => '0');
      end if;

      if (and_reduce(lock_window_i) = '1') then
      lock_o              <= '1';
      end if;

      if (enable = '1')  then
        if (and_reduce(data_expected) = '1') then
          data_expected <= (others => '0');
        else
          data_expected <= data_expected + 1;
        end if;

        if (data_expected /= data_i) then
          data_error_i  <= '1';
          lock_i        <= '0';
        else
          data_error_i  <= '0';
          lock_i        <= '1';
        end if;

      end if;
    end if;
  end if;
end process;

--connect outputs
  data_error   <= data_error_i;
  lock         <= lock_o;
  data_check   <= data_expected;

end architecture rtl;
