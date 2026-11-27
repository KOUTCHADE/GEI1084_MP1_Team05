# Carte des preuves — Équipe 05

GEI1084 – Mini-projet 1. Les sections du rapport renvoient à `01_REPORT/Team05_GE1084_MP1_FinalReport.pdf` ; les chemins sont relatifs à la racine `GEI1084_MP1_Team05/`.

| Critère | Preuve | Section du rapport | Chemin fichier / dépôt |
|---|---|---|---|
| T1.1 | CMP : architecture + HDL | §3 CMP | `05_ARCHITECTURE/CMP/CMP_architecture.png` ; `02_HDL/final_design/main_decoder.vhd`, `alu_decoder.vhd`, `condlogic.vhd` ; `02_HDL/optional_extensions/CMP/` |
| T1.2 | Shift : architecture + HDL | §4 Shift | `05_ARCHITECTURE/SHIFT/SHIFT_architecture.png` ; `02_HDL/final_design/shift_decoder.vhd`, `shifter.vhd`, `datapath.vhd` ; `02_HDL/optional_extensions/SHIFT/` |
| T1.3 | BL : architecture + HDL | §5 BL | `05_ARCHITECTURE/BL/BL_architecture.png` ; `02_HDL/final_design/main_decoder.vhd`, `datapath.vhd`, `register_file.vhd`, `extend.vhd`, `arm_top.vhd` ; `02_HDL/optional_extensions/BL/README.md` |
| T1.4 | Architecture intégrée | §6 Processeur intégré | `05_ARCHITECTURE/final_integrated/Final_integrated.png` ; `02_HDL/final_design/` |
| T2.1 | Tests C1–C7 | §3 et §7 | `03_TESTBENCH/CMP/tb_arm_top.vhd` ; `04_RESULTS/CMP/` (C1–C4, C6, C7 : `Cx_Chronogramme.png`, `Cx_Testbench_Console.png` ; `Vivado_Lab4_CMP_26sur26_avecSHIFT.png`) ; C5 : `04_RESULTS/SHIFT/Vivado_SHIFT_S1-S10_C5.png` ; `03_TESTBENCH/expected_results/ExpectedResults.csv` (lignes C1–C7) |
| T2.2 | Tests S1–S10 | §4 et §7 | `03_TESTBENCH/SHIFT/tb_shift.vhd`, `imem.vhd` ; `04_RESULTS/SHIFT/Vivado_SHIFT_S1-S10_C5.png` ; `ExpectedResults.csv` (lignes S1–S10) |
| T2.3 | Tests B1–B8 | §5 et §7 | `03_TESTBENCH/BL/tb_bl.vhd`, `imem.vhd` ; `04_RESULTS/BL/README.md`, `BL_console_B1-B8.txt`, `BL_B6.png`, `BL_B3_B5.png`, `Vivado_BL_B1-B8_19sur19_avecSHIFT.png` ; `ExpectedResults.csv` (lignes B1–B8) |
| T2.4 | R1–R7 + cas de diagnostic | §7 Vérification / régression | `03_TESTBENCH/regression/RegressionSummary.csv` (lignes R1–R7) ; `04_RESULTS/CMP/Vivado_Lab4_CMP_26sur26_avecSHIFT.png` (20 tests Lab 4) ; `04_RESULTS/BL/REG_BL_console_26tests.txt` ; `04_RESULTS/REGRESSION/` ; diagnostic : `04_RESULTS/DEBUG_CASE/README.md` (T1–T4) |
| E1 | Communication / reproductibilité | §2 à §8 | `00_README/README.md`, `PROJECT_SCOPE.md`, `SUBMISSION_INDEX.md` ; `05_ARCHITECTURE/` ; `03_TESTBENCH/expected_results/ExpectedResults.csv` ; `03_TESTBENCH/regression/RegressionSummary.csv` |
| E2 | Contribution / intégration | §9 | `06_ENGINEERING_PRACTICE/E2_Team_Contribution/E2_Team_Contribution.md` (E2.1, E2.3, E2.4, E2.5) ; `E2_2_Student01` à `05_*.md` (E2.2) |
| E3 | Défaut publié | §9 | `06_ENGINEERING_PRACTICE/E3_Released_Defect/E3_Conditional_BL_Defect_Response.pdf` ; `preuves/` |
| E4 | Provenance / licence | §9 | `06_ENGINEERING_PRACTICE/E4_Provenance_License/THIRD_PARTY_AND_PROVENANCE.md` ; `LICENSE` ; `LICENSE_SCOPE.md` ; `00_README/AI_USE_DECLARATION.md` |
| E5 | Risque FPGA | §9 | `06_ENGINEERING_PRACTICE/E5_FPGA_Risk/E5_FPGA_Configuration_Risk.pdf` |
| E6 | Économie | §9 | `06_ENGINEERING_PRACTICE/E6_Engineering_Economics/E6_FPGA_Product_Economics.pdf` |
| E7 | Recherche autonome | §9 | `06_ENGINEERING_PRACTICE/E7_Autonomous_Research/E7_Student01_Proposal.pdf` à `E7_Student05_Proposal.pdf`, `E7_Comparison_Matrix.pdf`, `E7_Selected_Idea_Development.pdf` |

Présentation : `07_PRESENTATION/Team05_GE1084_MP1_Presentation.pdf`. Version évaluée : tag `v1.0-remise` (voir `00_README/SUBMISSION_INDEX.md`).
