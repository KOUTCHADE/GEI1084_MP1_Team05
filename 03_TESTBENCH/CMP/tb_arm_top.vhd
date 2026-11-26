
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
    -- Signaux de diagnostic CMP
    signal ALUFlags_dbg : STD_LOGIC_VECTOR(3 downto 0);
    signal FlagW_dbg    : STD_LOGIC_VECTOR(1 downto 0);
    signal RegWrite_dbg : STD_LOGIC;
    signal Flags_dbg : STD_LOGIC_VECTOR(3 downto 0);
    
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
            ALUResult    => ALUResult,
            WriteData    => WriteData,
            ALUFlags_dbg => ALUFlags_dbg,
            FlagW_dbg    => FlagW_dbg,
            RegWrite_dbg => RegWrite_dbg,
            Flags_dbg    => Flags_dbg
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
-- Test C1 : CMP R2, R2
--------------------------------------------------
wait for CLK_PERIOD;

test_count := test_count + 1;
test_ok := true;

if PC /= x"00000050" then
    report "C1 : PC incorrect" severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if Instr /= x"E1520002" then
    report "C1 : instruction CMP incorrecte"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if ALUResult /= x"00000000" then
    report "C1 : ALUResult incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;


-- Verification des indicateurs NZCV
if ALUFlags_dbg /= "0110" then
    report "C1 : ALUFlags incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Verification de l'autorisation des indicateurs
if FlagW_dbg /= "11" then
    report "C1 : FlagW incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Verification de l'absence d'ecriture
if RegWrite_dbg /= '0' then
    report "C1 : RegWrite incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;


-- Attendre le front montant suivant (225 ns)
wait until rising_edge(CLK);
wait for 1 ns;

-- Verification des indicateurs memorises
if Flags_dbg /= "0110" then
    report "C1 : indicateurs memorises incorrects"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;


if test_ok then
    report "C1 : Conforme" severity note;
else
    report "C1 : Non conforme" severity warning;
end if;



--------------------------------------------------
-- Test C2 : CMP R1, R2 avec 9 - 4 = 5
--------------------------------------------------

-- Apres C1, nous sommes a 226 ns.
-- Les instructions suivantes sont :
-- PC = 0x54 : SUB R1, R2, #1
-- PC = 0x58 : SUB R2, R2, #6
-- PC = 0x5C : CMP R1, R2

--------------------------------------------------
-- C2 : Preparation de R1 = 9
--------------------------------------------------
wait for 7 ns;  -- 233 ns : PC = 0x54

if PC /= x"00000054" then
    report "C2 : PC incorrect pour SUB R1"
        severity error;
    errors := errors + 1;
end if;

if Instr /= x"E2421001" then
    report "C2 : instruction SUB R1 incorrecte"
        severity error;
    errors := errors + 1;
end if;

if ALUResult /= x"00000009" then
    report "C2 : initialisation R1 incorrecte"
        severity error;
    errors := errors + 1;
end if;

--------------------------------------------------
-- C2 : Preparation de R2 = 4
--------------------------------------------------
wait for CLK_PERIOD; -- 243 ns : PC = 0x58

if PC /= x"00000058" then
    report "C2 : PC incorrect pour SUB R2"
        severity error;
    errors := errors + 1;
end if;

if Instr /= x"E2422006" then
    report "C2 : instruction SUB R2 incorrecte"
        severity error;
    errors := errors + 1;
end if;

if ALUResult /= x"00000004" then
    report "C2 : initialisation R2 incorrecte"
        severity error;
    errors := errors + 1;
end if;

--------------------------------------------------
-- C2 : Verification de CMP R1, R2
--------------------------------------------------
wait for CLK_PERIOD; -- 253 ns : PC = 0x5C

test_count := test_count + 1;
test_ok := true;

if PC /= x"0000005C" then
    report "C2 : PC incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if Instr /= x"E1510002" then
    report "C2 : instruction CMP incorrecte"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if ALUResult /= x"00000005" then
    report "C2 : ALUResult incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Indicateurs NZCV attendus : 0010
