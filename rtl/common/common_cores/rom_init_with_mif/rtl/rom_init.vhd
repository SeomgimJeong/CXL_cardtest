library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_init is
  port(
    clock         : in  std_logic;
    data          : in  unsigned (7 downto 0);
    write_address : in  integer range 0 to 31;
    read_address  : in  integer range 0 to 31;
    we            : in  std_logic;
    q             : out unsigned (7 downto 0));
end;

architecture rtl of rom_init is

  type MEM is array(31 downto 0) of unsigned(7 downto 0);

  -- function initialize_ram
  --   return MEM is
  --   variable result : MEM;
  -- begin
  --   for i in 31 downto 0 loop
  --     result(i) := to_unsigned(natural(i), natural'(8));
  --   end loop;
  --   return result;
  -- end initialize_ram;

--    SIGNAL ram_block : MEM := initialize_ram;

  signal ram_block : MEM;

  attribute ram_init_file : string;

  attribute ram_init_file of ram_block : signal is "my_init_file.mif";

begin
  process (clock)
  begin
    if (rising_edge(clock)) then
      if (we = '1') then
        ram_block(write_address) <= data;
      end if;
      q <= ram_block(read_address);
    end if;
  end process;
end rtl;
