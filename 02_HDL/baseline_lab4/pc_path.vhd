



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc_path is
    port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        PCSrc   : in  STD_LOGIC;
        Result  : in  STD_LOGIC_VECTOR(31 downto 0);

        PC      : out STD_LOGIC_VECTOR(31 downto 0);
        PCPlus4 : out STD_LOGIC_VECTOR(31 downto 0);
        PCPlus8 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end pc_path;

architecture structural of pc_path is

    signal PC_internal      : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus4_internal : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus8_internal : STD_LOGIC_VECTOR(31 downto 0);
    signal PCNext_internal  : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- Premier additionneur : PC + 4
    add_PC4 : entity work.adder
        port map (
            a => PC_internal,
            b => x"00000004",
            y => PCPlus4_internal
        );

    -- Deuxieme additionneur : PCPlus4 + 4
    add_PC8 : entity work.adder
        port map (
            a => PCPlus4_internal,
            b => x"00000004",
            y => PCPlus8_internal
        );

    -- Multiplexeur de selection du prochain PC
    PCNext_internal <= PCPlus4_internal
                       when PCSrc = '0'
                       else Result;

    -- Registre PC
    u_pc : entity work.pc_reg
        port map (
            clk    => clk,
            reset  => reset,
            PCNext => PCNext_internal,
            PC     => PC_internal
        );

    -- Sorties
    PC      <= PC_internal;
    PCPlus4 <= PCPlus4_internal;
    PCPlus8 <= PCPlus8_internal;

end structural;
