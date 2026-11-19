----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 01:10:17
-- Design Name: 
-- Module Name: tb_flag_registers - Behavioral
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

entity tb_flag_registers is
end tb_flag_registers;

architecture Behavioral of tb_flag_registers is

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal ALUFlags : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal FlagW    : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal CondEx   : STD_LOGIC := '0';
    signal Flags    : STD_LOGIC_VECTOR(3 downto 0);

begin

    uut : entity work.flag_registers
        port map (
            clk      => clk,
            reset    => reset,
            ALUFlags => ALUFlags,
            FlagW    => FlagW,
            CondEx   => CondEx,
            Flags    => Flags
        );

    -- Horloge de periode 10 ns
    clk <= not clk after 5 ns;

    process
    begin
        -- Test 1 : Reset asynchrone
        reset <= '1';
        wait for 12 ns;
        assert Flags = "0000"
            report "Erreur reset" severity error;

        reset <= '0';

        -- Test 2 : Mise a jour NZCV
        ALUFlags <= "1011";
        FlagW <= "11";
        CondEx <= '1';
        wait for 10 ns;
        assert Flags = "1011"
            report "Erreur NZCV" severity error;

        -- Test 3 : Mise a jour NZ seulement
        ALUFlags <= "0100";
        FlagW <= "10";
        wait for 10 ns;
        assert Flags = "0111"
            report "Erreur NZ" severity error;

        -- Test 4 : Condition non satisfaite
        ALUFlags <= "0000";
        FlagW <= "11";
        CondEx <= '0';
        wait for 10 ns;
        assert Flags = "0111"
            report "Erreur CondEx" severity error;

        -- Test 5 : Aucune ecriture autorisee
        ALUFlags <= "1111";
        FlagW <= "00";
        CondEx <= '1';
        wait for 10 ns;
        assert Flags = "0111"
            report "Erreur enable" severity error;

        report "Tous les tests sont termines"
            severity note;

        wait;
    end process;

end Behavioral;
