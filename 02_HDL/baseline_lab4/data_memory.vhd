----------------------------------------------------------------------------------

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity data_memory is
    Port ( CLK : in STD_LOGIC;
           MemWrite : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (31 downto 0);
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           RD : out STD_LOGIC_VECTOR (31 downto 0));
end data_memory;

architecture Behavioral of data_memory is

type ram_type is array (0 to 63)
        of STD_LOGIC_VECTOR(31 downto 0);

    signal RAM : ram_type := (others => (others => '0'));
begin

 -- Lecture asynchrone
    RD <= RAM(to_integer(unsigned(A(5 downto 0))));
    
     -- Ecriture synchrone
    process(CLK)
    begin
        if rising_edge(CLK) then
            if MemWrite = '1' then
                RAM(to_integer(unsigned(A(5 downto 0)))) <= WD;
            end if;
        end if;
    end process;
      

end Behavioral;
