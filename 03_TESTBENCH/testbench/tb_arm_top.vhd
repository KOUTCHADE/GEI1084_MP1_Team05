
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity tb_arm_top is
end tb_arm_top;

architecture Behavioral of tb_arm_top is

    signal CLK       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '1';

    signal PC        : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr     : STD_LOGIC_VECTOR(31 downto 0);
    signal PCSrc     : STD_LOGIC;
    signal ALUResult : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    --------------------------------------------------
    -- Horloge : periode de 10 ns
    --------------------------------------------------
    CLK <= not CLK after CLK_PERIOD / 2;

    --------------------------------------------------
    -- Processeur ARM complet
    --------------------------------------------------
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

    --------------------------------------------------
    -- Stimulus et verification
    --------------------------------------------------
    stimulus : process

        file expected_file : text
            open read_mode is "ExpectedData.txt";

        variable L            : line;
        variable expected_ALU : STD_LOGIC_VECTOR(31 downto 0);
        variable expected_WD  : STD_LOGIC_VECTOR(31 downto 0);
        variable separator    : character;

        variable errors      : integer := 0;
        variable test_count  : integer := 0;
        variable test_ok     : boolean;
        variable expected_PC : STD_LOGIC_VECTOR(31 downto 0);

    begin

        --------------------------------------------------
        -- 1. Reset initial
        --------------------------------------------------
        reset <= '1';

        wait for 22 ns;

        reset <= '0';

        -- Stabilisation des signaux combinatoires
        wait for 1 ns;

        --------------------------------------------------
        -- 2. Verification des 20 instructions
        --------------------------------------------------
        for i in 0 to 19 loop

            test_count := test_count + 1;
            test_ok := true;

            ----------------------------------------------
            -- Lecture du fichier ExpectedData.txt
            ----------------------------------------------
            assert not endfile(expected_file)
                report "ExpectedData.txt : ligne manquante"
                severity failure;

            readline(expected_file, L);

            read(L, expected_ALU);
            read(L, separator);
            read(L, expected_WD);

            assert separator = '_'
                report "Separateur invalide dans ExpectedData.txt"
                severity failure;

            ----------------------------------------------
            -- Verification de l'adresse PC
            ----------------------------------------------
            expected_PC := std_logic_vector(
                to_unsigned(i * 4, 32)
            );

            if PC /= expected_PC then

                report "Test " &
                       integer'image(i + 1) &
                       " : PC incorrect"
                       severity error;

                errors := errors + 1;
                test_ok := false;

            end if;

            ----------------------------------------------
            -- Verification de ALUResult
            ----------------------------------------------
            if ALUResult /= expected_ALU then

                report "Test " &
                       integer'image(i + 1) &
                       " : ALUResult incorrect"
                       severity error;

                errors := errors + 1;
                test_ok := false;

            end if;

            ----------------------------------------------
            -- Verification de WriteData
            ----------------------------------------------
            if WriteData /= expected_WD then

                report "Test " &
                       integer'image(i + 1) &
                       " : WriteData incorrect"
                       severity error;

                errors := errors + 1;
                test_ok := false;

            end if;

            ----------------------------------------------
            -- Affichage du resultat du test
            ----------------------------------------------
            if test_ok then

                report "Test " &
                       integer'image(i + 1) &
                       " : Conforme"
                       severity note;

            else

                report "Test " &
                       integer'image(i + 1) &
                       " : Non conforme"
                       severity warning;

            end if;

            ----------------------------------------------
            -- Passage a l'instruction suivante
            ----------------------------------------------
            if i < 19 then
                -- Verification a 23, 33, 43, ... ns
                -- Chaque front montant intermediaire
                -- met a jour le PC.
                wait for CLK_PERIOD;
            end if;

        end loop;

        --------------------------------------------------
        -- 3. Bilan final
        --------------------------------------------------
        report "----------------------------------"
            severity note;

        report "Nombre de tests : " &
               integer'image(test_count)
               severity note;

        report "Nombre total d'erreurs : " &
               integer'image(errors)
               severity note;

        if errors = 0 then

            report "SIMULATION CONFORME : 20 tests"
                severity note;

        else

            report "SIMULATION NON CONFORME"
                severity warning;

        end if;

        report "----------------------------------"
            severity note;

        file_close(expected_file);

        wait;

    end process;

end Behavioral;
