-- Banc de test SHIFT (S1-S10) et CMP C5 - GEI1084 MP1
-- A simuler avec 03_TESTBENCH/SHIFT/imem.vhd a la place de final_design/imem.vhd.
-- A chaque front montant, on compare aux valeurs calculees avant simulation :
-- PC, Instr, ALUResult, PCSrc, RegWrite et, pour C5, les flags memorises NZCV.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_shift is
end tb_shift;

architecture Behavioral of tb_shift is

    signal CLK          : STD_LOGIC := '0';
    signal reset        : STD_LOGIC := '1';

    signal PC           : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr        : STD_LOGIC_VECTOR(31 downto 0);
    signal PCSrc        : STD_LOGIC;
    signal ALUResult    : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData    : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUFlags_dbg : STD_LOGIC_VECTOR(3 downto 0);
    signal FlagW_dbg    : STD_LOGIC_VECTOR(1 downto 0);
    signal RegWrite_dbg : STD_LOGIC;
    signal Flags_dbg    : STD_LOGIC_VECTOR(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant NB_CYCLES  : integer := 27;
    constant NB_TESTS   : integer := 12;  -- 1..10 = S1..S10, 11 = C5, 12 = SUB decale (complementaire)

    type word_array is array (1 to NB_CYCLES) of STD_LOGIC_VECTOR(31 downto 0);
    type nib_array  is array (1 to NB_CYCLES) of STD_LOGIC_VECTOR(3 downto 0);
    type bit_array  is array (1 to NB_CYCLES) of STD_LOGIC;
    type int_array  is array (1 to NB_CYCLES) of integer;
    type test_count is array (1 to NB_TESTS) of integer;
    type name_array is array (1 to NB_TESTS) of string(1 to 3);

    constant TEST_NAME : name_array := (
        "S1 ", "S2 ", "S3 ", "S4 ", "S5 ", "S6 ", "S7 ", "S8 ", "S9 ", "S10", "C5 ", "SUB"
    );

    constant EXP_PC : word_array := (
        x"00000000", x"00000004", x"00000008", x"0000000C", x"00000010",
        x"00000014", x"00000018", x"0000001C", x"00000020", x"00000024",
        x"00000028", x"0000002C", x"00000030", x"00000034", x"00000038",
        x"0000003C", x"00000040", x"00000044", x"00000048", x"0000004C",
        x"00000050", x"00000054", x"00000058", x"0000005C", x"00000060",
        x"00000064", x"00000068"
    );

    constant EXP_INSTR : word_array := (
        x"E2801012", x"E2802034", x"E0821401", x"E2802056", x"E0821401",
        x"E2802078", x"E0821401", x"E0803001", x"E2804003", x"E0805084",
        x"E0805204", x"E2806020", x"E08070A6", x"E2808001", x"E0808F88",
        x"E08090A8", x"E080A124", x"E001B204", x"E186C404", x"E046D104",
        x"E084D006", x"E284E085", x"E2802001", x"E1580002", x"62803055",
        x"428030AA", x"EAFFFFFE"
    );

    constant EXP_ALU : word_array := (
        x"00000012", x"00000034", x"00001234", x"00000056", x"00123456",
        x"00000078", x"12345678", x"12345678", x"00000003", x"00000006",
        x"00000030", x"00000020", x"00000010", x"00000001", x"80000000",
        x"40000000", x"00000000", x"00000030", x"00000320", x"00000014",
        x"00000023", x"00000088", x"00000001", x"7FFFFFFF", x"00000055",
        x"000000AA", x"00000068"
    );

    constant EXP_PCSRC : bit_array := (
        '0', '0', '0', '0', '0', '0', '0', '0', '0',
        '0', '0', '0', '0', '0', '0', '0', '0', '0',
        '0', '0', '0', '0', '0', '0', '0', '0', '1'
    );

    constant EXP_REGWRITE : bit_array := (
        '1', '1', '1', '1', '1', '1', '1', '1', '1',
        '1', '1', '1', '1', '1', '1', '1', '1', '1',
        '1', '1', '1', '1', '1', '0', '1', '0', '0'
    );

    -- Flags NZCV memorises (avant l'execution de l'instruction du cycle);
    -- verifies seulement la ou CHECK_FLAGS = '1' (instructions conditionnelles apres le CMP de C5).
    constant EXP_FLAGS : nib_array := (
        "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000",
        "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000",
        "0000", "0000", "0000", "0000", "0000", "0000", "0011", "0011", "0011"
    );

    constant CHECK_FLAGS : bit_array := (
        '0', '0', '0', '0', '0', '0', '0', '0', '0',
        '0', '0', '0', '0', '0', '0', '0', '0', '0',
        '0', '0', '0', '0', '0', '0', '1', '1', '0'
    );

    constant TEST_ID : int_array := (
        0, 0, 3, 0, 3, 0, 3, 1, 0,
        2, 3, 0, 4, 0, 5, 5, 6, 7,
        8, 12, 9, 10, 0, 11, 11, 11, 0
    );

begin

    CLK <= not CLK after CLK_PERIOD / 2;

    DUT : entity work.arm_top
        port map (
            CLK          => CLK,
            reset        => reset,
            PC           => PC,
            Instr        => Instr,
            PCSrc        => PCSrc,
            ALUResult    => ALUResult,
            WriteData    => WriteData,
            ALUFlags_dbg => ALUFlags_dbg,
            FlagW_dbg    => FlagW_dbg,
            RegWrite_dbg => RegWrite_dbg,
            Flags_dbg    => Flags_dbg
        );

    stimulus : process
        variable errors     : integer := 0;
        variable cycle_ok   : boolean;
        variable test_fails : test_count := (others => 0);
        variable label_txt  : string(1 to 5);
    begin

        reset <= '1';
        wait for 22 ns;
        reset <= '0';

        for i in 1 to NB_CYCLES loop

            wait until rising_edge(CLK);
            cycle_ok := true;

            if PC /= EXP_PC(i) then cycle_ok := false; end if;
            if Instr /= EXP_INSTR(i) then cycle_ok := false; end if;
            if ALUResult /= EXP_ALU(i) then cycle_ok := false; end if;
            if PCSrc /= EXP_PCSRC(i) then cycle_ok := false; end if;
            if RegWrite_dbg /= EXP_REGWRITE(i) then cycle_ok := false; end if;
            if CHECK_FLAGS(i) = '1' and Flags_dbg /= EXP_FLAGS(i) then cycle_ok := false; end if;

            if TEST_ID(i) = 0 then
                label_txt := "setup";
            else
                label_txt := TEST_NAME(TEST_ID(i)) & "  ";
            end if;

            if cycle_ok then
                report "SHIFT cycle " & integer'image(i) & " [" & label_txt & "] : PASS"
                     & " | PC=" & to_hstring(PC)
                     & " Instr=" & to_hstring(Instr)
                     & " ALUResult=" & to_hstring(ALUResult)
                     & " RegWrite=" & std_logic'image(RegWrite_dbg)
                     & " NZCV=" & to_string(Flags_dbg)
                     severity note;
            else
                errors := errors + 1;
                if TEST_ID(i) /= 0 then
                    test_fails(TEST_ID(i)) := test_fails(TEST_ID(i)) + 1;
                end if;
                report "SHIFT cycle " & integer'image(i) & " [" & label_txt & "] : FAIL"
                     & " | attendu PC=" & to_hstring(EXP_PC(i))
                     & " ALUResult=" & to_hstring(EXP_ALU(i))
                     & " RegWrite=" & std_logic'image(EXP_REGWRITE(i))
                     & " NZCV=" & to_string(EXP_FLAGS(i))
                     & " | observe PC=" & to_hstring(PC)
                     & " ALUResult=" & to_hstring(ALUResult)
                     & " RegWrite=" & std_logic'image(RegWrite_dbg)
                     & " NZCV=" & to_string(Flags_dbg)
                     severity error;
            end if;

        end loop;

        report "----------------------------------" severity note;

        for t in 1 to NB_TESTS loop
            if test_fails(t) = 0 then
                report TEST_NAME(t) & " : PASS" severity note;
            else
                report TEST_NAME(t) & " : FAIL" severity error;
            end if;
        end loop;

        report "----------------------------------" severity note;
        report "SHIFT : cycles en echec = " & integer'image(errors)
             & " / " & integer'image(NB_CYCLES) severity note;

        if errors = 0 then
            report "SHIFT : SIMULATION CONFORME (S1-S10, C5)" severity note;
        else
            report "SHIFT : SIMULATION NON CONFORME" severity warning;
        end if;

        report "----------------------------------" severity note;

        std.env.stop;
        wait;

    end process;

end Behavioral;
