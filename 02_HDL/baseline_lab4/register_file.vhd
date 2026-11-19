----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2026 15:50:31
-- Design Name: 
-- Module Name: register_file - Behavioral
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


entity register_file is
    Port ( CLK : in STD_LOGIC;
           RegWrite : in STD_LOGIC;
           RA1 : in STD_LOGIC_VECTOR (3 downto 0);
           RA2 : in STD_LOGIC_VECTOR (3 downto 0);
           A3 : in STD_LOGIC_VECTOR (3 downto 0);
           WD3 : in STD_LOGIC_VECTOR (31 downto 0);
           R15 : in STD_LOGIC_VECTOR (31 downto 0);
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0));
end register_file;

architecture Behavioral of register_file is
type ram_type is array (0 to 15)
        of STD_LOGIC_VECTOR(31 downto 0);

    signal RAM : ram_type := (others => (others => '0'));
    
begin
   -- Lectures asynchrones
    RD1 <= RAM(to_integer(unsigned(RA1)));
    RD2 <= RAM(to_integer(unsigned(RA2)));
    
     -- Exercice 1b : écriture synchrone
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RegWrite = '1' then
                RAM(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if;
    end process;


end Behavioral;
