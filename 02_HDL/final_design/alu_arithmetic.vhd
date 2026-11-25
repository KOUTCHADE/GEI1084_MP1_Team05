----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2026 18:59:31
-- Design Name: 
-- Module Name: alu_arithmetic - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
entity alu_arithmetic is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           Sub : in STD_LOGIC;
           Sum : out STD_LOGIC_VECTOR (31 downto 0);
           Cout : out STD_LOGIC);
end alu_arithmetic;

architecture synth of alu_arithmetic is
begin

    process(A, B, Sub)
        variable temp : UNSIGNED(32 downto 0);
    begin

        if Sub = '0' then

            -- Addition : A + B
            temp := ('0' & UNSIGNED(A))
                  + ('0' & UNSIGNED(B));
        else
            -- Soustraction : A + NOT(B) + 1
            temp := ('0' & UNSIGNED(A))
                  + ('0' & UNSIGNED(not B))
                  + 1;

        end if;

        Sum  <= STD_LOGIC_VECTOR(temp(31 downto 0));
        Cout <= temp(32);

    end process;

end synth;


