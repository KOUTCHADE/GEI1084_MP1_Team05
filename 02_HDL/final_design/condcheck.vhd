----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 01:48:24
-- Design Name: 
-- Module Name: condcheck - Behavioral
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

entity condcheck is
    port (
        Cond   : in  STD_LOGIC_VECTOR(3 downto 0);
        Flags  : in  STD_LOGIC_VECTOR(3 downto 0);
        CondEx : out STD_LOGIC
    );
end condcheck;

architecture Behavioral of condcheck is

    signal N, Z, C, V : STD_LOGIC;

begin

    -- Extraction des quatre flags
    N <= Flags(3);
    Z <= Flags(2);
    C <= Flags(1);
    V <= Flags(0);

    process(Cond, N, Z, C, V)
    begin
        case Cond is

            when "0000" => -- EQ
                CondEx <= Z;

            when "0001" => -- NE
                CondEx <= not Z;

            when "0010" => -- CS / HS
                CondEx <= C;

            when "0011" => -- CC / LO
                CondEx <= not C;

            when "0100" => -- MI
                CondEx <= N;

            when "0101" => -- PL
                CondEx <= not N;

            when "0110" => -- VS
                CondEx <= V;

            when "0111" => -- VC
                CondEx <= not V;

            when "1000" => -- HI
                CondEx <= C and (not Z);

            when "1001" => -- LS
                CondEx <= (not C) or Z;

            when "1010" => -- GE
                CondEx <= not (N xor V);

            when "1011" =>  -- LT 
                CondEx <= N xor V;

            when "1100" => -- GT
                CondEx <= (not Z) and (not (N xor V));

            when "1101" => -- LE
                CondEx <= Z or (N xor V);

            when "1110" => -- AL
                CondEx <= '1';

            when others =>
                CondEx <= '0';

        end case;
    end process;

end Behavioral;
