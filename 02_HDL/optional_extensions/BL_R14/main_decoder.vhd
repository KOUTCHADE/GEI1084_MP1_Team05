library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main_decoder is
    Port (
        Op       : in  STD_LOGIC_VECTOR(1 downto 0);
        Funct5   : in  STD_LOGIC;
        Funct4   : in  STD_LOGIC;
        Funct0   : in  STD_LOGIC;
        Branch   : out STD_LOGIC;
        MemtoReg : out STD_LOGIC;
        MemW     : out STD_LOGIC;
        ALUSrc   : out STD_LOGIC;
        ImmSrc   : out STD_LOGIC_VECTOR(1 downto 0);
        RegW     : out STD_LOGIC;
        RegSrc   : out STD_LOGIC_VECTOR(1 downto 0);
        ALUOp    : out STD_LOGIC;
        Link     : out STD_LOGIC
    );
end main_decoder;

architecture Behavioral of main_decoder is
begin
    process(Op, Funct5, Funct4, Funct0)
    begin
        Branch   <= '0';
        MemtoReg <= '0';
        MemW     <= '0';
        ALUSrc   <= '0';
        ImmSrc   <= "00";
        RegW     <= '0';
        RegSrc   <= "00";
        ALUOp    <= '0';
        Link     <= '0';

        case Op is
            when "00" =>
                ALUOp <= '1';
                RegW  <= '1';
                if Funct5 = '1' then
                    ALUSrc <= '1';
                end if;

            when "01" =>
                ALUSrc <= '1';
                ImmSrc <= "01";
                if Funct0 = '0' then
                    MemW   <= '1';
                    RegSrc <= "10";
                else
                    MemtoReg <= '1';
                    RegW     <= '1';
                end if;

            when "10" =>
                Branch <= '1';
                Link   <= Funct4;
                RegW   <= Funct4;
                ALUSrc <= '1';
                ImmSrc <= "10";
                RegSrc <= "01";

            when others =>
                null;
        end case;
    end process;
end Behavioral;
