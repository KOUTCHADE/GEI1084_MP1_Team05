library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    generic (BL_TEST_MODE : boolean := false);
    Port (
        CLK      : in  STD_LOGIC;
        RegWrite : in  STD_LOGIC;
        RA1      : in  STD_LOGIC_VECTOR(3 downto 0);
        RA2      : in  STD_LOGIC_VECTOR(3 downto 0);
        A3       : in  STD_LOGIC_VECTOR(3 downto 0);
        WD3      : in  STD_LOGIC_VECTOR(31 downto 0);
        R15      : in  STD_LOGIC_VECTOR(31 downto 0);
        RD1      : out STD_LOGIC_VECTOR(31 downto 0);
        RD2      : out STD_LOGIC_VECTOR(31 downto 0);
        R14Value : out STD_LOGIC_VECTOR(31 downto 0)
    );
end register_file;

architecture Behavioral of register_file is
    type ram_type is array (0 to 15) of STD_LOGIC_VECTOR(31 downto 0);
    function initial_ram(test_mode : boolean) return ram_type is
        variable r : ram_type := (others => (others => '0'));
    begin
        if test_mode then
            r(14) := x"12345678";
        end if;
        return r;
    end function;
    signal RAM : ram_type := initial_ram(BL_TEST_MODE);
begin
    RD1 <= R15 when RA1 = "1111" else RAM(to_integer(unsigned(RA1)));
    RD2 <= R15 when RA2 = "1111" else RAM(to_integer(unsigned(RA2)));
    R14Value <= RAM(14);

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RegWrite = '1' and A3 /= "1111" then
                RAM(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if;
    end process;
end Behavioral;
