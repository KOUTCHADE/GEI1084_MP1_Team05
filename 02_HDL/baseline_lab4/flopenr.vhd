----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 00:36:53
-- Design Name: 
-- Module Name: flopenr - Behavioral
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

entity flopenr is
    generic (
        WIDTH : positive := 2
    );
    port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        en    : in  STD_LOGIC;
        d     : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        q     : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end flopenr;

architecture behavioral of flopenr is
begin

    process(clk, reset)
    begin
        if reset = '1' then
            q <= (others => '0');

        elsif rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;

end behavioral;
