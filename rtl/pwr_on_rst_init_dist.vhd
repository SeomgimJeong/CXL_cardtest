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
-- Title       : Power On Reset (with output distribution)
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : The output of the Power On Reset component (por_n) has an
--               initial value of '0' when the FPGA configures. After a period
--               of time the output goes to '1' and  remains there until the
--               FPGA is reconfigured. The Power On Reset time is:
--
--                 Period of 'clk' * NUMBER_OF_CYCLES (32-bit)
--
--
--               Example
--               -------
--               For a 'clk' frequency of 100MHz (period = 10ns) and a desired
--               Power On Reset time of 10ms: NUMBER_OF_CYCLES => x"000F4240"
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


entity pwr_on_rst_init_dist is
  generic (
    NUMBER_OF_CYCLES    : std_logic_vector(31 downto 0)         := x"000F4240";
    FAN_OUT             : integer := 16
    );
  port (
    clk                 : in  std_logic;
    init_done_n         : in  std_logic;
    por_n               : out std_logic_vector(FAN_OUT-1 downto 0)
    );
end pwr_on_rst_init_dist;


architecture rtl of pwr_on_rst_init_dist is
  ------------
  -- Constant
  ------------
  constant POR_CYCLES         : std_logic_vector(31 downto 0)         := NUMBER_OF_CYCLES-2;

  -----------
  -- Signals
  -----------
  signal init_done_meta       : std_logic_vector(1 downto 0)          := (others => '0');
  signal count_0              : std_logic_vector(15 downto 0)         := (others => '0');
  signal count_1              : std_logic_vector(15 downto 0)         := (others => '0');
  signal carry_0              : std_logic                             := '0';
  signal compare              : std_logic_vector(3 downto 0)          := (others => '0');
  signal por_n_a1             : std_logic                             := '0';
  signal por_n_i              : std_logic_vector(FAN_OUT-1 downto 0)  := (others => '0');

  --------------
  -- Attributes
  --------------
  attribute preserve : boolean;
  attribute preserve of por_n_i : signal is true;
  attribute preserve of init_done_meta : signal is true;


begin
  process(clk)
  begin
    if rising_edge(clk) then
      -- Double register asynchronous input
      init_done_meta <= (init_done_meta(0) & not init_done_n);

      -- 32-bit counter with synchronous reset
      -- (constructed from two 16-bit counters with look-ahead carry)
      if init_done_meta(1) = '0' then
        count_0  <= (others => '0');
        count_1  <= (others => '0');
        carry_0  <= '0';
        compare  <= (others => '0');
        por_n_a1 <= '0';

      else
        if por_n_a1 = '0' then
          count_0 <= count_0 + 1;

          if count_0 = x"FFFE" then
            carry_0 <= '1';
          else
            carry_0 <= '0';
          end if;

          if carry_0 = '1' then
            count_1 <= count_1 + 1;
          end if;
        end if;

        -- Compare each bytes of the 32-bit counter
        if count_0(7 downto 0) = POR_CYCLES(7 downto 0) then
          compare(0) <= '1';
        else
          compare(0) <= '0';
        end if;

        if count_0(15 downto 8) = POR_CYCLES(15 downto 8) then
          compare(1) <= '1';
        else
          compare(1) <= '0';
        end if;

        if count_1(7 downto 0) = POR_CYCLES(23 downto 16) then
          compare(2) <= '1';
        else
          compare(2) <= '0';
        end if;

        if count_1(15 downto 8) = POR_CYCLES(31 downto 24) then
          compare(3) <= '1';
        else
          compare(3) <= '0';
        end if;

        -- Combine the four compare signals to set 'por_out'
        if compare = "1111" then
          por_n_a1 <= '1';
        end if;
      end if;

      -- Distribute the POR signal
      por_n_i <= (others => por_n_a1);

    end if;
  end process;


  -- Connect up output
  por_n <= por_n_i;


end rtl;
