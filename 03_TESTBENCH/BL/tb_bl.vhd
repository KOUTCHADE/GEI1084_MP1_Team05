library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_bl is
end tb_bl;

architecture Behavioral of tb_bl is

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
    constant NB_CYCLES  : integer := 19;
    constant NB_TESTS   : integer := 8;

    type word_array is array (1 to NB_CYCLES) of STD_LOGIC_VECTOR(31 downto 0);
    type bit_array  is array (1 to NB_CYCLES) of STD_LOGIC;
    type int_array  is array (1 to NB_CYCLES) of integer;
    type test_count is array (1 to NB_TESTS) of integer;

    constant EXP_PC : word_array := (
        x"00000000", x"00000004", x"0000000C", x"00000010", x"00000014",
        x"00000018", x"0000001C", x"00000020", x"00000030", x"00000034",
        x"00000038", x"0000003C", x"00000040", x"0000004C", x"00000050",
        x"0000005C", x"00000054", x"00000058", x"00000068"
    );

    constant EXP_INSTR : word_array := (
        x"E280E0AB", x"EA000000", x"E28E5000", x"E1500000", x"1B000004",
        x"E28E5000", x"E2802002", x"0B000002", x"E28E5000", x"E2806066",
        x"E2867000", x"E28E5000", x"EB000001", x"E28E5000", x"EA000001",
        x"EBFFFFFC", x"E28E5000", x"EA000002", x"EAFFFFFE"
    );

    constant EXP_ALU : word_array := (
        x"000000AB", x"0000000C", x"000000AB", x"00000000", x"0000002C",
        x"000000AB", x"00000002", x"00000030", x"00000024", x"00000066",
        x"00000066", x"00000024", x"0000004C", x"00000044", x"0000005C",
        x"00000054", x"00000060", x"00000068", x"00000068"
    );

    constant EXP_PCSRC : bit_array := (
        '0', '1', '0', '0', '0',
        '0', '0', '1', '0', '0',
        '0', '0', '1', '0', '1',
        '1', '0', '1', '1'
    );

    constant EXP_REGWRITE : bit_array := (
        '1', '0', '1', '0', '0',
        '1', '1', '1', '1', '1',
        '1', '1', '1', '1', '0',
        '1', '1', '0', '0'
    );

    constant TEST_ID : int_array := (
        0, 1, 1, 0, 6,
        6, 0, 5, 5, 7,
        7, 8, 2, 2, 0,
        4, 4, 0, 0
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

            if RegWrite_dbg /= EXP_REGWRITE(i) then
                cycle_ok := false;
            end if;

            if TEST_ID(i) = 0 then
                label_txt := "setup";
            else
                label_txt := "B" & integer'image(TEST_ID(i)) & "   ";
            end if;

            if cycle_ok then
                report "BL cycle " & integer'image(i) & " [" & label_txt & "] : PASS"
                     & " | PC=" & to_hstring(PC)
                     & " Instr=" & to_hstring(Instr)
                     & " ALUResult=" & to_hstring(ALUResult)
                     & " PCSrc=" & std_logic'image(PCSrc)
                     & " RegWrite=" & std_logic'image(RegWrite_dbg)
                     severity note;
            else
                errors := errors + 1;
                if TEST_ID(i) /= 0 then
                    test_fails(TEST_ID(i)) := test_fails(TEST_ID(i)) + 1;
                end if;
                report "BL cycle " & integer'image(i) & " [" & label_txt & "] : FAIL"
                     & " | attendu PC=" & to_hstring(EXP_PC(i))
                     & " Instr=" & to_hstring(EXP_INSTR(i))
                     & " ALUResult=" & to_hstring(EXP_ALU(i))
                     & " PCSrc=" & std_logic'image(EXP_PCSRC(i))
                     & " RegWrite=" & std_logic'image(EXP_REGWRITE(i))
                     & " | observe PC=" & to_hstring(PC)
                     & " Instr=" & to_hstring(Instr)
                     & " ALUResult=" & to_hstring(ALUResult)
                     & " PCSrc=" & std_logic'image(PCSrc)
                     & " RegWrite=" & std_logic'image(RegWrite_dbg)
                     severity error;
            end if;

        end loop;

        report "----------------------------------" severity note;

        for t in 1 to NB_TESTS loop
            if t /= 3 then
                if test_fails(t) = 0 then
                    report "B" & integer'image(t) & " : PASS" severity note;
                else
                    report "B" & integer'image(t) & " : FAIL" severity error;
                end if;
            else
                if test_fails(5) = 0 then
                    report "B3 : PASS (meme BL que B5, a l'adresse 0x20)" severity note;
                else
                    report "B3 : FAIL (meme BL que B5, a l'adresse 0x20)" severity error;
                end if;
            end if;
        end loop;

        report "----------------------------------" severity note;
        report "BL : cycles en echec = " & integer'image(errors)
             & " / " & integer'image(NB_CYCLES) severity note;

        if errors = 0 then
            report "BL : SIMULATION CONFORME (B1-B8)" severity note;
        else
            report "BL : SIMULATION NON CONFORME" severity warning;
        end if;

        report "----------------------------------" severity note;

        std.env.stop;
        wait;

    end process;

end Behavioral;
