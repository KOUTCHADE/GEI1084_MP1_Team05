----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 00:50:00
-- Design Name: 
-- Module Name: flag_registers - Behavioral
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

entity flag_registers is
    port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        ALUFlags  : in  STD_LOGIC_VECTOR(3 downto 0);
        FlagW     : in  STD_LOGIC_VECTOR(1 downto 0);
        CondEx    : in  STD_LOGIC;
        Flags     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end flag_registers;

architecture structural of flag_registers is

    signal FlagWrite : STD_LOGIC_VECTOR(1 downto 0);

begin

    -- Autorisation conditionnelle des écritures
    FlagWrite <= FlagW and (CondEx & CondEx);

    -- Registre N/Z
    reg_NZ : entity work.flopenr
        generic map (
            WIDTH => 2
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => FlagWrite(1),
            d     => ALUFlags(3 downto 2),
            q     => Flags(3 downto 2)
        );

    -- Registre C/V
    reg_CV : entity work.flopenr
        generic map (
            WIDTH => 2
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => FlagWrite(0),
            d     => ALUFlags(1 downto 0),
            q     => Flags(1 downto 0)
        );

end structural;
