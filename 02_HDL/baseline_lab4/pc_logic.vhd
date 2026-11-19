----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2026 15:06:04
-- Design Name: 
-- Module Name: pc_logic - Behavioral
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

entity pc_logic is
    Port (
        Rd     : in  STD_LOGIC_VECTOR(3 downto 0);
        RegW   : in  STD_LOGIC;
        Branch : in  STD_LOGIC;
        PCSrc  : out STD_LOGIC
    );
end pc_logic;

architecture Behavioral of pc_logic is
begin

    PCSrc <= '1' when
             ((Rd = "1111" and RegW = '1')
               or Branch = '1')
             else '0';

end Behavioral;