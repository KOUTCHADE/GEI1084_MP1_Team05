library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_t1_branch is
end tb_t1_branch;

architecture Behavioral of tb_t1_branch is

    signal CLK       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '1';

    signal PC        : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr     : STD_LOGIC_VECTOR(31 downto 0);
    signal PCSrc     : STD_LOGIC;
    signal ALUResult : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant NB_CYCLES  : integer := 4;

    type word_array is array (1 to NB_CYCLES) of STD_LOGIC_VECTOR(31 downto 0);
    type bit_array  is array (1 to NB_CYCLES) of STD_LOGIC;

    constant EXP_PC : word_array := (
        x"00000000",
        x"0000000C",
        x"00000004",
        x"00000008"
    );

    constant EXP_INSTR : word_array := (
        x"EA000001",
        x"EAFFFFFC",
        x"E2801011",
        x"E2802022"
    );

    constant EXP_ALU : word_array := (
        x"0000000C",
        x"00000004",
        x"00000011",
        x"00000022"
    );

    constant EXP_PCSRC : bit_array := ('1', '1', '0', '0');

begin

    CLK <= not CLK after CLK_PERIOD / 2;

    DUT : entity work.arm_top
        port map (
            CLK       => CLK,
            reset     => reset,
            PC        => PC,
            Instr     => Instr,
            PCSrc     => PCSrc,
            ALUResult => ALUResult,
            WriteData => WriteData
        );

    stimulus : process
        variable errors  : integer := 0;
        variable cycle_ok : boolean;
    begin

        reset <= '1';
        wait for 22 ns;
        reset <= '0';

        for i in 1 to NB_CYCLES loop

            wait until rising_edge(CLK);
            cycle_ok := true;

            if PC /= EXP_PC(i) then
                cycle_ok := false;
            end if;

            if Instr /= EXP_INSTR(i) then
                cycle_ok := false;
            end if;

            if ALUResult /= EXP_ALU(i) then
                cycle_ok := false;
            end if;

            if PCSrc /= EXP_PCSRC(i) then
                cycle_ok := false;
            end if;

            if cycle_ok then
                report "T1 cycle " & integer'image(i) & " : PASS"
                     & " | PC=" & to_hstring(PC)
                     & " Instr=" & to_hstring(Instr)
                     & " ALUResult=" & to_hstring(ALUResult)
                     & " PCSrc=" & std_logic'image(PCSrc)
                     severity note;
            else
                errors := errors + 1;
                report "T1 cycle " & integer'image(i) & " : FAIL"
                     & " | attendu PC=" & to_hstring(EXP_PC(i))
                     & " Instr=" & to_hstring(EXP_INSTR(i))
                     & " ALUResult=" & to_hstring(EXP_ALU(i))
                     & " PCSrc=" & std_logic'image(EXP_PCSRC(i))
                     & " | observe PC=" & to_hstring(PC)
                     & " Instr=" & to_hstring(Instr)
                     & " ALUResult=" & to_hstring(ALUResult)
                     & " PCSrc=" & std_logic'image(PCSrc)
                     severity error;
            end if;

        end loop;

        report "----------------------------------" severity note;
        report "T1 : cycles en echec = " & integer'image(errors)
             & " / " & integer'image(NB_CYCLES) severity note;

        if errors = 0 then
            report "T1 : CHEMIN DE BRANCHEMENT CONFORME" severity note;
        else
            report "T1 : CHEMIN DE BRANCHEMENT NON CONFORME" severity warning;
        end if;

        report "----------------------------------" severity note;

        std.env.stop;
        wait;

    end process;

end Behavioral;
