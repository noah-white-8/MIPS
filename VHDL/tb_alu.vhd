-- Noah White
-- Section #: 11088

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu is
end tb_alu;

architecture TB of tb_alu is

    component alu
        generic (
            WIDTH : positive := 32
            );
        port (
            inputA		    : in std_logic_vector(WIDTH-1 downto 0);
            inputB		    : in std_logic_vector(WIDTH-1 downto 0);
            OpSel		    : in std_logic_vector(7 downto 0);
            shift           : in std_logic_vector(4 downto 0);
            branch_taken    : out std_logic;
            result		    : out std_logic_vector(WIDTH-1 downto 0);
            result_hi       : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    constant WIDTH      : positive                           := 32;
    signal inputA       : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal inputB       : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal OpSel        : std_logic_vector(7 downto 0)       := (others => '0');
    signal shift        : std_logic_vector(4 downto 0)       := (others => '0');
    signal branch_taken : std_logic                          := '0';
    signal result       : std_logic_vector(WIDTH-1 downto 0);
    signal result_hi    : std_logic_vector(WIDTH-1 downto 0) := (others => '0');

begin  -- TB

    UUT : alu
        generic map (WIDTH => WIDTH)
        port map (
            inputA          => inputA,
            inputB          => inputB,
            OpSel           => OpSel,
            shift           => shift,
            branch_taken    => branch_taken,
            result          => result,
            result_hi       => result_hi
        );

    process
    begin

        -- ADDITION TEST
        OpSel    <= X"21";
        inputA <= std_logic_vector(to_unsigned(10, inputA'length));
        inputB <= std_logic_vector(to_unsigned(15, inputB'length));
        wait for 40 ns;
        assert(result = std_logic_vector(to_unsigned(25, result'length))) report "Error : 10+15 = " & integer'image(to_integer(unsigned(result))) & " instead of 25" severity warning;

        -- SUBTRACTION TEST
        OpSel    <= X"23";
        inputA <= std_logic_vector(to_unsigned(25, inputA'length));
        inputB <= std_logic_vector(to_unsigned(10, inputB'length));
        wait for 40 ns;
        assert(result = std_logic_vector(to_unsigned(15, result'length))) report "Error : 25-10 = " & integer'image(to_integer(unsigned(result))) & " instead of 15" severity warning;

        -- SIGNED MULTIPLICATION TEST
        OpSel    <= X"18";
        inputA <= std_logic_vector(to_signed(10, inputA'length));
        inputB <= std_logic_vector(to_signed(-4, inputB'length));
        wait for 40 ns;
        assert(result = std_logic_vector(to_signed(-40, result'length))) report "Error : 10*(-4) = " & integer'image(to_integer(signed(result))) & " instead of -40" severity warning;

        -- UNSIGNED MULTIPLICATION TEST (8589934592)
        OpSel    <= X"19";
        inputA <= std_logic_vector(to_unsigned(65536, inputA'length));
        inputB <= std_logic_vector(to_unsigned(131072, inputB'length));
        wait for 40 ns;
--        assert(result = std_logic_vector(to_unsigned(4294967295, result'length))) report "Error : 10*(-4) = " & integer'image(to_integer(signed(result))) & " instead of -40" severity warning;
--        assert(result_hi = std_logic_vector(to_unsigned(4294967295, result'length))) report "Error : 10*(-4) = " & integer'image(to_integer(signed(result))) & " instead of -40" severity warning;

        -- AND TEST
        OpSel  <= X"24";
        inputA <= X"0000FFFF";
        inputB <= X"FFFF1234";
        wait for 40 ns;

        -- SHIFT RIGHT LOGICAL TEST
        OpSel  <= X"02";
        inputB <= X"0000000F";
        shift  <= "00100";
        wait for 40 ns;
        -- Assert statement potentially

        -- SHIFT RIGHT ARITHMETIC TEST #1
        OpSel  <= X"03";
        inputB <= X"F0000008";
        shift  <= "00001";
        wait for 40 ns;
        -- Assert statement potentially

        -- SHIFT RIGHT ARITHMETIC TEST #2
        OpSel  <= X"03";
        inputB <= X"00000008";
        shift  <= "00001";
        wait for 40 ns;
        -- Assert statement potentially

        -- COMPARE: IS A LESS THAN B TEST #1
        OpSel   <= X"2A";
        inputA  <= std_logic_vector(to_unsigned(10, inputA'length));
        inputB  <= std_logic_vector(to_unsigned(15, inputB'length));
        wait for 40 ns;
        -- Assert statement potentially

        -- COMPARE: IS A LESS THAN B TEST #2
        OpSel   <= X"2A";
        inputA  <= std_logic_vector(to_unsigned(15, inputA'length));
        inputB  <= std_logic_vector(to_unsigned(10, inputB'length));
        wait for 40 ns;
        -- Assert statement potentially

        -- BRANCH: BLEZ TEST
        OpSel   <= X"06";
        inputA  <= std_logic_vector(to_unsigned(5, inputA'length));
        wait for 40 ns;

        -- BRANCH: BGTZ TEST
        OpSel   <= X"07";
        inputA  <= std_logic_vector(to_unsigned(5, inputA'length));
        wait for 40 ns;




        -- OLD TESTS (from Lab 3) BELOW

        -- -- test 2+6 (no overflow)
        -- OpSel    <= "0101";
        -- inputA <= conv_std_logic_vector(2, inputA'length);
        -- inputB <= conv_std_logic_vector(6, inputB'length);
        -- wait for 40 ns;
        -- assert(result = conv_std_logic_vector(8, result'length)) report "Error : 2+6 = " & integer'image(conv_integer(result)) & " instead of 8" severity warning;
        -- assert(overflow = '0') report "Error                                   : overflow incorrect for 2+8" severity warning;

        -- -- test 250+50 (with overflow)
        -- OpSel    <= "0101";
        -- inputA <= conv_std_logic_vector(250, inputA'length);
        -- inputB <= conv_std_logic_vector(50, inputB'length);
        -- wait for 40 ns;
        -- assert(result = conv_std_logic_vector(300, result'length)) report "Error : 250+50 = " & integer'image(conv_integer(result)) & " instead of 44" severity warning;
        -- assert(overflow = '1') report "Error                                     : overflow incorrect for 250+50" severity warning;

        -- -- test 5*6
        -- OpSel    <= "0111";
        -- inputA <= conv_std_logic_vector(5, inputA'length);
        -- inputB <= conv_std_logic_vector(6, inputB'length);
        -- wait for 40 ns;
        -- assert(result = conv_std_logic_vector(30, result'length)) report "Error : 5*6 = " & integer'image(conv_integer(result)) & " instead of 30" severity warning;
        -- assert(overflow = '0') report "Error                                    : overflow incorrect for 5*6" severity warning;  

        -- -- test 50*60
        -- OpSel    <= "0111";
        -- inputA <= conv_std_logic_vector(64, inputA'length);
        -- inputB <= conv_std_logic_vector(64, inputB'length);
        -- wait for 40 ns;
        -- assert(result = conv_std_logic_vector(4096, result'length)) report "Error : 64*64 = " & integer'image(conv_integer(result)) & " instead of 0" severity warning;
        -- -- assert(overflow = '1') report "Error                                      : overflow incorrect for 64*64" severity warning;

        -- add many more tests
		report "Simulation finished";
        wait;

    end process;


end TB;
