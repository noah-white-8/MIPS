-- Noah White

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_control is
    port (
        IR_5to0             : in std_logic_vector(5 downto 0);
        ALUOp               : in std_logic_vector(5 downto 0);      -- OP Code, might change later
        OpSel               : out std_logic_vector(7 downto 0);
        HI_en               : out std_logic;
        LO_en               : out std_logic;
        ALU_LO_HI           : out std_logic_vector(1 downto 0)
    );
end alu_control;



architecture behavioral of alu_control is
    
begin
    process(IR_5to0, ALUOp)
    begin
        -- DEFAULT VALS HERE
        OpSel       <= (others => '0');
        HI_en       <= '0';
        LO_en       <= '0';
        ALU_LO_HI   <= "00";
        
        -- Cases for type of instruction and specific instruction
        case (ALUOp) is
            when "000000" =>                                        -- R-type
                case (IR_5to0) is
                    when "100001" =>                                -- ADD Unsigned
                        OpSel       <= X"21";                       -- 0x21 is same as 100001

                    when "100011" =>                                -- SUB Unsigned
                        OpSel       <= X"23";                       -- 0x23 is same as 100011

                    when others => null;
                end case;

            when "001111" =>                                        -- ADD 4 to PC
                OpSel   <= X"21";                                   -- For ALU ADD
        
            when others => null;
        end case;

            
        
    end process;
    
end behavioral;
