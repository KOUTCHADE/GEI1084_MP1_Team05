----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2026 11:04:49 PM
-- Design Name: 
-- Module Name: shifter_decoder - Behavioral
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

entity shift_decoder is
    Port (
        Instr        : in  STD_LOGIC_VECTOR(31 downto 0);
        ShiftEnable  : out STD_LOGIC;
        ShiftControl : out STD_LOGIC_VECTOR(1 downto 0);
        ShiftAmount  : out STD_LOGIC_VECTOR(4 downto 0)
    );
end shift_decoder;

architecture Behavioral of shift_decoder is
begin

    process(Instr)
    begin

        -- Valeurs par defaut : aucun decalage
        ShiftEnable  <= '0';
        ShiftControl <= "00";
        ShiftAmount  <= "00000";

        -- Data Processing avec operande registre
        if Instr(27 downto 26) = "00" and
           Instr(25) = '0' and
           Instr(4) = '0' then

            -- Verification de l'operation principale
            case Instr(24 downto 21) is

                -- ADD, SUB, AND, ORR
                when "0100" | "0010" |
                     "0000" | "1100" =>

                    case Instr(6 downto 5) is

                        when "00" =>
                            -- Logical Shift Left
                            ShiftEnable  <= '1';
                            ShiftControl <= "00";
                            ShiftAmount  <= Instr(11 downto 7);

                        when "01" =>
                            -- Logical Shift Right
                            ShiftEnable  <= '1';
                            ShiftControl <= "01";
                            ShiftAmount  <= Instr(11 downto 7);

                        when others =>
                            -- ASR et ROR hors portee
                            null;

                    end case;

                when others =>
                    -- Operation non prise en charge
                    null;

            end case;

        end if;

    end process;


end Behavioral;
