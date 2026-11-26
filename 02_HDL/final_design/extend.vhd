----------------------------------------------------------------------------------

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity extend is
    Port ( Instr : in STD_LOGIC_VECTOR (23 downto 0);
           ImmSrc : in STD_LOGIC_VECTOR (1 downto 0);
           ExtImm : out STD_LOGIC_VECTOR (31 downto 0));
end extend;

architecture Behavioral of extend is

begin

process(Instr, ImmSrc)
    begin
        case ImmSrc is

            when "00" =>
                ExtImm <= (31 downto 8 => '0') &
                          Instr(7 downto 0);

            when "01" =>
                ExtImm <= (31 downto 12 => '0') &
                          Instr(11 downto 0);

            when "10" =>
                ExtImm <= (31 downto 26 => Instr(23)) &
                          Instr(23 downto 0) & "00";

            when others =>
                ExtImm <= (others => '0');

        end case;
    end process;

end Behavioral;
