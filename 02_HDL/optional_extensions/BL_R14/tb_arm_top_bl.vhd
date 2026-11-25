library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_arm_top_bl is
end tb_arm_top_bl;

architecture Behavioral of tb_arm_top_bl is
    signal CLK           : STD_LOGIC := '0';
    signal reset         : STD_LOGIC := '1';
    signal PC            : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr         : STD_LOGIC_VECTOR(31 downto 0);
    signal PCSrc         : STD_LOGIC;
    signal ALUResult     : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData     : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus4       : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus8       : STD_LOGIC_VECTOR(31 downto 0);
    signal Link          : STD_LOGIC;
    signal RegWrite      : STD_LOGIC;
    signal WriteBackData : STD_LOGIC_VECTOR(31 downto 0);
    signal R14Value      : STD_LOGIC_VECTOR(31 downto 0);
    constant CLK_PERIOD : time := 10 ns;
begin
    CLK <= not CLK after CLK_PERIOD / 2;

    DUT : entity work.arm_top
        generic map (BL_TEST_MODE => true)
        port map (
            CLK => CLK,
            reset => reset,
            PC => PC,
            Instr => Instr,
            PCSrc => PCSrc,
            ALUResult => ALUResult,
            WriteData => WriteData,
            PCPlus4 => PCPlus4,
            PCPlus8 => PCPlus8,
            Link => Link,
            RegWrite => RegWrite,
            WriteBackData => WriteBackData,
            R14Value => R14Value
        );

    stimulus : process
    begin
        reset <= '1';
        wait for 30 ns;
        reset <= '0';
        wait for 1 ns;

        assert PC = x"00000000" and R14Value = x"12345678"
            report "Initialisation du PC ou du lien de test incorrecte"
            severity failure;

        -- B1: un B ordinaire doit atteindre la cible sans modifier R14.
        assert Instr = x"EA000000" and PCSrc = '1' and Link = '0'
            report "B1: B ordinaire non pris ou decode comme BL"
            severity failure;
        wait until rising_edge(CLK); wait for 1 ns;
        assert PC = x"00000008" and R14Value = x"12345678"
            report "B1: cible ou preservation de R14 incorrecte"
            severity failure;
        report "B1 PASS" severity note;

        -- B2/B3: BL avant; la cible utilise PC+8 et LR recoit PC+4.
        assert Instr = x"EB000001" and PCPlus4 = x"0000000C"
               and PCPlus8 = x"00000010" and Link = '1'
               and PCSrc = '1' and RegWrite = '1'
            report "B2/B3: preparation BL avant invalide"
            severity failure;
        wait until rising_edge(CLK); wait for 1 ns;
        assert PC = x"00000014"
            report "B2/B3: cible attendue 0x14, PC observe=" & integer'image(to_integer(unsigned(PC)))
            severity failure;
        assert R14Value = x"0000000C"
            report "B2/B3: R14 attendu 0x0C, observe=" & integer'image(to_integer(unsigned(R14Value)))
            severity failure;
        report "B2 PASS; B3 PASS" severity note;

        -- B4: Imm24=-3, donc decalage signe de -12 a partir de PC+8.
        assert Instr = x"EBFFFFFD" and PC = x"00000014"
               and Link = '1' and PCSrc = '1'
            report "B4: BL arriere non decode"
            severity failure;
        wait until rising_edge(CLK); wait for 1 ns;
        assert PC = x"00000010" and R14Value = x"00000018"
            report "B4: cible arriere ou lien incorrect"
            severity failure;
        report "B4 PASS" severity note;

        -- Regression B ordinaire: la valeur de lien doit rester intacte.
        assert Instr = x"EA000001" and PC = x"00000010"
               and Link = '0' and PCSrc = '1'
            report "Regression B: instruction ordinaire invalide"
            severity failure;
        wait until rising_edge(CLK); wait for 1 ns;
        assert PC = x"0000001C" and R14Value = x"00000018"
            report "Regression B: R14 a ete modifie"
            severity failure;

        -- B5: BLNE est pris car Z=0 apres le reset.
        assert Instr = x"1B000001" and Link = '1'
               and PCSrc = '1' and RegWrite = '1'
            report "B5: BL conditionnel vrai non pris"
            severity failure;
        wait until rising_edge(CLK); wait for 1 ns;
        assert PC = x"00000028" and R14Value = x"00000020"
            report "B5: cible ou lien incorrect"
            severity failure;
        report "B5 PASS" severity note;

        -- B6: BLEQ est inhibe car Z=0; PC avance et LR persiste.
        assert Instr = x"0B000001" and Link = '1'
               and PCSrc = '0' and RegWrite = '0'
            report "B6: BL conditionnel faux non inhibe"
            severity failure;
        wait until rising_edge(CLK); wait for 1 ns;
        assert PC = x"0000002C" and R14Value = x"00000020"
            report "B6: PC ou preservation de R14 incorrect"
            severity failure;
        report "B6 PASS" severity note;

        -- B7: une instruction normale ecrit Rd sans detourner le write-back.
        assert Instr = x"E2800001" and ALUResult = x"00000001"
               and WriteBackData = x"00000001" and Link = '0'
            report "B7: resultat normal apres BL incorrect"
            severity failure;
        wait until rising_edge(CLK); wait for 1 ns;
        assert PC = x"00000030" and R14Value = x"00000020"
            report "B7: PC ou R14 incorrect"
            severity failure;
        report "B7 PASS" severity note;

        -- B8: STR observe la donnee normale et R14 reste intact.
        assert Instr = x"E5810000" and WriteData = x"00000001"
               and Link = '0'
            report "B8: donnee de stockage incorrecte apres BL"
            severity failure;
        wait until rising_edge(CLK); wait for 1 ns;
        assert PC = x"00000034" and R14Value = x"00000020"
            report "B8: PC ou persistance de LR incorrecte"
            severity failure;
        report "B8 PASS" severity note;
        report "Tous les tests BL B1-B8 sont passes" severity note;
        wait;
    end process;
end Behavioral;