if ALUFlags_dbg /= "0010" then
    report "C2 : ALUFlags incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if FlagW_dbg /= "11" then
    report "C2 : FlagW incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if RegWrite_dbg /= '0' then
    report "C2 : RegWrite incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Verification des indicateurs memorises
--------------------------------------------------
wait until rising_edge(CLK); -- 255 ns
wait for 1 ns;

if Flags_dbg /= "0010" then
    report "C2 : indicateurs memorises incorrects"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Resultat du test C2
--------------------------------------------------
if test_ok then
    report "C2 : Conforme" severity note;
else
    report "C2 : Non conforme" severity warning;
end if;


--------------------------------------------------
-- Test C3 : resultat negatif (4 - 9 = -5)
--------------------------------------------------

-- Apres C2, nous sommes a 256 ns.
-- Le PC est deja a 0x60.
-- On verifie donc C3 immediatement.

test_count := test_count + 1;
test_ok := true;


--------------------------------------------------
-- Verification de l'adresse PC
--------------------------------------------------
if PC /= x"00000060" then
    report "C3 : PC incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Verification de l'instruction CMP
--------------------------------------------------
if Instr /= x"E1520001" then
    report "C3 : instruction CMP incorrecte"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Verification du resultat de l'ALU
--------------------------------------------------
if ALUResult /= x"FFFFFFFB" then
    report "C3 : ALUResult incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Verification des indicateurs NZCV
--------------------------------------------------
if ALUFlags_dbg /= "1000" then
    report "C3 : ALUFlags incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Verification de FlagW
--------------------------------------------------
if FlagW_dbg /= "11" then
    report "C3 : FlagW incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Verification de l'absence d'ecriture
--------------------------------------------------
if RegWrite_dbg /= '0' then
    report "C3 : RegWrite incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Verification des indicateurs memorises
--------------------------------------------------
wait until rising_edge(CLK);
wait for 1 ns;

if Flags_dbg /= "1000" then
    report "C3 : indicateurs memorises incorrects"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- Resultat du test C3
--------------------------------------------------
if test_ok then
    report "C3 : Conforme" severity note;
else
    report "C3 : Non conforme" severity warning;
end if;


--------------------------------------------------
-- Test C4 : Carry/Borrow
-- R2 = 4
-- SUB R5, R2, #5  => R5 = 0xFFFFFFFF
-- CMP R5, R2     => 0xFFFFFFFB
-- NZCV attendu   => 1010
--------------------------------------------------

-- Apres C3 : 266 ns, PC = 0x64
-- Verification de la preparation de R5

if PC /= x"00000064" then
    report "C4 : PC incorrect pour SUB R5"
        severity error;
    errors := errors + 1;
end if;

if Instr /= x"E2425005" then
    report "C4 : instruction SUB incorrecte"
        severity error;
    errors := errors + 1;
end if;

if ALUResult /= x"FFFFFFFF" then
    report "C4 : preparation R5 incorrecte"
        severity error;
    errors := errors + 1;
end if;

-- Front montant a 275 ns : ecriture de R5
-- Verification de CMP a 276 ns

wait for CLK_PERIOD;

test_count := test_count + 1;
test_ok := true;

if PC /= x"00000068" then
    report "C4 : PC incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if Instr /= x"E1550002" then
    report "C4 : instruction CMP incorrecte"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if ALUResult /= x"FFFFFFFB" then
    report "C4 : ALUResult incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if ALUFlags_dbg /= "1010" then
    report "C4 : ALUFlags incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if FlagW_dbg /= "11" then
    report "C4 : FlagW incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if RegWrite_dbg /= '0' then
    report "C4 : RegWrite incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Front montant a 285 ns
-- Verification des indicateurs memorises

wait until rising_edge(CLK);
wait for 1 ns;

if Flags_dbg /= "1010" then
    report "C4 : indicateurs memorises incorrects"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if test_ok then
    report "C4 : Conforme" severity note;
else
    report "C4 : Non conforme" severity warning;
end if;

--------------------------------------------------
-- Test C6 : CMP ne doit pas ecrire de registre
-- PC = 0x70 : CMP R1, R2
--------------------------------------------------

-- Apres C4 : 286 ns, PC = 0x6C
-- ADD R3, R0, #42 est execute avant CMP

