-- Noah White
-- Section #: 11088

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_control is
    port (
        IR_5to0             : in std_logic_vector(5 downto 0);
        ALUOp               : in std_logic_vector(2 downto 0);                     -- Might be a vector and change later
        OpSel               : out std_logic_vector(7 downto 0);
        HI_en               : out std_logic;
        LO_en               : out std_logic;
        ALU_LO_HI           : out std_logic_vector(1 downto 0)
    );
end alu_control;


architecture behavioral of alu_control is
    
begin
    -- The below for now
    HI_en       <= '0';
    LO_en       <= '0';
    ALU_LO_HI   <= "00";

    -- For ADD for now (0x21 is ADD in alu.vhd)
    OpSel       <= X"21";
    
    
end behavioral;
