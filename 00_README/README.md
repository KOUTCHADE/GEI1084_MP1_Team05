# GEI1084 Mini-projet 1 — Team05

Processeur ARM monocycle du Lab 4 étendu avec **CMP**, **opérande registre décalé (LSL/LSR immédiat)** et **BL**, en VHDL.

## 1. Objectif du projet

Faire évoluer le processeur monocycle du Lab 4 (GEI1084, UQTR) sans le réécrire : réutiliser l'ALU, la logique conditionnelle et le chemin de branchement existants, ajouter seulement les contrôles et blocs nécessaires, puis démontrer par des tests prédictifs (C1–C7, S1–S10, B1–B8, R1–R7) que les trois extensions fonctionnent et que le Lab 4 n'a pas régressé.

## 2. Sous-ensemble supporté

| Catégorie | Instructions | Remarques |
|---|---|---|
| Data-processing registre | ADD, SUB, AND, ORR (`Rd, Rn, Rm`) | Avec ou sans S (mise à jour NZCV) |
| Data-processing immédiat | ADD, SUB, AND, ORR (`Rd, Rn, #imm8`) | Pas de rotation de l'immédiat (comme le Lab 4) |
| **Opérande décalé (nouveau)** | ADD, SUB, AND, ORR `Rd, Rn, Rm, LSL #shamt` / `LSR #shamt` | shamt = 0 à 31, `Instr(11:7)` ; type `Instr(6:5)` : 00 = LSL, 01 = LSR ; bit 4 = 0 |
| **Comparaison (nouveau)** | CMP `Rn, Rm` / `CMP Rn, #imm8` | Soustraction, met à jour NZCV, n'écrit aucun registre |
| Mémoire | LDR, STR (`[Rn, #imm12]`) | Décalage positif seulement |
| Branchement | B | Cible = PC+8 + SignExt(imm24) × 4 |
| **Branchement avec lien (nouveau)** | BL | Même cible que B ; R14 ← PC+4 |
| Exécution conditionnelle | Les 15 conditions ARM (EQ … AL) sur toutes les instructions ci-dessus | Gating de RegWrite, MemWrite, PCSrc et de l'écriture des flags par CondEx |

## 3. Limitations explicites

* Pas de ASR, ROR, RRX ni décalage par registre (`Rm, LSL Rs`).
* `LSR #0` est traité comme « aucun décalage ». En ARM, ce codage signifie LSR #32 ; il est hors du sous-ensemble demandé.
* Le shifter ne produit aucun carry : C vient uniquement de l'ALU.
* CMP n'accepte pas d'opérande décalé : le décodeur de décalage n'agit que sur ADD, SUB, AND, ORR (`CMP Rn, Rm, LSL #n` est exécuté sans décalage).
* CMP écrit toujours NZCV (FlagW = 11) même si S = 0 ; le guide impose le codage avec S = 1.
* Pas de BX, BLX, MOV, MVN, EOR, TST, CMN, ni de LDR/STR avec décalage négatif ou registre.
* Pas d'écriture de R15 par une instruction data-processing.
* Processeur monocycle en simulation comportementale ; aucune implémentation sur carte n'a été validée.

## 4. Structure du dépôt

```
GEI1084_MP1_Team05/
├── 00_README/            README, PROJECT_SCOPE, SUBMISSION_INDEX, AI_USE_DECLARATION
├── 01_REPORT/            Team05_GE1084_MP1_FinalReport.pdf
├── 02_HDL/
│   ├── baseline_lab4/    Lab 4 d'origine (référence, non modifiée)
│   ├── final_design/     Processeur intégré Lab 4 + CMP + Shift + BL  ← design évalué
│   └── optional_extensions/  Versions de développement par extension (CMP, SHIFT, BL, BL_R14)
├── 03_TESTBENCH/
│   ├── CMP/              tb_arm_top.vhd (20 tests Lab 4 + C1–C4, C6, C7)
│   ├── SHIFT/            tb_shift.vhd + imem.vhd (S1–S10, C5)
│   ├── BL/               tb_bl.vhd + imem.vhd (B1–B8)
│   ├── testbench/        bancs unitaires du Lab 4 (condcheck, condlogic, flag_registers)
│   ├── expected_results/ExpectedResults.csv
│   └── regression/       RegressionSummary.csv, run_regression_ghdl.sh
├── 04_RESULTS/           CMP/, SHIFT/, BL/, REGRESSION/, DEBUG_CASE/ (captures et consoles)
├── 05_ARCHITECTURE/      schémas baseline_lab4, CMP, SHIFT, BL, final_integrated
├── 06_ENGINEERING_PRACTICE/  E2 à E7
├── 07_PRESENTATION/
└── 08_GRADING_EVIDENCE/
```

