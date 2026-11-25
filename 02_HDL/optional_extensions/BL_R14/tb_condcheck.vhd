----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 01:51:14
-- Design Name: 
-- Module Name: tb_condcheck - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_condcheck is
end tb_condcheck;

architecture Behavioral of tb_condcheck is

    signal Cond   : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal Flags  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal CondEx : STD_LOGIC;

begin

    uut : entity work.condcheck
        port map (
            Cond   => Cond,
            Flags  => Flags,
            CondEx => CondEx
        );

    process
    begin

        -- Test 1 : EQ avec Z = 1
        Cond <= "0000";
        Flags <= "0100";
        wait for 10 ns;
        assert CondEx = '1'
            report "Erreur EQ" severity error;

        -- Test 2 : NE avec Z = 1
        Cond <= "0001";
        wait for 10 ns;
        assert CondEx = '0'
            report "Erreur NE" severity error;

        -- Test 3 : HI avec C = 1, Z = 0
        Cond <= "1000";
        Flags <= "0010";
        wait for 10 ns;
        assert CondEx = '1'
            report "Erreur HI" severity error;

        -- Test 4 : LT avec N = 1, V = 0
        Cond <= "1011";
        Flags <= "1000";
        wait for 10 ns;
        assert CondEx = '1'
            report "Erreur LT" severity error;

        -- Test 5 : GE avec N = V = 1
        Cond <= "1010";
        Flags <= "1001";
        wait for 10 ns;
        assert CondEx = '1'
            report "Erreur GE" severity error;

        -- Test 6 : GT avec Z = 1
        Cond <= "1100";
        Flags <= "0100";
        wait for 10 ns;
        assert CondEx = '0'
            report "Erreur GT" severity error;

        -- Test 7 : AL toujours vraie
        Cond <= "1110";
        Flags <= "0000";
        wait for 10 ns;
        assert CondEx = '1'
            report "Erreur AL" severity error;

        -- Test 8 : Code non pris en charge
        Cond <= "1111";
        wait for 10 ns;
        assert CondEx = '0'
            report "Erreur code 1111" severity error;

        report "Tests condcheck termines"
            severity note;

        wait;
    end process;

end Behavioral;
