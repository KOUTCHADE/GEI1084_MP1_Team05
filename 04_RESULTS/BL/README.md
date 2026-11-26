# Résultats de validation — BL (B1–B8)

| Élément | Valeur |
|---|---|
| Matériel testé | `02_HDL/optional_extensions/BL/` + `alu_decoder` et `condlogic` de CMP + autres fichiers de `baseline_lab4` |
| Programme de test | `03_TESTBENCH/BL/imem.vhd` (27 instructions, adresses 0x00 à 0x68) |
| Testbench | `03_TESTBENCH/BL/tb_bl.vhd` |
| Outil | Vivado 2017.4, simulation comportementale, VHDL-2008 |
| Date | 2026-11-23 |

## 1. Méthode

- Le testbench vérifie à chaque front montant, pendant 19 cycles : `PC`, `Instr`, `ALUResult`, `PCSrc` et `RegWrite` (sortie `RegWrite_dbg`), comparés aux valeurs attendues calculées avant simulation.
- **Observation de R14 :** R14 n'est pas une sortie du processeur. Il est relu par l'instruction `ADD R5, R14, #0` : sa valeur apparaît alors dans `ALUResult`.
- **Valeur initiale de R14 :** le guide propose R14 = 0x12345678 à titre d'exemple. Le processeur ne charge que des immédiats de 8 bits et l'extension Shift n'était pas intégrée sur cette branche ; la valeur distinctive utilisée est **R14 = 0x000000AB** (`ADD R14, R0, #0xAB`). Le critère des tests est inchangé.
- **Flags :** `CMP R0, R0` donne Z = 1 (Flags = 0110). EQ est alors vrai et NE est faux.

## 2. Programme de test

| Adresse | Code | Instruction | Rôle |
|---|---|---|---|
| 0x00 | E280E0AB | ADD R14, R0, #0xAB | R14 = 0xAB |
| 0x04 | EA000000 | B (cible 0x0C) | B1 |
| 0x08 | E28010EE | ADD R1, R0, #0xEE | Ne doit pas s'exécuter |
| 0x0C | E28E5000 | ADD R5, R14, #0 | Relecture de R14 (B1) |
| 0x10 | E1500000 | CMP R0, R0 | Z = 1 |
| 0x14 | 1B000004 | BLNE (cible 0x2C) | B6 : condition fausse |
| 0x18 | E28E5000 | ADD R5, R14, #0 | Relecture de R14 (B6) |
| 0x1C | E2802002 | ADD R2, R0, #2 | Remplissage |
| 0x20 | 0B000002 | BLEQ (cible 0x30) | B3, B5 : condition vraie |
| 0x24–0x2C | E28010EE | ADD R1, R0, #0xEE (×3) | Ne doivent pas s'exécuter |
| 0x30 | E28E5000 | ADD R5, R14, #0 | Relecture de R14 (B3, B5) |
| 0x34 | E2806066 | ADD R6, R0, #0x66 | B7 : écriture normale |
| 0x38 | E2867000 | ADD R7, R6, #0 | Relecture de R6 (B7) |
| 0x3C | E28E5000 | ADD R5, R14, #0 | Relecture de R14 (B8) |
| 0x40 | EB000001 | BL (cible 0x4C) | B2 : BL AL vers l'avant |
| 0x44, 0x48 | E28010EE | ADD R1, R0, #0xEE | Ne doivent pas s'exécuter |
| 0x4C | E28E5000 | ADD R5, R14, #0 | Relecture de R14 (B2) |
| 0x50 | EA000001 | B (cible 0x5C) | Saut vers le BL arrière |
| 0x54 | E28E5000 | ADD R5, R14, #0 | Cible du BL arrière, relecture de R14 (B4) |
| 0x58 | EA000002 | B (cible 0x68) | Vers la fin |
| 0x5C | EBFFFFFC | BL (cible 0x54) | B4 : BL vers l'arrière |
| 0x60, 0x64 | E28010EE | ADD R1, R0, #0xEE | Ne doivent pas s'exécuter |
| 0x68 | EAFFFFFE | B (sur elle-même) | Fin |

## 3. Tests B1–B8