## 5. Outils, versions et standard VHDL

| Outil | Version | Usage |
|---|---|---|
| AMD Vivado | 2022.2 (simulateur XSim) | Simulation comportementale de référence ; captures de `04_RESULTS` |
| GHDL | 4.1.0 (backend mcode) | Régression en ligne de commande (`run_regression_ghdl.sh`) |
| Standard | **VHDL-2008 obligatoire** | `adder.vhd` utilise une syntaxe VHDL-2008 ; en VHDL-93 la compilation échoue |
| Composant cible (projet Vivado) | xc7z007sclg225-2 (réglage du Lab 4) | Aucun bitstream n'est produit pour la remise |

## 6. Compilation / build

**Vivado**

1. Créer un projet RTL vide (aucune source), composant au choix.
2. *Add Sources* → tous les fichiers de `02_HDL/final_design/`.
3. *Add Simulation Sources* → le banc voulu (voir 7). Pour SHIFT et BL, ajouter aussi le `imem.vhd` du dossier de test et **retirer** `final_design/imem.vhd` de l'ensemble de simulation (même nom d'entité).
4. Sélectionner tous les fichiers → *Source File Properties* → *Type* = **VHDL 2008**.
5. Pour le banc CMP, copier `02_HDL/baseline_lab4/ExpectedData.txt` dans le dossier de simulation (`<projet>.sim/sim_1/behav/xsim/`) ou l'ajouter comme source de simulation.

**GHDL**

```
ghdl -i --std=08 02_HDL/final_design/*.vhd <fichiers du banc>
ghdl -m --std=08 <entité du banc>
```

## 7. Simulation

| Suite | Banc (top de simulation) | Fichiers à ajouter | Durée |
|---|---|---|---|
| Lab 4 + CMP | `tb_arm_top` | `03_TESTBENCH/CMP/tb_arm_top.vhd`, `ExpectedData.txt` | 400 ns |
| SHIFT + C5 | `tb_shift` | `03_TESTBENCH/SHIFT/tb_shift.vhd`, `03_TESTBENCH/SHIFT/imem.vhd` | 300 ns |
| BL | `tb_bl` | `03_TESTBENCH/BL/tb_bl.vhd`, `03_TESTBENCH/BL/imem.vhd` | 250 ns |

Vivado : *Run Simulation* → *Run Behavioral Simulation*, puis `run 1 us` dans la console Tcl. Les résultats s'affichent dans la console (lignes `PASS`/`FAIL`, `Conforme`).

## 8. Régression

Depuis la racine du dépôt (Linux, macOS ou WSL avec GHDL installé) :

```
bash 03_TESTBENCH/regression/run_regression_ghdl.sh
```

Le script copie `final_design` dans un dossier temporaire avec chaque banc, lance les trois suites, écrit les consoles dans `04_RESULTS/REGRESSION/` et affiche `[PASS]` ou `[FAIL]` par suite. Code de sortie 0 si tout passe. Le tableau consolidé est `03_TESTBENCH/regression/RegressionSummary.csv`.

## 9. Critère de réussite attendu

```
[PASS] CMP     → « SIMULATION CONFORME : 26 tests », « Nombre total d'erreurs : 0 »
[PASS] SHIFT   → « SHIFT : cycles en echec = 0 / 27 », S1–S10 et C5 PASS
[PASS] BL      → « BL : cycles en echec = 0 / 19 », B1–B8 PASS
```

Un test est PASS seulement si le résultat architectural complet est correct (par exemple, B6 exige PC suivant = PC+4 **et** R14 inchangé).

## 10. Références et provenance

* S. Harris, D. Harris, *Digital Design and Computer Architecture, ARM Edition*, Morgan Kaufmann, 2015 — architecture monocycle de référence.
* ARM, *ARM Architecture Reference Manual (ARMv7-A/R)* — codage des instructions data-processing, décalages, BL.
* Guide du mini-projet 1 GEI1084 (A26) et Lab 4 du cours.
* Provenance et licence de chaque fichier : `06_ENGINEERING_PRACTICE/E4_Provenance_License/THIRD_PARTY_AND_PROVENANCE.md`.
* Utilisation de l'IA : `00_README/AI_USE_DECLARATION.md`.

## Mode de remise

Remise à la fois de l'archive complète `GEI1084_MP1_Team05.zip` et de l'URL du dépôt Git. Les deux correspondent au même commit / tag final indiqué dans `SUBMISSION_INDEX.md`.
