# E3 — Réponse à un défaut publié : BL conditionnel qui écrase R14

Équipe 05 — GEI1084 Mini-projet 1

> Méthode : le défaut décrit dans le scénario n'existe pas dans notre version finale (B6 passe). Pour traiter le cas comme un vrai incident, nous avons **réinjecté le défaut** dans une copie du design (version fictive « v1.0 publiée »), reproduit le symptôme, puis comparé à la version corrigée (« v1.0.1 », identique à `02_HDL/final_design/`). Toutes les traces sont dans `06_ENGINEERING_PRACTICE/E3_Released_Defect/preuves/`.

## 1. Résumé

| Élément | Valeur |
|---|---|
| Défaut | Un BL dont la condition est fausse ne branche pas (correct), mais écrit PC+4 dans R14 (incorrect). |
| Gravité | Élevée : corruption silencieuse d'état architectural (registre de lien) dans une fonction annoncée comme supportée. |
| Version affectée | v1.0 (fictive), défaut injecté dans `datapath.vhd` (voir `preuves/E3_defaut_injecte.diff`). |
| Version corrigée | v1.0.1 = `02_HDL/final_design/` de la branche `integration`. |
| Cause racine | L'écriture du banc de registres pour le lien est activée par `BL` seul, sans passer par `CondEx`. |
| Détecté par | Test B6 (`03_TESTBENCH/BL/tb_bl.vhd`), via la relecture de R14 par `ADD R5, R14, #0`. |
| État | Corrigé, retesté, régression complète conforme. |

## 2. Comportement attendu

Pour `BLNE` à l'adresse 0x14 quand Z = 1 (condition NE fausse) :

| Grandeur | Attendu |
|---|---|
| CondEx | 0 |
| PCSrc | 0 (aucun branchement) |
| PC suivant | PC + 4 = 0x18 |
| RegWrite effectif vers le banc | 0 |
| R14 après l'instruction | inchangé = 0x000000AB |

Règle du guide (7.4.1) : *CondEx = 0 : aucun branchement et aucune écriture de R14.*

## 3. Reproduction

Programme : `03_TESTBENCH/BL/imem.vhd` (le même que pour B1–B8).

| Adresse | Instruction | Rôle |
|---|---|---|
| 0x00 | `ADD R14, R0, #0xAB` | R14 reçoit une valeur distinctive |
| 0x10 | `CMP R0, R0` | Z = 1, donc NE est faux |
| 0x14 | `BLNE 0x2C` | BL conditionnel, condition fausse |
| 0x18 | `ADD R5, R14, #0` | Relit R14 : sa valeur apparaît dans ALUResult |

Commande (GHDL 4.1, VHDL-2008), depuis un dossier contenant `final_design/*.vhd` + `03_TESTBENCH/BL/*.vhd` :

```
ghdl -i --std=08 *.vhd
ghdl -m --std=08 tb_bl
ghdl -r --std=08 tb_bl --stop-time=2us
```

La même procédure fonctionne dans Vivado 2022.2 (simulation comportementale, VHDL-2008).

## 4. Observé (version v1.0 défectueuse)

Extrait de `preuves/E3_console_avant_correction_defaut_injecte.txt` :

```
BL cycle 5 [B6] : PASS | PC=00000014 Instr=1B000004 ALUResult=0000002C PCSrc='0' RegWrite='0'
BL cycle 6 [B6] : FAIL | attendu ALUResult=000000AB | observe PC=00000018 ALUResult=00000018
B6 : FAIL
BL : cycles en echec = 1 / 19
```

Lecture :

* au cycle 5 (le BLNE lui-même), tout semble correct : PC ne branche pas (PCSrc = 0) et le signal de débogage `RegWrite` vaut 0 ;
* au cycle 6, la relecture de R14 donne **0x18** (PC+4 du BLNE) au lieu de **0xAB**. R14 a donc été écrit.

C'est exactement le caractère silencieux du défaut : un test qui ne regarde que le PC, ou même le signal `RegWrite` en sortie de `condlogic`, conclut PASS.

## 5. Cause racine

Dans notre architecture, trois choses sont nécessaires pour écrire R14 :

1. `A3 = 14` (multiplexeur de destination commandé par `BL`) ;
2. `WD3 = PC+4` (multiplexeur de donnée commandé par `BL`) ;
3. une **autorisation d'écriture** du banc de registres.

Les deux sélections (1) et (2) peuvent dépendre de `BL` seul : elles ne font que préparer l'écriture. Le point de contrôle architectural est (3). Dans la version correcte, l'autorisation est `RegWrite = RegW AND CondEx` (dans `condlogic.vhd`), et `main_decoder` met `RegW = 1` pour BL. L'écriture du lien passe donc par le même gating que toute autre écriture.

Dans la version défectueuse, l'autorisation transmise au banc est `RegWrite OR BL` (voir le diff). Le terme `BL` contourne `CondEx`. Le chemin de branchement, lui, reste correctement inhibé (`PCSrc = PCS AND CondEx`), d'où le comportement « à moitié correct ».

Une autre forme du même défaut, `RegWrite <= RegW` sans `CondEx`, avait déjà été injectée par l'équipe pendant le développement de BL : seul B6 échouait (voir `04_RESULTS/BL/README.md`, section 5). Un signal `LinkWrite` séparé et non conditionné produirait le même effet.

## 6. Conséquences

