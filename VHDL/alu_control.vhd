-- Noah White
-- Notes: Get Chat to make you a mif file to test all these instructions you've already done

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
        OpSel       <= (others => '1');
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

                    when "100100" =>                                -- AND
                        OpSel       <= X"24";                       -- 0x24 is 100100

                    when "100101" =>                                -- OR
                        OpSel       <= X"25";                       -- 0x25 is 100101

                    when "100110" =>                                -- XOR
                        OpSel       <= X"26";                       -- 0x26 is 100110

                    when "000010" =>                                -- Shift Right Logical
                        OpSel       <= X"02";                       

                    when "000000" =>                                -- Shift Left Logical
                        OpSel       <= X"00";
                    
                    when "000011" =>                                -- Shift Right Arithmetic
                        OpSel       <= X"03";

                    when "101010" =>                                -- Set on less than signed
                        OpSel       <= X"2A";
                    when "101011" =>                                -- Set on less than unsigned
                        OpSel       <= X"2B";
                    when "011000" =>                                -- Multiplication signed
                        OpSel       <= X"18";
                        HI_en       <= '1';
                        LO_en       <= '1';
                    when "011001" =>                                -- Multiplication unsigned
                        OpSel       <= X"19";
                        HI_en       <= '1';
                        LO_en       <= '1';
                    when "010000" =>                                -- Move from HI register (need to delay 1 cycle)
                        ALU_LO_HI   <= "10";
                    when "010010" =>                                -- Move from LO register (need to delay 1 cycle)
                        ALU_LO_HI   <= "01";
                    

                    when others => null;
                end case;

            when "001111" =>                                        -- ADD 4 to PC (and for ADDIU)
                OpSel   <= X"21";                                   -- For ALU ADD
        
            when others => null;
        end case;

            
        
    end process;
    
end behavioral;
