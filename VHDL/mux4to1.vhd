-- Noah White
-- Section #: 11088

-- Not necessarily tested yet

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY mux4to1 IS
	generic(WIDTH : positive	:= 32);
    PORT(d0, d1, d2, d3 : IN  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
         s              : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
         mux_out        : OUT STD_LOGIC_VECTOR(WIDTH-1 downto 0));
END mux4to1;

ARCHITECTURE Behavior OF mux4to1 IS
BEGIN
	mux_out <= 
		d0 when s = "00" else
		d1 when s = "01" else
		d2 when s = "10" else
		d3 when s = "11" else
		(others => '0'); -- Default

END Behavior;
