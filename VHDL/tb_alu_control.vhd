-- tb_alu_control.vhd
-- Testbench for alu_control entity
-- Created on 8/17/25

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu_control is
end tb_alu_control;

architecture tb of tb_alu_control is
    -- DUT inputs
    signal IR_5to0   : std_logic_vector(5 downto 0);
    signal ALUOp     : std_logic_vector(5 downto 0);

    -- DUT outputs
    signal OpSel     : std_logic_vector(7 downto 0);
    signal HI_en     : std_logic;
    signal LO_en     : std_logic;
    signal ALU_LO_HI : std_logic_vector(1 downto 0);

begin
    -- Instantiate DUT
    DUT: entity work.alu_control
        port map (
            IR_5to0     => IR_5to0,
            ALUOp       => ALUOp,
            OpSel       => OpSel,
            HI_en       => HI_en,
            LO_en       => LO_en,
            ALU_LO_HI   => ALU_LO_HI
        );

    -- Stimulus process
    process
    begin
        -- Test ADDU (R-type funct=100001)
        ALUOp   <= "000000";  -- R-type
        IR_5to0 <= "100001";
        wait for 10 ns;
        assert (OpSel = X"21") report "ADDU failed: expected 0x21" severity error;

        -- Log message if successful (this works, lol)
        if (OpSel = X"21") then
            report "ADDU passed: OpSel is 0x21" severity note;
        end if;

        -- Test SUBU (R-type funct=100011)
        ALUOp   <= "000000";
        IR_5to0 <= "100011";
        wait for 10 ns;
        assert (OpSel = X"23") report "SUBU failed: expected 0x23" severity error;

        -- Test PC+4 (ALUOp=001111)
        ALUOp   <= "001111";
        IR_5to0 <= (others => '0'); -- funct irrelevant
        wait for 10 ns;
        assert (OpSel = X"21") report "PC+4 failed: expected 0x21" severity error;

        -- Add more test cases as you add instructions!
        wait;
    end process;
end tb;

