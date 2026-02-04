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
-- Title       : Shift Reg Cooker Test
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component instantiates a byte wide chain of LUT-FF pairs
--               and drives them with a PRBS test pattern.
--
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity sreg_cook_test is
  generic (
    NUM_X8_REG                : integer := 2000   -- No of x8 LUT-FF blocks
    );
  port (
    clk                       : in  std_logic;
    async_rst                 : in  std_logic;
    reg_en                    : in  std_logic_vector(7 downto 0);
    reg_out                   : out std_logic
    );
end entity sreg_cook_test;


architecture rtl of sreg_cook_test is

  ---------
  -- Types
  ---------
  type T_sreg is array (0 to NUM_X8_REG-1) of std_logic_vector(7 downto 0);

  -----------
  -- Signals
  -----------
  signal prbs_gen             : std_logic_vector(8 downto 0)          := (others => '1');
  signal sreg                 : T_sreg;

  attribute noprune: boolean;
  attribute preserve: boolean;
  attribute keep: boolean;
  attribute noprune of sreg      : signal is true;
  attribute preserve of sreg     : signal is true;
  attribute keep of sreg         : signal is true; 
  attribute noprune of prbs_gen  : signal is true;
  attribute preserve of prbs_gen : signal is true;
  attribute keep of prbs_gen     : signal is true; 

begin

  process(clk, async_rst)

  variable prbs_v             : std_logic_vector(8 downto 0);
  variable reg_out_v          : std_logic;

  begin
    if async_rst = '1' then 
      prbs_gen <= (others => '1');

    elsif rising_edge(clk) then
      -- PRBS generator.
      if prbs_gen = "000000000" then
        prbs_gen <= (others => '1');
      else
        prbs_v := prbs_gen;
        for i in 0 to 1 loop
          prbs_v := (prbs_v(7 downto 0) & (prbs_v(4) xor prbs_v(8)));
        end loop;
        prbs_gen <= prbs_v;
      end if;
    end if;

    if rising_edge(clk) then
      -- Create input byte (each bit has an associated enable).
      for i in 0 to 7 loop
        sreg(0)(i) <= prbs_gen(i+1) and reg_en(i);
      end loop;

      -- Create byte wide chain of LUT-FF pairs (bit 7 controls
      -- the polarity of the next byte).
      for j in 1 to (NUM_X8_REG-1) loop
        for k in 0 to 6 loop
          sreg(j)(k) <= sreg(j-1)(k) xor sreg(j-1)(7);
        end loop;
        sreg(j)(7) <= not sreg(j-1)(7);           -- Polarity
      end loop;

      -- Create the final output.
      reg_out_v := '0';
      for i in 0 to 7 loop
        reg_out_v := reg_out_v xor sreg(NUM_X8_REG-1)(i);
      end loop;
      reg_out <= reg_out_v;

    end if;

  end process;


end rtl;

