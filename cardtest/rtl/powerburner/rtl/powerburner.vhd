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
-- Title       : Powerburner
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component provides a configurable dummy logic BRAM, DSP
--               and FF power consumption element. This instantiation can be
--               customised to target a power consumption level
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all;

entity powerburner is
  generic
    (
    BRAM_INSTANCE_SIZE     : natural   := 32;   -- Quantity of BRAM block
    X8_REG_INSTANCE_SIZE   : natural   := 12;   -- Quantity of FF Block
    DSP_INSTANCE_SIZE      : natural   := 32    -- Quanity of DSP Block
      );
  port(
    core_clk       : in  std_logic;  -- Higher Frequency = Higher switching rate of BRAM
    enable         : in  std_logic;
    reset          : in  std_logic;
    block_enable   : in  std_logic_vector(23 downto 0);
    pb_running     : out std_logic   -- Signals to external controller that control engine is ready to release blocks
    );
end powerburner;

architecture rtl of powerburner is

  -----------
  -- Signals
  -----------
  signal status_running_i              : std_logic                          := '0';
  signal bram_enable_i                 : std_logic_vector(7 downto 0)       := (others => '0');
  signal sreg_enable_i                 : std_logic_vector(7 downto 0)       := (others => '0');
  signal dsp_enable_i                  : std_logic_vector(7 downto 0)       := (others => '0');

  ----------------
  -- Attributes
  ----------------
  attribute noprune: boolean;
  attribute preserve: boolean;
  attribute keep: boolean;
  attribute noprune of bram_enable_i     : signal is true;
  attribute noprune of sreg_enable_i     : signal is true;
  attribute noprune of dsp_enable_i      : signal is true;
  attribute noprune of status_running_i  : signal is true; 
  attribute preserve of bram_enable_i    : signal is true;
  attribute preserve of sreg_enable_i    : signal is true;
  attribute preserve of dsp_enable_i     : signal is true;
  attribute preserve of status_running_i : signal is true; 
  attribute keep of bram_enable_i        : signal is true;
  attribute keep of sreg_enable_i        : signal is true;
  attribute keep of dsp_enable_i         : signal is true;
  attribute keep of status_running_i     : signal is true; 

begin

  process (core_clk, reset, enable)
  begin
    if rising_edge(core_clk) then
      if reset = '1' or enable = '0' then
        bram_enable_i      <= (others => '0');
        sreg_enable_i      <= (others => '0');
        dsp_enable_i       <= (others => '0');
        status_running_i   <= '0';  
      else
        bram_enable_i      <= block_enable(7 downto 0);
        sreg_enable_i      <= block_enable(15 downto 8);
        dsp_enable_i       <= block_enable(23 downto 16); 
        status_running_i   <= '1';              
     end if; 
    end if;
  end process;


--Instantiate BRAM test
  bram_cook_test : entity work.bram_cook_test 
  generic map(
    NUM_BRAM    => BRAM_INSTANCE_SIZE 
    )
  port map(
    clk            => core_clk,
    async_rst      => reset,
    byte_en        => bram_enable_i,
    bram_out       => open
  );

--Instantiate SREG test
  sreg_cook_test : entity work.sreg_cook_test
  generic map(
    NUM_X8_REG     => X8_REG_INSTANCE_SIZE 
    )
  port map(
    clk            => core_clk,
    async_rst      => reset,
    reg_en         => sreg_enable_i,
    reg_out        => open   
    );

--Instantiate DSP test
  dsp_cook_test : entity work.dsp_cook_test
  generic map(
    NUM_DSP        => DSP_INSTANCE_SIZE 
    )
  port map(
    clk            => core_clk,
    async_rst      => reset,
    dsp_en         => dsp_enable_i,
    dsp_out        => open    
    );

pb_running     <= status_running_i;

end rtl;
