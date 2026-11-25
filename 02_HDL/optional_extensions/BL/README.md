# BL — fichiers modifiés (parties 4 et 5)

Ce dossier contient uniquement les fichiers modifiés pour BL.
Pour compiler le processeur complet avec BL, il faut :

- ces 5 fichiers ;
- `alu_decoder.vhd` et `condlogic.vhd` de `02_HDL/optional_extensions/CMP/` (CMP), sans modification ;
- les autres fichiers de `02_HDL/baseline_lab4/`, sans modification.

| Fichier | Point de départ | Modification | Raison |
|---|---|---|---|
| `register_file.vhd` | `baseline_lab4` | Lignes 47–50 : une lecture à l'adresse 15 (RD1 ou RD2) renvoie l'entrée `R15` (PC + 8) | Défaut 1 du chemin B : R15 était lu à 0 |
| `extend.vhd` | `baseline_lab4` | Ligne 33 : extension de signe de `Instr(23)` pour ImmSrc = 10 | Défaut 2 du chemin B : extension par des zéros |
| `main_decoder.vhd` | `optional_extensions/CMP` | Nouvelle sortie `BL`. Pour Op = 10 : si `Opcode(3)` = Instr(24) = 1, alors RegW = 1 et BL = 1 ; sinon RegW = 0 | Reconnaître BL et autoriser l'écriture de R14 |
| `arm_top.vhd` | `optional_extensions/CMP` | Nouveau signal `BL_s` ; `BL_s` et `PCPlus4_s` sont reliés au datapath | Transmettre la commande BL et la valeur PC + 4 |
| `datapath.vhd` | `baseline_lab4` | Nouvelles entrées `PCPlus4` et `BL` ; MUX `A3_internal` (`1110` si BL, sinon Instr(15:12)) ; MUX `WD3_internal` (PCPlus4 si BL, sinon Result) | Choisir R14 comme destination et PC + 4 comme donnée |

## Points de conception

- Le saut de BL réutilise le chemin du B : R15 (PC + 8) + ExtImm → ALU → Result → PC, commandé par `Branch` et `PCSrc = PCS ∧ CondEx`.
- L'écriture de R14 passe par `RegWrite = RegW ∧ CondEx` (`condlogic`, inchangé). Si la condition est fausse, R14 n'est pas écrit.
- Pour un B (bit 24 = 0), RegW = 0 et BL = 0 : R14 n'est jamais écrit.
- Quand BL = 0, les deux MUX redonnent Rd et Result : le comportement des autres instructions est inchangé.
- Modules inchangés : `condlogic`, `condcheck`, `pc_logic`, `pc_path`, `alu32`, `data_memory`, `imem`.

Diagnostic du chemin B : `04_RESULTS/DEBUG_CASE/README.md`.
Tests B1–B8 : `04_RESULTS/BL/README.md`.
