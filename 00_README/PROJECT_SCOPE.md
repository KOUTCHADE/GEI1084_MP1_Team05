# Portée du projet — Team05

## Base Lab 4 (requis, conservée)

Processeur ARM monocycle 32 bits : ADD, SUB, AND, ORR (registre et immédiat, avec ou sans S), LDR, STR (décalage immédiat positif), B, exécution conditionnelle complète (15 conditions), indicateurs NZCV. Référence non modifiée : `02_HDL/baseline_lab4/`. Le défaut du chemin B découvert pendant le projet (R15 lu à 0, extension de l'immédiat par zéros) est corrigé dans `final_design` (voir `04_RESULTS/DEBUG_CASE/`).

## Extensions obligatoires (requises et supportées)

| Extension | Supporté | Tests |
|---|---|---|
| CMP (registre et immédiat), codage Funct(4:1) = 1010, S = 1 | Oui | C1–C7 |
| Opérande registre décalé : LSL #0–31 et LSR #0–31 sur ADD, SUB, AND, ORR | Oui | S1–S10 |
| BL (conditionnel et inconditionnel, vers l'avant et l'arrière) | Oui | B1–B8 |
| Non-régression Lab 4 | Oui | R1–R7 |

## Exclusions explicites (hors portée, pas des défauts)

* ASR, ROR, RRX ; décalage spécifié par registre ; `LSR #0` interprété comme LSR #32.
* Carry de sortie du shifter.
* BX, BLX, MOV, MVN, EOR, BIC, TST, TEQ, CMN, ADC, SBC, RSB, MUL.
* Immédiat avec rotation ; LDR/STR avec décalage négatif, registre, pré/post-indexation, octet.
* Écriture de R15 par data-processing ou LDR.
* Pipeline, interruptions, modes du processeur.
* Implémentation et validation sur carte FPGA.

## Extensions optionnelles réellement implémentées

* Aucune extension fonctionnelle supplémentaire.
* Outils ajoutés : script de régression GHDL `03_TESTBENCH/regression/run_regression_ghdl.sh`.
* `02_HDL/optional_extensions/BL_R14/` : seconde implémentation BL indépendante, conservée pour comparaison, **non utilisée** dans `final_design`.
