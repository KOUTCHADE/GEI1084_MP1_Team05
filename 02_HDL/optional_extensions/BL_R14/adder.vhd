library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder is
    port (
        a : in  STD_LOGIC_VECTOR(31 downto 0);
        b : in  STD_LOGIC_VECTOR(31 downto 0);
        y : out STD_LOGIC_VECTOR(31 downto 0)
    );
end adder;

architecture behave of adder is
begin
    y <= STD_LOGIC_VECTOR(UNSIGNED(a) + UNSIGNED(b));
end behave;
