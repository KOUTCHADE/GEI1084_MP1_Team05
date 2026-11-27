# Rapport final — sections architecture, implémentation et validation (brouillon)

Équipe 05 — GEI1084 MP1. Sections à insérer dans `Team05_GE1084_MP1_FinalReport.pdf`. Elles couvrent E1.1, E1.2, E1.4 et répondent aux questions obligatoires de T1. Figures : `05_ARCHITECTURE/*/*.png` (convention : gris = inchangé, orange = modifié, bleu = nouveau).

## 1. Architectures (E1.1)

| Figure | Fichier | Ce qu'elle montre |
|---|---|---|
| 1 | `05_ARCHITECTURE/baseline_lab4/Lab4_baseline.png` | Référence Lab 4 |
| 2 | `05_ARCHITECTURE/CMP/CMP_architecture.png` | Réutilisation de l'ALU, écriture des flags, suppression d'écriture, interaction avec CondEx |
| 3 | `05_ARCHITECTURE/SHIFT/SHIFT_architecture.png` | RD2 → Shifter → ALUSrc → ALU ; chemin ExtImm inchangé |
| 4 | `05_ARCHITECTURE/BL/BL_architecture.png` | PC+8 pour la cible, PC+4 pour R14, mux A3/WD3, contrôle conditionnel |
| 5 | `05_ARCHITECTURE/final_integrated/Final_integrated.png` | Processeur final complet |

## 2. Implémentation (E1.2)

### 2.1 CMP

1. **Sémantique** : `CMP Rn, Op2` calcule Rn − Op2, met à jour NZCV, n'écrit aucun registre ; soumis à la condition.
2. **Modules touchés** : `main_decoder.vhd`, `alu_decoder.vhd` ; `arm_top.vhd` (Opcode vers le décodeur, sorties de diagnostic pour les tests).
3. **Contrôles** : aucun signal nouveau. Valeurs différentes : `RegW = 0` et `FlagW = 11` pour Funct(4:1) = 1010.
4. **Datapath** : aucun ajout. L'opération SUB existante (`ALUControl = 01`) est réutilisée.
5. **Décision HDL** : la suppression d'écriture est faite dans le décodeur principal (`if Opcode /= "1010" then RegW <= '1'`), avant `condlogic`, pour que `RegWrite = RegW · CondEx` soit toujours 0 pour CMP, quelle que soit la condition.
6. **Inchangés** : ALU, `condlogic`, `flag_registers`, `condcheck`, datapath, banc de registres.
7. **Pourquoi ça marche** : l'ALU calcule déjà la soustraction et ses flags ; `FlagW = 11` les mémorise si `CondEx = 1` ; `RegW = 0` empêche le résultat de devenir architectural.

Réponses aux questions T1.1 : (1) SUB (`ALUControl = 01`). (2) N, Z, C, V. (3) CMP n'a pas de destination : écrire Rd détruirait un registre (C6). (4) `RegW` = 0 au lieu de 1, `FlagW` = 11 imposé. (5) Condition fausse : `FlagWrite = FlagW · CondEx = 00`, les flags gardent leur valeur. (6) ALU, cond logic, flags, datapath, mémoire, PC.

```vhdl
-- main_decoder.vhd : CMP n'écrit pas de registre
if Opcode /= "1010" then RegW <= '1'; else RegW <= '0'; end if;
-- alu_decoder.vhd : CMP = SUB + écriture de NZCV
when "1010" => ALUControl <= "01"; FlagW <= "11";
```

### 2.2 Shift (LSL / LSR immédiat)

1. **Sémantique** : `Op Rd, Rn, Rm, LSL|LSR #shamt` pour ADD, SUB, AND, ORR ; le deuxième opérande est Rm décalé.
2. **Modules touchés** : `datapath.vhd` (câblage) ; nouveaux : `shift_decoder.vhd`, `shifter.vhd`.
3. **Contrôles** : `ShiftControl(1:0)` (00 = LSL, 01 = LSR), `ShiftAmount(4:0)`, `ShiftEnable` (calculé, non utilisé).
4. **Datapath** : shifter combinatoire entre RD2 et l'entrée 0 du mux ALUSrc.
5. **Décisions HDL** : le décodage lit directement `Instr` (bits 27:26 = 00, 25 = 0, 4 = 0, opcode ∈ {ADD, SUB, AND, ORR}) ; sinon il sort LSL #0, ce qui laisse RD2 intact pour toutes les autres instructions. `shift_right` sur `unsigned` garantit le remplissage par zéros.
6. **Inchangés** : ALU, chemin ExtImm, WriteData (STR utilise RD2 non décalé), décodeurs principaux, cond logic.
7. **Pourquoi ça marche** : l'ALU reçoit déjà l'opérande sous sa forme finale ; décaler par 0 est l'identité, donc les anciennes instructions registre donnent le même résultat (S9).

Réponses T1.2 : (1) Entre RD2 et le mux ALUSrc. (2) Seul l'opérande registre est transformé ; l'immédiat n'est pas touché et aucune autre logique ne change. (3) ExtImm arrive sur l'autre entrée du mux. (4) Rm = Instr(3:0). (5) shamt = Instr(11:7). (6) Instr(6:5). (7) LSL #0 rend RD2 inchangé. (8) `shift_right(unsigned(RD2), n)`. (9) Le guide ne demande pas d'opérations à décalage qui mettent à jour C depuis le shifter ; C vient de l'ALU. (10) Instructions registre non décalées (S9), chemin immédiat (S10), LDR/STR (R4, R5), régression Lab 4.

