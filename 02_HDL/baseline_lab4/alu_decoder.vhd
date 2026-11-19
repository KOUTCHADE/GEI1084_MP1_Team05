----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2026 16:46:39
-- Design Name: 
-- Module Name: alu_decoder - Behavioral
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

entity alu_decoder is
    Port (
        ALUOp      : in  STD_LOGIC;
        Funct      : in  STD_LOGIC_VECTOR(4 downto 0);
        ALUControl : out STD_LOGIC_VECTOR(1 downto 0);
        FlagW      : out STD_LOGIC_VECTOR(1 downto 0)
    );
end alu_decoder;

architecture Behavioral of alu_decoder is
begin

    process(ALUOp, Funct)
    begin
        -- Valeurs par defaut
        ALUControl <= "00";
        FlagW      <= "00";

        if ALUOp = '1' then

            case Funct(4 downto 1) is

                when "0100" =>
                    -- ADD / ADDS
                    ALUControl <= "00";

                    if Funct(0) = '1' then
                        FlagW <= "11";
                    end if;

                when "0010" =>
                    -- SUB / SUBS
                    ALUControl <= "01";

                    if Funct(0) = '1' then
                        FlagW <= "11";
                    end if;

                when "0000" =>
                    -- AND / ANDS
                    ALUControl <= "10";

                    if Funct(0) = '1' then
                        FlagW <= "10";
                    end if;

                when "1100" =>
                    -- ORR / ORRS
                    ALUControl <= "11";

                    if Funct(0) = '1' then
                        FlagW <= "10";
                    end if;

                when others =>
                    -- Operation non prise en charge
                    null;

            end case;

        end if;

    end process;

end Behavioral;

