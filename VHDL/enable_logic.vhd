-- Noah White
-- Section #: 11088

-- Not necessarily tested yet

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity enable_logic is
    generic(WIDTH : positive := 32);
    port (
        addr            : in std_logic_vector(WIDTH-1 downto 0);
        wr_en           : in std_logic;
        outport_wr_en   : out std_logic;
        RAM_wr_en       : out std_logic;
        mux_sel         : out std_logic_vector(1 downto 0)
    );
end enable_logic;


architecture behavioral of Enable_logic is
    
begin
    process(addr, wr_en)
    begin
        outport_wr_en <= '0';
        RAM_wr_en <= '0';
        mux_sel <= "11"; -- default select of nothing

        if wr_en = '1' then
            if addr = X"0000FFFC" then
                outport_wr_en <= '1';
            else
                RAM_wr_en <= '1';
            end if;
        end if;

        if addr = X"0000FFF8" then
            mux_sel <= "00";
        elsif addr = X"0000FFFC" then
            mux_sel <= "01";
        else
            mux_sel <= "10";
        end if; 
    end process;

end behavioral;

