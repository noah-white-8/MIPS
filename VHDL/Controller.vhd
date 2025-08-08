-- Created by Noah White
-- Last Edit: Noah White on 8/6/25
--
-- Description: 
--      Controller for the MIPS.
-- 
-- Methodology (from Stitt):
--      Design the circuit, then write the code.
--
-- NEXT STEPS (Updated 8/6/25):
--      - In top_level.vhd file

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controller is
    port (
        clk                     : in std_logic;
        rst                     : in std_logic;
        IR31to26                : in std_logic_vector(5 downto 0); -- The OP Code I believe
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
        ALUOp                   : out std_logic_vector(2 downto 0); -- May need to change width later
        PCSource                : out std_logic_vector(1 downto 0)
    );
end entity Controller;



-- Here in lies the architecture. Oh how beautiful with her gothic walls and gargoyles
architecture behavioral of Controller is
    type state_t is (START, INST_FETCH1, INST_FETCH2);              -- Each STATE reps one CYCLE imma say
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
        IsSigned    <= '0';
        ALUSrcA     <= '0';
        ALUSrcB     <= "00";
        ALUOp       <= "000";
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
                ALUOp       <= "000"; -- May need to change later (just needs to correspond to an ADD)
                PCSource    <= "00";
                PCWrite     <= '1';
                next_state  <= START; -- IMPORTANT: NEED to change later 100%. Just leave for now.

            when others => null;
        end case;

    end process;

    
end architecture behavioral;
