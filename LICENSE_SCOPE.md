# Portée de la licence — Équipe 05

Le fichier `LICENSE` (MIT) s'applique **uniquement** à ce qui est listé ci-dessous. Tout le reste conserve son statut d'origine (voir `06_ENGINEERING_PRACTICE/E4_Provenance_License/THIRD_PARTY_AND_PROVENANCE.md`).

## 1. Fichiers entièrement écrits par l'équipe — MIT

| Fichier |
|---|
| `02_HDL/final_design/shift_decoder.vhd` |
| `02_HDL/final_design/shifter.vhd` |
| `02_HDL/optional_extensions/SHIFT/shift_decoder.vhd`, `shifter.vhd` |
| `03_TESTBENCH/BL/tb_bl.vhd` |
| `03_TESTBENCH/SHIFT/tb_shift.vhd` |
| `03_TESTBENCH/tb_t1_branch.vhd` |
| `03_TESTBENCH/expected_results/ExpectedResults.csv`, `03_TESTBENCH/regression/RegressionSummary.csv` (contenu ; le gabarit de colonnes vient du cours) |

## 2. Fichiers mixtes — seules les modifications de l'équipe sont sous MIT

Ces fichiers partent du Lab 4 du cours. La partie d'origine reste au cours ; seules les lignes ajoutées ou modifiées par l'équipe (le *diff* par rapport à `02_HDL/baseline_lab4/`) sont couvertes.

| Fichier (dans `02_HDL/final_design/`, sauf mention) | Modification de l'équipe |
|---|---|
| `main_decoder.vhd` | CMP (RegW = 0 pour 1010), BL (signal BL, bit L) |
| `alu_decoder.vhd` | CMP (FlagW = 11 pour 1010) |
| `condlogic.vhd` | CMP |
| `datapath.vhd` | BL (sélection de R14 et de PC + 4), SHIFT (insertion du shifter) |
| `register_file.vhd` | Lecture de R15 = PC + 8 |
| `extend.vhd` | Extension de signe de l'immédiat de branchement |
| `arm_top.vhd` | Connexion des nouveaux signaux |
| `imem.vhd` | Programmes de test de l'équipe |
| `03_TESTBENCH/CMP/tb_arm_top.vhd` | Tests C1–C7 ajoutés au banc du Lab 4 |

Les mêmes règles s'appliquent aux copies de ces fichiers dans `02_HDL/optional_extensions/` et `03_TESTBENCH/`.

## 3. Documentation de l'équipe — CC BY 4.0

`00_README/` (sauf le gabarit fourni par le cours), `01_REPORT/`, `06_ENGINEERING_PRACTICE/`, `07_PRESENTATION/`, `08_GRADING_EVIDENCE/`. Les schémas de `05_ARCHITECTURE/` sont des œuvres dérivées du schéma du manuel : seuls nos ajouts sont couverts.

## 4. Non couvert

* `02_HDL/baseline_lab4/` : Lab 4 du cours GEI1084.
* Programme de test du Lab 4 (`Instructions.txt`, `ExpectedData.txt`, `imem.vhd` d'origine) et bancs `tb_condcheck`, `tb_condlogic`, `tb_flag_registers`, `tb_arm_top` d'origine.
* Gabarits et guide fournis par l'enseignant.
* Schéma monocycle d'origine (Harris & Harris, *Digital Design and Computer Architecture, ARM Edition*).
