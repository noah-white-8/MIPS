-- Noah White
-- Section #: 11088

-- Del3 version
-- NOTE: Prob going to need to change/add stuff as you add more functionality and whatnot

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	generic (WIDTH : positive := 32);
	port (
		inputA		    : in std_logic_vector(WIDTH-1 downto 0);
		inputB		    : in std_logic_vector(WIDTH-1 downto 0);
		OpSel		    : in std_logic_vector(7 downto 0);          -- CHANGE WIDTH LATER (MAYBE)
        shift           : in std_logic_vector(4 downto 0);
        branch_taken    : out std_logic;
		result		    : out std_logic_vector(WIDTH-1 downto 0);
        result_hi       : out std_logic_vector(WIDTH-1 downto 0)
		);
end alu;

-- COMBINATIONAL GUIDELINE #1: Design circuit, then write the code
-- COMBINATIONAL GUIDELINE #2: Define all outputs on all paths
-- Are we supposed to implement overflow? I don't think so
-- The use of the signal earlier didn't work because signals don't get updated till the end of a process

architecture behavioral of alu is

    
begin
    process(inputA, inputB, OpSel, shift)
		variable temp : unsigned(2*WIDTH-1 downto 0);
        variable temp0 : signed(2*WIDTH-1 downto 0);
    begin
        branch_taken <= '0';
        result <= (others => '0');
        result_hi <= (others => '0');

        case OpSel is
            when X"21" =>                           -- A + B
                result <= std_logic_vector(unsigned(inputA) + unsigned(inputB));
            when X"23" =>                           -- A - B
                result <= std_logic_vector(unsigned(inputA) - unsigned(inputB));
            when X"18" =>                           -- Signed multiplication
                temp0 := signed(inputA) * signed(inputB);
                result <= std_logic_vector(temp0(WIDTH-1 downto 0));
                result_hi <= std_logic_vector(temp0(2*WIDTH-1 downto WIDTH));
            when X"19" =>                           -- Unsigned multiplication
                temp := unsigned(inputA) * unsigned(inputB);
                result <= std_logic_vector(temp(WIDTH-1 downto 0));
                result_hi <= std_logic_vector(temp(2*WIDTH-1 downto WIDTH));
            when X"24" =>                           -- A AND B
                result <= inputA and inputB;
            when X"25" =>                           -- A OR B
                result <= inputA or inputB;
            when X"26" =>                           -- A XOR B
                result <= inputA xor inputB;
            when X"00" =>                           -- shift left logical
                result <= std_logic_vector(shift_left(unsigned(inputB), to_integer(unsigned(shift))));
            when X"02" =>                           -- shift right logical
                result <= std_logic_vector(shift_right(unsigned(inputB), to_integer(unsigned(shift))));
            when X"03" =>                           -- arithmetic shift right
                result <= std_logic_vector(shift_right(signed(inputB), to_integer(unsigned(shift))));
            when X"2A" =>                           -- slt, etc. (Set on less than signed operations)
                if (signed(inputA) < signed(inputB)) then
                    result <= X"00000001";
                else
                    result <= (others => '0');
                end if;
            when X"2B" =>                           -- sltu: set on less than unsigned
                if (unsigned(inputA) < unsigned(inputB)) then
                    result <= X"00000001";
                else
                    result <= (others => '0');
                end if;
            when X"06" =>                           -- blez (branch if less than or equal to zero)
                if (signed(inputA) <= 0) then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;
            when X"07" =>                           -- bgtz (branch if greater than zero)
				if (signed(inputA) > 0) then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;
            when X"08" =>                           -- Pass through inputA to output (for jump register & JAL instructions)
                result <= inputA;
            when others =>
                branch_taken <= '0';
                result <= (others => '0');
                result_hi <= (others => '0');
        end case;
        
    end process;
end behavioral;
