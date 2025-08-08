-- Noah White
-- Section #: 11088

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extend is
    port (
        input               : in std_logic_vector(15 downto 0);
        IsSigned            : in std_logic;
        output              : out std_logic_vector(31 downto 0)
    );
end sign_extend;


architecture behavioral of sign_extend is
    
begin

process(input, IsSigned)
begin
    if IsSigned = '1' then
        -- Sign extend: fill upper bits with the sign bit (bit 15)
        output <= (15 downto 0 => input(15)) & input;
    else
        -- Zero extend
        output <= (15 downto 0 => '0') & input;
    end if;
end process;
    
end behavioral;

