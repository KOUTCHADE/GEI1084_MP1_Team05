----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 03:48:22
-- Design Name: 
-- Module Name: condlogic - Behavioral
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

entity condlogic is
    port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;

        Cond      : in  STD_LOGIC_VECTOR(3 downto 0);
        ALUFlags  : in  STD_LOGIC_VECTOR(3 downto 0);
        FlagW     : in  STD_LOGIC_VECTOR(1 downto 0);

        RegW      : in  STD_LOGIC;
        MemW      : in  STD_LOGIC;
        PCS       : in  STD_LOGIC;

        RegWrite  : out STD_LOGIC;
        MemWrite  : out STD_LOGIC;
        PCSrc     : out STD_LOGIC
    );
end condlogic;

architecture structural of condlogic is

    signal Flags_internal  : STD_LOGIC_VECTOR(3 downto 0);
    signal CondEx_internal : STD_LOGIC;

begin

    -- Verification de la condition ARM
    u_condcheck : entity work.condcheck
        port map (
            Cond   => Cond,
            Flags  => Flags_internal,
            CondEx => CondEx_internal
        );

    -- Memorisation conditionnelle des flags
    u_flags : entity work.flag_registers
        port map (
            clk      => clk,
            reset    => reset,
            ALUFlags => ALUFlags,
            FlagW    => FlagW,
            CondEx   => CondEx_internal,
            Flags    => Flags_internal
        );

    -- Masquage conditionnel des ecritures
    RegWrite <= RegW and CondEx_internal;
    MemWrite <= MemW and CondEx_internal;
    PCSrc    <= PCS and CondEx_internal;

end structural;