* **Corruption d'état architectural.** R14 fait partie de l'état visible du programmeur. Un programme qui a sauvegardé une adresse de retour dans R14, puis exécute un BL conditionnel non pris, perd cette adresse.
* **Effet différé.** BX/BLX ne sont pas dans notre sous-ensemble, mais un logiciel réel ferait `MOV PC, LR` ou `BX LR` plus tard : le retour irait à la mauvaise adresse (ici juste après le BL non pris), donc boucle ou exécution de code inattendue, loin de la cause.
* **Défaut silencieux.** Le PC est correct au moment du BL. Seule l'observation de R14 après l'instruction le révèle. C'est pourquoi B6 relit R14 explicitement.

## 7. Correction

Retirer le terme qui contourne `CondEx` : l'autorisation d'écriture du banc doit être uniquement `RegWrite = RegW AND CondEx`. Pour BL, le décodeur principal fournit `RegW = 1`, et les deux multiplexeurs (`A3`, `WD3`) restent commandés par `BL`.

```vhdl
-- condlogic.vhd (v1.0.1)
RegWrite <= RegW and CondEx_internal;
-- datapath.vhd (v1.0.1) : le banc reçoit RegWrite tel quel
RegWrite => RegWrite,
```

## 8. Retest et régression (v1.0.1)

| Test exigé par le guide (11.2.2) | Test utilisé | Résultat | Preuve |
|---|---|---|---|
| BL normal | B2 (BL AL vers l'avant) | PASS | `preuves/E3_console_apres_correction_BL.txt` |
| BL condition vraie | B5 (BLEQ, Z = 1) | PASS | idem |
| BL condition fausse | B6 (BLNE, Z = 1) | PASS, R14 = 0xAB | idem |
| B ordinaire | B1 | PASS | idem |
| Écriture normale après BL | B7 | PASS | idem |
| Un cas CMP | C5 (+ C1–C4, C6, C7) | PASS | `preuves/E3_regression_SHIFT_C5.txt`, `preuves/E3_regression_Lab4_CMP.txt` |
| Un cas Shift | S1–S10 | PASS (0/27 cycles en échec) | `preuves/E3_regression_SHIFT_C5.txt` |
| Régression Lab 4 | 20 tests Lab 4 + C1–C4, C6, C7 | PASS (26/26) | `preuves/E3_regression_Lab4_CMP.txt` |

Bilan : BL 19/19 cycles conformes, SHIFT 0/27 en échec, Lab 4 + CMP 26/26 (GHDL 4.1, VHDL-2008). Les mêmes résultats ont été obtenus dans Vivado 2022.2 (captures dans `04_RESULTS/BL`, `04_RESULTS/CMP`, `04_RESULTS/SHIFT`).

## 9. Gestion de la version déjà publiée

1. **Identifier la version affectée** : étiquette Git `v1.0` (commit publié). On cherche dans l'historique le commit qui a introduit le terme fautif (`git log -S "or BL"` ou `git bisect` avec B6 comme critère).
2. **Documenter** : ouvrir une issue GitHub « BL conditionnel faux écrase R14 » avec ce document, les étapes de reproduction et la console en échec.
3. **Conserver la trace** : ne pas supprimer ni réécrire `v1.0`. Pas de `git push --force`, pas de remplacement silencieux du ZIP.
4. **Publier la correction** : commit de correction qui référence l'issue, nouvelle étiquette `v1.0.1`, notes de version.
5. **Prouver** : joindre aux notes de version les consoles de régression de la section 8.
6. **Informer les utilisateurs** : avis ci-dessous, publié dans le README et dans la release.

## 10. Avis aux utilisateurs

> **Avis de défaut — processeur MP1 v1.0.** Dans la version v1.0, une instruction BL dont la condition est fausse ne branche pas, mais écrase quand même R14 avec l'adresse PC+4. Tout programme qui conserve une adresse de retour dans R14 pendant un BL conditionnel peut donc revenir à une mauvaise adresse. **Action requise :** passez à la version v1.0.1 (étiquette `v1.0.1`) et relancez vos simulations. Les autres instructions (Lab 4, CMP, LSL/LSR, BL inconditionnel) ne sont pas affectées ; la régression complète est jointe. Contact : équipe 05, issue GitHub n° __.

## 11. Défaut ou limitation connue ?

* **Limitation connue** : une fonction qui n'est pas annoncée. Exemples : ASR, ROR, RRX, décalage par registre, BX/BLX, carry de sortie du shifter. Elles sont listées comme exclues dans `00_README/PROJECT_SCOPE.md`. Ne pas les supporter n'est pas un défaut.
* **Défaut** : une fonction annoncée comme supportée qui se comporte mal. Le BL conditionnel est explicitement supporté (B5, B6) ; écraser R14 quand la condition est fausse est donc un **défaut**, qui exige correction, nouvelle version et avis. On ne peut pas le « reclasser » en limitation après coup.

## 12. Checklist de release (v1.0.1)

- [ ] Issue ouverte et liée au commit de correction
- [ ] Correction revue par un membre autre que l'auteur
- [ ] B1–B8 : 19/19 cycles conformes
- [ ] S1–S10 + C5 : 0 échec
- [ ] Lab 4 + CMP : 26/26
- [ ] `RegressionSummary.csv` mis à jour avec la date et la version
- [ ] Étiquette `v1.0.1` créée, `v1.0` conservée
- [ ] Notes de version + avis aux utilisateurs publiés
- [ ] ZIP de remise régénéré à partir du commit étiqueté
