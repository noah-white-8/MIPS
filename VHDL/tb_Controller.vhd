-- tb_Controller.vhd
-- Testbench for Controller FSM
-- Created 8/17/25

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Controller is
end tb_Controller;

architecture tb of tb_Controller is
    -- DUT inputs
    signal clk        : std_logic := '0';
    signal rst        : std_logic;
    signal IR31to26   : std_logic_vector(5 downto 0);

    -- DUT outputs
    signal PCWriteCond : std_logic;
    signal PCWrite     : std_logic;
    signal IorD        : std_logic;
    signal MemRead     : std_logic;
    signal MemWrite    : std_logic;
    signal MemToReg    : std_logic;
    signal IRWrite     : std_logic;
    signal RegDst      : std_logic;
    signal RegWrite    : std_logic;
    signal JumpAndLink : std_logic;
    signal IsSigned    : std_logic;
    signal ALUSrcA     : std_logic;
    signal ALUSrcB     : std_logic_vector(1 downto 0);
    signal ALUOp       : std_logic_vector(5 downto 0);
    signal PCSource    : std_logic_vector(1 downto 0);

    constant clk_period : time := 10 ns;

begin
    -- Instantiate DUT
    DUT: entity work.Controller
        port map (
            clk         => clk,
            rst         => rst,
            IR31to26    => IR31to26,
            PCWriteCond => PCWriteCond,
            PCWrite     => PCWrite,
            IorD        => IorD,
            MemRead     => MemRead,
            MemWrite    => MemWrite,
            MemToReg    => MemToReg,
            IRWrite     => IRWrite,
            RegDst      => RegDst,
            RegWrite    => RegWrite,
            JumpAndLink => JumpAndLink,
            IsSigned    => IsSigned,
            ALUSrcA     => ALUSrcA,
            ALUSrcB     => ALUSrcB,
            ALUOp       => ALUOp,
            PCSource    => PCSource
        );

    -- Clock generator
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Reset controller
        rst <= '1';
        IR31to26 <= (others => '0');
        wait for 2*clk_period;
        rst <= '0';
        wait for clk_period;

        -- Apply R-type instruction (opcode=000000)
        IR31to26 <= "000000";
        wait for 10*clk_period;  

        -- Apply some other instruction later (fill in once you add support)
        IR31to26 <= "000001";
        wait for 10*clk_period;

        -- Stop simulation
        wait;
    end process;
end tb;

