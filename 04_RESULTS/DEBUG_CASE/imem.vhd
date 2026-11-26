----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 17:28:51
-- Design Name: 
-- Module Name: imem - Behavioral
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

entity imem is
    port (
        PC    : in  STD_LOGIC_VECTOR(31 downto 0);
        Instr : out STD_LOGIC_VECTOR(31 downto 0)
    );
end imem;

architecture Behavioral of imem is

    type ROM_type is array (0 to 31)
        of STD_LOGIC_VECTOR(31 downto 0);

    constant ROM : ROM_type := (
        0  => "11101010000000000000000000000001",
        1  => "11100010100000000001000000010001",
        2  => "11100010100000000010000000100010",
        3  => "11101010111111111111111111111100",
        others => (others => '0')
    );

begin

    Instr <= ROM(to_integer(unsigned(PC(6 downto 2))));

end Behavioral;