```vhdl
-- datapath.vhd
SrcB_internal <= ShiftedRD2_internal when ALUSrc = '0' else ExtImm_internal;
-- shifter.vhd
when "01" => ShiftedRD2 <= std_logic_vector(shift_right(unsigned(RD2), to_integer(unsigned(shamt))));
```

### 2.3 BL

1. **Sémantique** : si CondEx = 1 : PC ← PC+8 + 4·SignExt(imm24) et R14 ← PC+4 ; sinon ni l'un ni l'autre.
2. **Modules touchés** : `main_decoder.vhd`, `datapath.vhd`, `arm_top.vhd` (signal BL) ; `register_file.vhd` et `extend.vhd` corrigés (chemin B).
3. **Contrôles** : nouveau signal `BL` (Op = 10 et Instr(24) = 1) ; `RegW = 1` pour BL.
4. **Datapath** : mux A3 (Instr(15:12) ou 14) ; mux WD3 (Result ou PCPlus4) ; PCPlus4 amené au datapath.
5. **Décision HDL** : les deux mux dépendent de `BL` seul, mais l'écriture passe par `RegWrite = RegW · CondEx`. Aucun chemin d'écriture séparé : c'est ce qui garantit B6 (voir E3).
6. **Inchangés** : calcul de la cible (ALU, R15 = PC+8, ExtImm), mux PC, cond logic, ALU decoder.
7. **Pourquoi ça marche** : BL est un B qui écrit en plus un registre ; on réutilise la cible du B et le mécanisme d'écriture conditionnelle de toute instruction.

Réponses T1.3 : (1) Cible = ALU(R15, ExtImm) avec PCSrc. (2) Dans l'ARM du cours, lire PC donne PC+8 (deux instructions en avance). (3) L'adresse de retour est l'instruction qui suit le BL. (4) Mux A3 commandé par BL. (5) Mux WD3 commandé par BL. (6) Le bit L = Instr(24). (7) Saut et écriture de R14. (8) Ni saut ni écriture. (9) Pour B, L = 0, donc BL = 0 et RegW = 0 (B1). (10) Chemin de la cible, ALU, mémoire, cond logic.

```vhdl
-- datapath.vhd
A3_internal  <= "1110"  when BL = '1' else Instr(15 downto 12);
WD3_internal <= PCPlus4 when BL = '1' else Result_internal;
```

### 2.4 Tableau d'impact sur les modules

| Module | Rôle Lab 4 | Action MP1 | CMP | Shift | BL |
|---|---|---|---|---|---|
| ALU (`alu32`, `alu_arithmetic`) | existant | inchangé | SUB réutilisé | reçoit ShiftedRD2 | calcule la cible |
| ALU decoder | existant | modifié | 1010 → SUB, FlagW = 11 | — | — |
| Main decoder | existant | modifié | RegW = 0 pour 1010 | — | signal BL, RegW = 1 |
| Datapath | existant | modifié | — | shifter avant mux ALUSrc | mux A3, mux WD3, entrée PCPlus4 |
| Register file | existant | modifié | — | — | lecture R15 = PC+8 corrigée |
| Extend | existant | modifié | — | — | extension de signe de imm24 corrigée |
| Shift decoder | absent | nouveau | — | décode shamt / type | — |
| Shifter | absent | nouveau | — | LSL / LSR | — |
| Condition logic (`condlogic`, `condcheck`, `flag_registers`) | existant | inchangé fonctionnellement (seule une sortie de diagnostic `Flags_dbg` est ajoutée à `condlogic`) | gating des flags | — | gating de l'écriture R14 |
| PC logic (`pc_path`, `pc_reg`, `adder`) | existant | inchangé | — | — | PCPlus4 déjà produit, réutilisé |
| Top (`arm_top`) | existant | modifié (câblage) | Opcode vers main decoder ; sorties de diagnostic | — | signal BL et PCPlus4 vers le datapath |
| Data memory, imem | existant | inchangé | — | — | — |

## 3. Validation (E1.4)

Le tableau consolidé (ID, objectif, attendu, observé, PASS/FAIL, preuve) est `03_TESTBENCH/expected_results/ExpectedResults.csv` ; le reproduire dans le rapport. Résultat : 32/32 PASS (C1–C7, S1–S10, B1–B8, R1–R7).

Formes d'onde à insérer, chacune avec ID, signaux lisibles, fenêtre et légende de conclusion :

| ID | Fichier | Légende proposée |
|---|---|---|
| C6 | `04_RESULTS/CMP/C6_Chronogramme.png` | « C6 : pendant CMP R1, R2 (PC = 0x70), RegWrite = 0 et R3 reste 42 ; seuls les flags changent. » |
| S5 | `04_RESULTS/SHIFT/Vivado_SHIFT_S1-S10_C5.png` | « S5 : 0x80000000 LSR #1 = 0x40000000, remplissage par 0 (pas 0xC0000000). » |
| B6 | `04_RESULTS/BL/BL_B6.png` | « B6 : BLNE avec Z = 1 : PCSrc = 0, RegWrite = 0 ; A3 = 14 et WD3 = 0x18 sont préparés mais non écrits ; R14 relu = 0xAB. » |
| Diagnostic | `04_RESULTS/DEBUG_CASE/T1_waveform_avant_correction.png` | « Défaut du chemin B : R15 lu à 0 et imm24 non étendu en signe ; cible 0x04 au lieu de 0x0C. » |
