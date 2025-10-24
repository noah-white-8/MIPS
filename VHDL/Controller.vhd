-- Created by Noah White
--
-- Description: 
--      Controller for the MIPS.
-- 
-- Methodology (from Stitt):
--      Design the circuit, then write the code.
--
-- Notes:
--      - R-type is the only type with the same OPCode for all INSTS. I-type has diff OPCode for diff instructions
--
-- NEXT STEPS (Updated 8/15/25):
--      - In top_level.vhd file
--      - Add a instruction decode cycle for the controller (don't know that you really need this as you'll just decode IR31to26 later)
--      - - Might could use a INSTRUCTION TYPE class like is it R_type, etc.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controller is
    port (
        clk                     : in std_logic;
        rst                     : in std_logic;
        IR31to26                : in std_logic_vector(5 downto 0); -- The OP Code I believe
        IR5to0                  : in std_logic_vector(5 downto 0); -- For MFHI & MFLO
        PCWriteCond             : out std_logic;
        PCWrite                 : out std_logic;
        IorD                    : out std_logic;
        MemRead                 : out std_logic;
        MemWrite                : out std_logic;
        MemToReg                : out std_logic;
        IRWrite                 : out std_logic;
        RegDst                  : out std_logic;
        RegWrite                : out std_logic;
        JumpAndLink             : out std_logic;
        IsSigned                : out std_logic;
        ALUSrcA                 : out std_logic;
        ALUSrcB                 : out std_logic_vector(1 downto 0);
        ALUOp                   : out std_logic_vector(5 downto 0); -- OP Code
        PCSource                : out std_logic_vector(1 downto 0)
    );
end entity Controller;



-- Here in lies the architecture. Oh how beautiful with her gothic walls and gargoyles
architecture behavioral of Controller is
    type state_t is (START, INST_FETCH1, INST_FETCH2, REG_FETCH, INST_DECODE, R_TYPE, I_TYPE);      -- Each STATE reps one CYCLE imma say
    signal state_r, next_state : state_t;
    
begin
    -- Sequential Logic Process and async (I believe) reset
    process(clk, rst)
    begin
        if (rst = '1') then
            state_r <= START;
        elsif (rising_edge(clk)) then
            state_r <= next_state;
        end if;
    end process;

    -- Combinational Logic Process
    process(IR31to26, state_r)
    begin
        -- DEFAULT VALS HERE
        PCWriteCond <= '0';
        PCWrite     <= '0';
        IorD        <= '0';
        MemRead     <= '0';
        MemWrite    <= '0';
        MemToReg    <= '0';
        IRWrite     <= '0';
        RegDst      <= '0';
        RegWrite    <= '0';
        JumpAndLink <= '0';
        IsSigned    <= '1';
        ALUSrcA     <= '0';
        ALUSrcB     <= "00";
        ALUOp       <= (others => '1');    -- OP Code (could use others => '1' as a default but I think IR31to26 is a better default)
        PCSource    <= "00";

        next_state <= state_r;

        -- IMPORTANT: Only testing INSTRUCTION FETCH right now
        case (state_r) is
            when START =>
                next_state  <= INST_FETCH1; -- Maybe change/add stuff in this section later

            when INST_FETCH1 =>
                IorD        <= '0';
                MemRead     <= '1';
                next_state  <= INST_FETCH2;

            when INST_FETCH2 =>
                IRWrite     <= '1';

                -- The following is to do: PC = PC + 4 (because mem is in words of 4 bytes)
                ALUSrcA     <= '0';
                ALUSrcB     <= "01";
                ALUOp       <= "001111"; 
                PCSource    <= "00";
                PCWrite     <= '1';
                next_state  <= REG_FETCH; 

            -- When REG_FETCH, do nothing b/c Reg fetch happens automatically and INST_DECODE will happen later, just set next state
            when REG_FETCH =>
                next_state  <= INST_DECODE;

            -- In INST_DECODE, you're setting the type of INST (r-type, etc) based on OPCode (IR31to26) and setting signals for 1st cycle of that INST
            when INST_DECODE =>
                case (IR31to26) is 
                    when "000000" =>             -- R-type
                        ALUOp       <= IR31to26; -- 00 for R-type (could change, could use a type state class or not)
                        ALUSrcA     <= '1';             
                        ALUSrcB     <= "00";            
                        next_state  <= R_TYPE;

                    -- I-TYPE INSTRUCTIONS START HERE
                    when "001001" =>             -- 0x09 for ADDIU (IsSigned default is '1')
                        ALUOp       <= "001111"; -- 0x0F tells ALU_Control to do an ADD (just like PC+4)
                        ALUSrcA     <= '1';
                        ALUSrcB     <= "10";
                        next_state  <= I_TYPE;

                    when "001100" =>             -- 0x0C for ANDI (change IsSigned to '0' to zero extend)
                        ALUOp       <= "001100"; -- 0x0C tells ALU_Control to do an AND
                        IsSigned    <= '0';
                        ALUSrcA     <= '1';
                        ALUSrcB     <= "10";
                        next_state  <= I_TYPE;

                    when "001101" =>             -- 0x0D for ORI (IsSigned = '0')
                        ALUOp       <= "001101";
                        IsSigned    <= '0';
                        ALUSrcA     <= '1';
                        ALUSrcB     <= "10";
                        next_state  <= I_TYPE;

                    when "001110" =>             -- Ox0E for XORI (IsSigned = '0')
                        ALUOp       <= "001110";
                        IsSigned    <= '0';
                        ALUSrcA     <= '1';
                        ALUSrcB     <= "10";
                        next_state  <= I_TYPE;

                    when "001010" =>             -- 0x0A for SLTI
                        ALUOp       <= "001010";
                        ALUSrcA     <= '1';
                        ALUSrcB     <= "10";
                        next_state  <= I_TYPE;

                    when "001011" =>             -- 0x0B for SLTIU
                        ALUOp       <= "001011";
                        IsSigned    <= '0';
                        ALUSrcA     <= '1';
                        ALUSrcB     <= "10";
                        next_state  <= I_TYPE;
                    -- I-TYPE INSTRUCTIONS END HERE
                    
                    when others => null;
                end case;

            -- Writes result to appropriate address in the RegFile. Also alu_control doin stuff here
            when R_TYPE =>
                MemToReg    <= '0';
                RegDst      <= '1';
                RegWrite    <= '1';
                next_state  <= START;

                -- The following case block is for MFHI & MFLO instructions
                case (IR5to0) is
                    when "010000" =>                    -- MFHI
                        ALUOp   <= (others => '0');
                    when "010010" =>                    -- MFLO
                        ALUOp   <= (others => '0');
                    when others => null;
                end case;

            when I_TYPE =>
                MemToReg    <= '0';
                RegDst      <= '0';
                RegWrite    <= '1';
                next_state  <= START;

            when others => null;
        end case;

    end process;

    
end architecture behavioral;
