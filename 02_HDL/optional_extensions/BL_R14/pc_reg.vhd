----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 17:46:23
-- Design Name: 
-- Module Name: pc_reg - Behavioral
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

entity pc_reg is
    port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        PCNext : in  STD_LOGIC_VECTOR(31 downto 0);
        PC     : out STD_LOGIC_VECTOR(31 downto 0)
    );
end pc_reg;

architecture structural of pc_reg is
begin

    u_pc : entity work.flopenr
        generic map (
            WIDTH => 32
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => '1',
            d     => PCNext,
            q     => PC
        );

end structural;