wait for CLK_PERIOD;  -- 296 ns : PC = 0x70

test_count := test_count + 1;
test_ok := true;

-- Verification du PC
if PC /= x"00000070" then
    report "C6 : PC incorrect" severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Verification de l'instruction CMP
if Instr /= x"E1510002" then
    report "C6 : instruction CMP incorrecte"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Verification de la soustraction interne
if ALUResult /= x"00000005" then
    report "C6 : ALUResult incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Verification des indicateurs
if ALUFlags_dbg /= "0010" then
    report "C6 : ALUFlags incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if FlagW_dbg /= "11" then
    report "C6 : FlagW incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- CMP ne doit pas ecrire dans le banc de registres
if RegWrite_dbg /= '0' then
    report "C6 : RegWrite incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Attendre le front montant executant CMP
wait until rising_edge(CLK);
wait for 1 ns;

-- Verification des indicateurs memorises
if Flags_dbg /= "0010" then
    report "C6 : indicateurs memorises incorrects"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Resultat du test
if test_ok then
    report "C6 : Conforme" severity note;
else
    report "C6 : Non conforme" severity warning;
end if;


--------------------------------------------------
-- Test C7 : les flags CMP commandent
-- une instruction conditionnelle suivante
--------------------------------------------------

-- Apres C6 : 306 ns, PC = 0x74
-- R1 = 9, R2 = 4, R3 = 42

test_count := test_count + 1;
test_ok := true;

--------------------------------------------------
-- C7.1 : CMP R1, R2
-- PC = 0x74, NZCV attendu = 0010
--------------------------------------------------

if PC /= x"00000074" then
    report "C7 : PC incorrect pour CMP"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if Instr /= x"E1510002" then
    report "C7 : instruction CMP incorrecte"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if ALUResult /= x"00000005" then
    report "C7 : resultat CMP incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if ALUFlags_dbg /= "0010" then
    report "C7 : ALUFlags CMP incorrects"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if FlagW_dbg /= "11" then
    report "C7 : FlagW CMP incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if RegWrite_dbg /= '0' then
    report "C7 : CMP ne doit pas ecrire"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Front montant a 315 ns : memorisation des flags
wait until rising_edge(CLK);
wait for 1 ns;

if Flags_dbg /= "0010" then
    report "C7 : flags CMP non memorises"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

--------------------------------------------------
-- C7.2 : ADDEQ R3, R3, #1
-- PC = 0x78
-- Z = 0 : condition EQ fausse
--------------------------------------------------

if PC /= x"00000078" then
    report "C7 : PC incorrect pour ADDEQ"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if Instr /= x"02833001" then
    report "C7 : instruction ADDEQ incorrecte"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if RegWrite_dbg /= '0' then
    report "C7 : ADDEQ executee malgre Z=0"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Front montant a 325 ns : ADDEQ doit etre ignoree
wait until rising_edge(CLK);
wait for 1 ns;

--------------------------------------------------
-- C7.3 : ADDNE R3, R3, #1
-- PC = 0x7C
-- Z = 0 : condition NE vraie
--------------------------------------------------

if PC /= x"0000007C" then
    report "C7 : PC incorrect pour ADDNE"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if Instr /= x"12833001" then
    report "C7 : instruction ADDNE incorrecte"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- L'ALU doit calculer 42 + 1 = 43.
-- Cela verifie aussi que ADDEQ n'a pas modifie R3.
if ALUResult /= x"0000002B" then
    report "C7 : resultat ADDNE incorrect"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if Flags_dbg /= "0010" then
    report "C7 : flags modifies incorrectement"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

if RegWrite_dbg /= '1' then
    report "C7 : ADDNE non autorisee avec Z=0"
        severity error;
    errors := errors + 1;
    test_ok := false;
end if;

-- Front montant a 335 ns : ecriture de R3 = 43
wait until rising_edge(CLK);
wait for 1 ns;

--------------------------------------------------
-- Resultat du test C7
--------------------------------------------------

if test_ok then
    report "C7 : Conforme" severity note;
else
    report "C7 : Non conforme" severity warning;
end if;


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

            report "SIMULATION CONFORME : " &
               integer'image(test_count) & " tests"
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
