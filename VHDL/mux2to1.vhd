-- Noah White
-- Section #: 11088

-- Not necessarily tested yet

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY mux2to1 IS
	generic(WIDTH : positive	:= 32);
    PORT(d0, d1			: IN  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
         s				: IN  std_logic;
         mux_out        : OUT STD_LOGIC_VECTOR(WIDTH-1 downto 0)
	);
END mux2to1;

ARCHITECTURE Behavior OF mux2to1 IS
BEGIN
	mux_out <= d0 when s = '0' else d1;
		
END Behavior;
