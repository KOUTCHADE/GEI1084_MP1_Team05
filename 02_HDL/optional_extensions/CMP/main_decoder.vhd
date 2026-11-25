----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2026 13:42:30
-- Design Name: 
-- Module Name: main_decoder - Behavioral
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

entity main_decoder is
    Port (
        Op       : in  STD_LOGIC_VECTOR(1 downto 0);
        Funct5   : in  STD_LOGIC;
        Funct0   : in  STD_LOGIC;
        Opcode   : in STD_LOGIC_VECTOR(3 downto 0);

        Branch   : out STD_LOGIC;
        MemtoReg : out STD_LOGIC;
        MemW     : out STD_LOGIC;
        ALUSrc   : out STD_LOGIC;
        ImmSrc   : out STD_LOGIC_VECTOR(1 downto 0);
        RegW     : out STD_LOGIC;
        RegSrc   : out STD_LOGIC_VECTOR(1 downto 0);
        ALUOp    : out STD_LOGIC
    );
end main_decoder;

architecture Behavioral of main_decoder is
begin

    process(Op, Funct5, Funct0, Opcode)
    begin
        -- Valeurs par defaut
        Branch   <= '0';
        MemtoReg <= '0';
        MemW     <= '0';
        ALUSrc   <= '0';
        ImmSrc   <= "00";
        RegW     <= '0';
        RegSrc   <= "00";
        ALUOp    <= '0';

        case Op is

            when "00" =>
                -- Data Processing
                if Funct5 = '0' then
                    -- DP Reg
                    Branch   <= '0';
                    MemtoReg <= '0';
                    MemW     <= '0';
                    ALUSrc   <= '0';
                    ImmSrc   <= "00";
                    if Opcode /= "1010" then
                        RegW <= '1';
                    else
                        RegW <= '0';
                    end if;
                    RegSrc   <= "00";
                    ALUOp    <= '1';

                elsif Funct5 = '1' then
                    -- DP Imm
                    Branch   <= '0';
                    MemtoReg <= '0';
                    MemW     <= '0';
                    ALUSrc   <= '1';
                    ImmSrc   <= "00";
                    if Opcode /= "1010" then
                        RegW <= '1';
                    else
                        RegW <= '0';
                    end if;
                    RegSrc   <= "00";
                    ALUOp    <= '1';
                end if;

            when "01" =>
                -- Memory Instructions
                if Funct0 = '0' then
                    -- STR
                    Branch   <= '0';
                    MemtoReg <= '0';
                    MemW     <= '1';
                    ALUSrc   <= '1';
                    ImmSrc   <= "01";
                    RegW     <= '0';
                    RegSrc   <= "10";
                    ALUOp    <= '0';

                elsif Funct0 = '1' then
                    -- LDR
                    Branch   <= '0';
                    MemtoReg <= '1';
                    MemW     <= '0';
                    ALUSrc   <= '1';
                    ImmSrc   <= "01";
                    RegW     <= '1';
                    RegSrc   <= "00";
                    ALUOp    <= '0';
                end if;

            when "10" =>
                -- Branch
                Branch   <= '1';
                MemtoReg <= '0';
                MemW     <= '0';
                ALUSrc   <= '1';
                ImmSrc   <= "10";
                RegW     <= '0';
                RegSrc   <= "01";
                ALUOp    <= '0';

            when others =>
                -- Instruction non reconnue
                null;

        end case;

    end process;

end Behavioral;
