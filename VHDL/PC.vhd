-- Noah White
-- Section #: 11088
-- The instructions are kind of unclear on this so may need to change it later
-- Might just change it to a register lol

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    generic(WIDTH : positive := 32);
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        input           : in std_logic_vector(WIDTH-1 downto 0);
        ctrl            : in std_logic;                             -- Equivalent to enable signal
        addr            : out std_logic_vector(WIDTH-1 downto 0)
    );
end PC;


architecture behavioral of PC is
    signal count : std_logic_vector(WIDTH-1 downto 0);
begin
    
counting: process(clk, rst)
begin
    if rst = '1' then
        count <= (others => '0');
    elsif rising_edge(clk) then
        if (ctrl = '1') then
            if (count = X"FFFFFFFF") then
                count <= (others => '0');
            else
                count <= std_logic_vector(unsigned(count) + 1);
            end if;
        end if;
    end if;
end process counting;

addr <= count;
    
end behavioral;
