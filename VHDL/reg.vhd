-- Noah White
-- Section #: 11088

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity reg is
    generic(WIDTH : positive := 32);
    port(clk    : in  std_logic;
         rst    : in  std_logic;
         en     : in std_logic;
         input  : in  std_logic_vector(WIDTH-1 downto 0);
         output : out std_logic_vector(WIDTH-1 downto 0));
end reg;

architecture BHV of reg is
begin
    process(clk, rst, en)
    begin
        if (rst = '1') then
            output <= (others => '0');
        elsif (rising_edge(clk) and en = '1') then
            output <= input;
        end if;       
    end process;
end BHV;