| Test | Objectif | État initial | Instruction / séquence | Résultat attendu | Résultat observé | Statut | Preuve |
|---|---|---|---|---|---|---|---|
| B1 | Un B ordinaire saute et laisse R14 inchangé | R14 = 0xAB | `B` à 0x04, puis `ADD R5, R14, #0` à 0x0C | Cible 0x0C, RegWrite = 0, R14 = 0xAB | ALUResult = 0x0C, PCSrc = 1, RegWrite = 0 ; PC suivant 0x0C ; relecture R14 = 0xAB | PASS | Console, cycles 2–3 |
| B2 | BL vers l'avant | R14 = 0x24 | `BL` (AL) à 0x40 : PC + 4 = 0x44, PC + 8 = 0x48, offset +1 → +4 | Cible 0x4C, R14 = 0x44 | ALUResult = 0x4C, PCSrc = 1, RegWrite = 1 ; relecture R14 = 0x44 | PASS | Console, cycles 13–14 |
| B3 | Distinguer PC + 4 et PC + 8 | BL à l'adresse 0x20 | `BLEQ` à 0x20 | Cible = 0x28 + 8 = 0x30 ; R14 = 0x24 | SrcA = 0x28, ALUResult = 0x30, WD3 = 0x24 ; relecture R14 = 0x24 | PASS | `BL_B3_B5.png` ; console, cycles 8–9 |
| B4 | BL vers l'arrière | R14 = 0x44 | `BL` à 0x5C, imm24 = 0xFFFFFC (−4) → SignExt = 0xFFFFFFFC → ×4 = 0xFFFFFFF0 (−16) | Cible = 0x64 − 16 = 0x54 ; R14 = 0x60 | ALUResult = 0x54, PCSrc = 1 ; PC suivant 0x54 ; relecture R14 = 0x60 | PASS | Console, cycles 16–17 |
| B5 | BL conditionnel, condition vraie | Z = 1, R14 = 0xAB | `BLEQ` à 0x20 | Saut à 0x30 **et** R14 = 0x24 | PCSrc = 1, RegWrite = 1 ; relecture R14 = 0x24 | PASS | `BL_B3_B5.png` ; console, cycles 8–9 |
| B6 | BL conditionnel, condition fausse | Z = 1, R14 = 0xAB | `BLNE` à 0x14 | PC suivant = 0x18 ; R14 = 0xAB | PCSrc = 0, RegWrite = 0 (A3 = 14 et WD3 = 0x18 préparés mais non écrits) ; PC suivant 0x18 ; relecture R14 = 0xAB | PASS | `BL_B6.png` ; console, cycles 5–6 |
| B7 | Écriture normale après BL | R14 = 0x24 | `ADD R6, R0, #0x66`, puis `ADD R7, R6, #0` | R6 = 0x66 (A3 = 6, pas 14) | A3 = 6, WD3 = 0x66 ; relecture R6 = 0x66 | PASS | Console, cycles 10–11 |
| B8 | Persistance de LR | R14 = 0x24 | Instructions B7, puis `ADD R5, R14, #0` | R14 = 0x24 | Relecture R14 = 0x24 | PASS | Console, cycle 12 |

**Bilan :** 19/19 cycles conformes — « BL : SIMULATION CONFORME (B1-B8) » (`BL_console_B1-B8.txt`).

Réutilisation : B3 et B5 utilisent le même BL (adresse 0x20) ; B1 sert aussi de test R7 (B ordinaire).

## 4. Régression avec BL

Programme et testbench CMP (`03_TESTBENCH/CMP/tb_arm_top.vhd`, `optional_extensions/CMP/imem.vhd`) exécutés avec le matériel BL :

**« Nombre total d'erreurs : 0 — SIMULATION CONFORME : 26 tests »** (20 tests du Lab 4 + C1, C2, C3, C4, C6, C7).

Preuves : `REG_BL_console_26tests.txt`, `REG_BL_waveform_26tests.png`.

## 5. Sensibilité du testbench (vérification complémentaire, GHDL)

Pour vérifier que le testbench détecte bien les défauts, deux erreurs ont été introduites volontairement dans une copie du matériel :

| Défaut introduit | Résultat |
|---|---|
| `RegWrite <= RegW` (écriture non conditionnée par CondEx) | **Seul B6 échoue** : R14 est écrasé par 0x18 au lieu de rester 0xAB |
| `A3_internal` jamais égal à 14 | 6 tests échouent (B2, B3, B4, B5, B7, B8) |

Le premier défaut correspond au scénario du défaut publié (E3).

## 6. Fichiers

| Fichier | Contenu |
|---|---|
| `BL_console_B1-B8.txt` | Console Vivado, 19 cycles et bilan B1–B8 |
| `BL_waveform_B1-B8.png` | Vue d'ensemble (0–205 ns) |
| `BL_B6.png` | Curseur à 60 ns : BLNE à 0x14, condition fausse |
| `BL_B3_B5.png` | Curseur à 90 ns : BLEQ à 0x20, PC + 8 pour la cible, PC + 4 pour R14 |
| `REG_BL_console_26tests.txt` | Régression Lab 4 + CMP avec BL (26/26) |
| `REG_BL_waveform_26tests.png` | Forme d'onde de la régression |
