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
-- Title       : Combinatorial Muliplexer
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component is a parameterised AND-OR multiplexer. Each
--               mux input has a one-hot select which is ANDed with the data.
--               The AND outputs are then ORed together. The input that is
--               enabled is the only one which propagates through to the mux
--               output.
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity cmux is
  generic (
    WIDTH     : integer := 8;           -- width of each bus
    SELSZ     : integer := 8            -- number of busses
    );
  port (
    -- concatenated input data vectors
    data      : in  std_logic_vector((WIDTH*SELSZ)-1 downto 0);
    -- 'one hot' input mux select vector
    sel       : in  std_logic_vector(SELSZ-1 downto 0);
    -- output of final mux stage
    z         : out std_logic_vector(WIDTH-1 downto 0)
    );
end cmux;

architecture rtl of cmux is

begin

  process(data, sel)
    variable and_en     : std_logic_vector((WIDTH*SELSZ)-1 downto 0);
    variable casc       : std_logic_vector(SELSZ-1 downto 0);
    variable or_op      : std_logic_vector(WIDTH-1 downto 0);

  begin
    -- This block ANDs all the data inputs with the relevant select 
    for j in 0 to SELSZ-1 loop
      for i in 0 to WIDTH-1 loop
        and_en(i+j*WIDTH) := sel(j) and data(i+j*WIDTH);
      end loop;
    end loop;

    for j in 0 to WIDTH-1 loop
      -- This inner loop ORs all the terms together for that
      -- mux bit output position
      for k in 0 to SELSZ-1 loop
        if (k = 0) then
          casc(k)  := and_en(j);
        else
          casc(k)  := and_en(j+(k*WIDTH)) or casc(k-1);
          -- result of the OR of all the AND terms for that bit
          -- position 
          or_op(j) := casc(k);
        end if;
      end loop;
    end loop;

    z <= or_op;

  end process;

end rtl;
