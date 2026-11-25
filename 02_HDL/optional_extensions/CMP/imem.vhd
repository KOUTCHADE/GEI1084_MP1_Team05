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
        0  => "11100000010000000000000000000000",
        1  => "11100010100000000010000000000101",
        2  => "11100010100000000011000000001100",
        3  => "11100010010000110111000000001001",
        4  => "11100001100001110100000000000010",
        5  => "11100000000000110101000000000100",
        6  => "11100000100001010101000000000100",
        7  => "11100000010101011000000000000111",
        8  => "11100000010100111000000000000100",
        9  => "11100010100000000101000000000000",
        10 => "11100000010101111000000000000010",
        11 => "10110010100001010111000000000001",
        12 => "11100000010001110111000000000010",
        13 => "11100101100000110111000001010100",
        14 => "11100101100100000010000001100000",
        15 => "11100000100010000101000000000000",
        16 => "11100010100000000010000000001110",
        17 => "11100010100000000010000000001101",
        18 => "11100010100000000010000000001010",
        19 => "11100101100000000010000001100100",        
        20 => "11100001010100100000000000000010",

        -- Test C2 : soustraction positive
        21 => x"E2421001",  -- SUB R1, R2, #1  (R1 = 9)
        22 => x"E2422006",  -- SUB R2, R2, #6  (R2 = 4)
        23 => x"E1510002",  -- CMP R1, R2     (9 - 4 = 5)
        24 => x"E1520001",  -- C3 : CMP R2, R1

        -- C4 : verification du Carry/Borrow
        25 => x"E2425005",  -- SUB R5, R2, #5  : R5 = 0xFFFFFFFF
        26 => x"E1550002",  -- CMP R5, R2      : 0xFFFFFFFF - 4
        
               -- C6 : CMP ne doit pas modifier les registres
        27 => x"E280302A",  -- ADD R3, R0, #42
        28 => x"E1510002",  -- CMP R1, R2

        -- C7 : les flags de CMP commandent l'instruction suivante
        29 => x"E1510002",  -- CMP R1, R2
        30 => x"02833001",  -- ADDEQ R3, R3, #1
        31 => x"12833001"   -- ADDNE R3, R3, #1
    );

begin

    Instr <= ROM(to_integer(unsigned(PC(6 downto 2))));

end Behavioral;

