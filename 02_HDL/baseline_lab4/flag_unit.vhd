----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.09.2026 21:47:04
-- Design Name: 
-- Module Name: flag_unit - synth
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

entity flag_unit is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           Sum : in STD_LOGIC_VECTOR (31 downto 0);
           Result : in STD_LOGIC_VECTOR (31 downto 0);
           Cout : in STD_LOGIC;
           ALUControl : in STD_LOGIC_VECTOR (1 downto 0);
           ALUFlags : out STD_LOGIC_VECTOR (3 downto 0));
end flag_unit;

architecture synth of flag_unit is

signal N : STD_LOGIC;
    signal Z : STD_LOGIC;
    signal C : STD_LOGIC;
    signal V : STD_LOGIC;

begin

-- Negative
    N <= Result(31);
    -- Zero
    Z <= '1' when Result = x"00000000" else '0';
    -- Carry
    C <= Cout and (not ALUControl(1));
    -- Overflow
    V <= (not ALUControl(1))
         and (not (A(31) xor B(31) xor ALUControl(0)))
         and (A(31) xor Sum(31));
    -- Regroupement des drapeaux : N Z C V
    ALUFlags <= N & Z & C & V;

end synth;
