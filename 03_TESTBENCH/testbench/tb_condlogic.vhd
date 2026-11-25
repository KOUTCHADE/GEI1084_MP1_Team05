----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 04:05:45
-- Design Name: 
-- Module Name: tb_condlogic - Behavioral
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

entity tb_condlogic is
end tb_condlogic;

architecture Behavioral of tb_condlogic is

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal Cond     : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    signal ALUFlags : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal FlagW    : STD_LOGIC_VECTOR(1 downto 0) := "00";

    signal RegW     : STD_LOGIC := '0';
    signal MemW     : STD_LOGIC := '0';
    signal PCS      : STD_LOGIC := '0';

    signal RegWrite : STD_LOGIC;
    signal MemWrite : STD_LOGIC;
    signal PCSrc    : STD_LOGIC;

begin

    uut : entity work.condlogic
        port map (
            clk      => clk,
            reset    => reset,
            Cond     => Cond,
            ALUFlags => ALUFlags,
            FlagW    => FlagW,
            RegW     => RegW,
            MemW     => MemW,
            PCS      => PCS,
            RegWrite => RegWrite,
            MemWrite => MemWrite,
            PCSrc    => PCSrc
        );

    clk <= not clk after 5 ns;

    process
    begin
        -- Test 1 : Reset
        reset <= '1';
        wait for 12 ns;
        reset <= '0';

        -- Test 2 : AL, ecritures autorisees
        Cond <= "1110";
        RegW <= '1';
        MemW <= '1';
        PCS <= '1';
        wait for 10 ns;

        assert RegWrite = '1' and
               MemWrite = '1' and
               PCSrc = '1'
            report "Erreur AL" severity error;

        -- Test 3 : EQ avec Z = 0
        Cond <= "0000";
        wait for 10 ns;

        assert RegWrite = '0' and
               MemWrite = '0' and
               PCSrc = '0'
            report "Erreur EQ" severity error;

        -- Test 4 : Sauvegarder Z = 1
        Cond <= "1110";
        ALUFlags <= "0100";
        FlagW <= "11";
        wait for 10 ns;

        -- Test 5 : EQ avec Z = 1
        FlagW <= "00";
        Cond <= "0000";
        wait for 10 ns;

        assert RegWrite = '1' and
               MemWrite = '1' and
               PCSrc = '1'
            report "Erreur EQ avec Z=1"
            severity error;

        -- Test 6 : LT avec N = 1, V = 0
        Cond <= "1110";
        ALUFlags <= "1000";
        FlagW <= "11";
        wait for 10 ns;

        FlagW <= "00";
        Cond <= "1011";
        wait for 10 ns;

        assert RegWrite = '1' and
               MemWrite = '1' and
               PCSrc = '1'
            report "Erreur LT" severity error;

        -- Test 7 : LT avec N = V
        Cond <= "1110";
        ALUFlags <= "0000";
        FlagW <= "11";
        wait for 10 ns;

        FlagW <= "00";
        Cond <= "1011";
        wait for 10 ns;

        assert RegWrite = '0' and
               MemWrite = '0' and
               PCSrc = '0'
            report "Erreur LT non satisfaite"
            severity error;

        report "Simulation condlogic terminee"
            severity note;

        wait;
    end process;

end Behavioral;
