# Résultats de validation - CMP

## 1. Objectif

Ce dossier regroupe les preuves de simulation de l'instruction CMP intégrée au processeur ARM monocycle du mini-projet GEI1084.

L'instruction CMP effectue une soustraction afin de mettre à jour les indicateurs NZCV, sans écrire le résultat dans le banc de registres.

## 2. Tests réalisés

| Test | Preuves de simulation | Résultat |
|---|---|---|
| C1 | Chronogramme et console Vivado | Conforme |
| C2 | Chronogramme et console Vivado | Conforme |
| C3 | Chronogramme et console Vivado | Conforme |
| C4 | Chronogramme et console Vivado | Conforme |
| C6 | Chronogramme et console Vivado | Conforme |
| C7 | Chronogramme et console Vivado | Conforme |

Chaque test dispose de deux captures :

- `C1_Chronogramme.png` et `C1_Testbench_Console.png`
- `C2_Chronogramme.png` et `C2_Testbench_Console.png`
- `C3_Chronogramme.png` et `C3_Testbench_Console.png`
- `C4_Chronogramme.png` et `C4_Testbench_Console.png`
- `C6_Chronogramme.png` et `C6_Testbench_Console.png`
- `C7_Chronogramme.png` et `C7_Testbench_Console.png`

## 3. Observations

Les chronogrammes permettent d'observer les signaux `ALUResult`, `ALUFlags`, `FlagW`, `Flags_internal`, `CondEx_internal` et `RegWrite`.

Le test C6 vérifie que CMP ne provoque aucune écriture dans le banc de registres.

Le test C7 vérifie l'exécution conditionnelle des instructions ARM après une comparaison.

## 4. Bilan final

- Tests initiaux du laboratoire 4 : **20**
- Tests supplémentaires CMP : **6**
- Nombre total de tests : **26**
- Nombre total d'erreurs : **0**
- Résultat final : **SIMULATION CONFORME : 26 tests**

## 5. Test restant

Le test C5, consacré au débordement signé, reste à compléter après l'intégration de l'extension SHIFT.

## 6. Environnement de validation

- Outil : Vivado / XSim
- Langage : VHDL
- Simulation : comportementale
- Banc d'essai : `tb_arm_top.vhd`