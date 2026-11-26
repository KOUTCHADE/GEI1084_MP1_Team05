----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.09.2026 10:42:46
-- Design Name: 
-- Module Name: alu32 - struct
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


entity alu32 is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           ALUControl : in STD_LOGIC_VECTOR (1 downto 0);
           Result : out STD_LOGIC_VECTOR (31 downto 0);
           ALUFlags : out STD_LOGIC_VECTOR (3 downto 0));
end alu32;

architecture struct of alu32 is

  -- Déclaration du premier sous-module
    component alu_arithmetic
        port(
            A    : in  STD_LOGIC_VECTOR(31 downto 0);
            B    : in  STD_LOGIC_VECTOR(31 downto 0);
            Sub  : in  STD_LOGIC;
            Sum  : out STD_LOGIC_VECTOR(31 downto 0);
            Cout : out STD_LOGIC
        );
    end component;


    -- Déclaration du deuxième sous-module
    component result_selector
        port(
            A          : in  STD_LOGIC_VECTOR(31 downto 0);
            B          : in  STD_LOGIC_VECTOR(31 downto 0);
            Sum        : in  STD_LOGIC_VECTOR(31 downto 0);
            ALUControl : in  STD_LOGIC_VECTOR(1 downto 0);
            Result     : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    
    -- Déclaration du troisième sous-module
    component flag_unit
        port(
            A          : in  STD_LOGIC_VECTOR(31 downto 0);
            B          : in  STD_LOGIC_VECTOR(31 downto 0);
            Sum        : in  STD_LOGIC_VECTOR(31 downto 0);
            Result     : in  STD_LOGIC_VECTOR(31 downto 0);
            Cout       : in  STD_LOGIC;
            ALUControl : in  STD_LOGIC_VECTOR(1 downto 0);
            ALUFlags   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;


    -- Signaux internes reliant les sous-modules
    signal Sum_internal  : STD_LOGIC_VECTOR(31 downto 0);
    signal Cout_internal : STD_LOGIC;
    signal Result_internal : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- Instance du bloc arithmétique
    arithmetic_unit: alu_arithmetic
        port map(
            A    => A,
            B    => B,
            Sub  => ALUControl(0),
            Sum  => Sum_internal,
            Cout => Cout_internal
        );


    -- Instance du bloc de sélection
    selector_unit: result_selector
        port map(
            A          => A,
            B          => B,
            Sum        => Sum_internal,
            ALUControl => ALUControl,
            Result => Result_internal
        );
        
    -- Instance du bloc des drapeaux
    flags_unit: flag_unit
        port map(
            A          => A,
            B          => B,
            Sum        => Sum_internal,
            Result     => Result_internal,
            Cout       => Cout_internal,
            ALUControl => ALUControl,
            ALUFlags   => ALUFlags
        );
-- Connexion du résultat interne à la sortie de l'ALU        
Result <= Result_internal;

end struct;
