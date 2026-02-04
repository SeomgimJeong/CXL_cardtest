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
-- Title       : BRAM Cooker Test (version 2)
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component instantiates 8x 64-bit wide data paths through
--               chains of BRAM FIFOs, driving them with a PRBS test pattern.
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


entity bram_cook_test is
  generic (
    NUM_BRAM                  : integer := 32     -- No of BRAMs
    );
  port (
    clk                       : in  std_logic;
    async_rst                 : in  std_logic;
    byte_en                   : in  std_logic_vector(7 downto 0);
    bram_out                  : out std_logic
    );
end entity bram_cook_test;


architecture rtl of bram_cook_test is
  ---------
  -- Types
  ---------
  type T_prbs   is array (0 to 7)              of std_logic_vector(8 downto 0);
  type T_reg    is array (0 to (NUM_BRAM/8)-1) of std_logic_vector(63 downto 0);
  type T_reg_x8 is array (0 to 7)              of T_reg;
  type T_bit_x8 is array (0 to 7)              of std_logic_vector((NUM_BRAM/8)-1 downto 0);
  type T_64b_x8 is array (0 to 7)              of std_logic_vector(63 downto 0);
  type T_8b_x8  is array (0 to 7)              of std_logic_vector(7 downto 0);

  -------------
  -- Constants
  -------------
  constant PRBS_INIT          : T_prbs            := ("111111110","111111101","111111011","111110111","111101111","111011111","110111111","101111111");

  -----------
  -- Signals
  -----------
  signal prbs_gen             : T_prbs                                := PRBS_INIT;
  signal reg                  : T_reg_x8                              := (others => (others => (others => '0')));
  signal rd_data              : T_reg_x8                              := (others => (others => (others => '0')));
  signal wr_enab              : T_bit_x8                              := (others => (others => '0'));
  signal rd_enab              : T_bit_x8;
  signal empty                : T_bit_x8;
  signal reg_last             : T_64b_x8                              := (others => (others => '0'));
  signal bram_out_a3          : T_8b_x8                               := (others => (others => '0'));
  signal bram_out_a2          : std_logic_vector(7 downto 0)          := (others => '0');
  signal bram_out_a1          : std_logic                             := '0';

begin

  process(clk, async_rst)
    variable prbs_v           : std_logic_vector(8 downto 0);
  begin
    if async_rst = '1' then 
      prbs_gen <= PRBS_INIT;

    elsif rising_edge(clk) then
      -- PRBS Generators (8x 9-bit)
      for j in 0 to 7 loop
        if prbs_gen(j) = "000000000" then
          prbs_gen(j) <= PRBS_INIT(j);
        else
          prbs_v := prbs_gen(j);
          for i in 0 to 7 loop
            prbs_v := (prbs_v(7 downto 0) & (prbs_v(4) xor prbs_v(8)));
          end loop;
          prbs_gen(j) <= prbs_v;
        end if;
      end loop;
    end if;
  end process;


  g0 : for k in 0 to 7 generate
  begin
    process(clk)
      variable bram_out_v     : std_logic;
    begin
      if rising_edge(clk) then
        -- Create BRAM chain input word (each byte has an associated enable)
        for j in 0 to 7 loop
          for i in 0 to 7 loop
            reg(k)(0)((j*8)+i) <= prbs_gen(j)(i);
          end loop;
        end loop;

        -- Register subsequent input words along the chain
        for i in 1 to ((NUM_BRAM/8)-1) loop
          if empty(k)(i-1) = '0' then
            reg(k)(i) <= rd_data(k)(i-1);
          end if;
        end loop;

        -- Create first write enable (enabled on average for 15/16 clk cycles)
        if byte_en(k) = '1' then
          wr_enab(k)(0) <= prbs_gen(k)(0) or prbs_gen(k)(1) or prbs_gen(k)(2) or prbs_gen(K)(3);
        else
          wr_enab(k)(0) <= '0';
        end if;

        -- Create subsequent write enables along the chain
        for i in 1 to ((NUM_BRAM/8)-1) loop
          wr_enab(k)(i) <= not empty(k)(i-1);
        end loop;

        -- Register final output
        if empty(k)((NUM_BRAM/8)-1) = '0' then
          reg_last(k) <= reg(k)((NUM_BRAM/8)-1);
        end if;

        -- Combine bits (stage 1)
        for j in 0 to 7 loop
          bram_out_v := '0';
          for i in 0 to 7 loop
            bram_out_v := bram_out_v xor reg_last(k)((j*8)+i);
          end loop;
          bram_out_a3(k)(j) <= bram_out_v;
        end loop;

        -- Combine bits (stage 2)
        bram_out_v := '0';
        for i in 0 to 7 loop
          bram_out_v := bram_out_v xor bram_out_a3(k)(i);
        end loop;
        bram_out_a2(k) <= bram_out_v;

      end if;
    end process;


    g1 : for i in 0 to ((NUM_BRAM/8)-1) generate
    begin 
      i_bram : entity work.general_fifo
      generic map (
        DWIDTH                    => 64,
        AWIDTH                    => 9,
        ALMOST_FULL_THOLD         => 500,
        RAMTYPE                   => "block",
        FIRST_WORD_FALL_THRU      => TRUE
        )
      port map(
        write_clock               => clk,               -- in  std_logic;
        read_clock                => clk,               -- in  std_logic;
        fifo_flush                => '0',               -- in  std_logic;
        write_enable              => wr_enab(k)(i),     -- in  std_logic;
        write_data                => reg(k)(i),         -- in  std_logic_vector(DWIDTH-1 downto 0);
        read_enable               => rd_enab(k)(i),     -- in  std_logic;
        read_data                 => rd_data(k)(i),     -- out std_logic_vector(DWIDTH-1 downto 0);
        almost_full               => open,              -- out std_logic;
        depth                     => open,              -- out std_logic_vector(AWIDTH-1 downto 0);
        empty                     => empty(k)(i)        -- out std_logic
        );

      rd_enab(k)(i) <= not empty(k)(i);

    end generate;
  end generate;


  process(clk)
    variable bram_out_v       : std_logic;
  begin
    if rising_edge(clk) then
      -- Combine bits (stage 3)
      bram_out_v := '0';
      for k in 0 to 7 loop
        bram_out_v := bram_out_v xor bram_out_a2(k);
      end loop;
      bram_out_a1 <= bram_out_v;
      bram_out    <= bram_out_a1;
    end if;
  end process;


end rtl;
