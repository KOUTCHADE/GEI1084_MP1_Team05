# E2 — Contribution au travail d'équipe et responsabilité d'intégration

Équipe 05 — GEI1084 MP1. Les parties d'équipe (E2.1, E2.3, E2.5) sont rédigées à partir de l'historique Git et des fichiers du dépôt. **E2.2 est individuel** : chaque membre remplit sa fiche (section 3). **E2.4** : chaque revue doit être faite et écrite par le reviewer (section 5).

## Membres et comptes Git

Liste officielle du groupe 5 (5 membres, nom de famille en premier). Dans la suite, chaque membre est désigné par son prénom usuel : Raissa, Caleb, Faustin, Rodrigue, Andre Kevin.

| N° | Membre (NOM, prénoms) | Responsabilité VHDL (Repartition.pdf) | Compte GitHub |
|---|---|---|---|
| 1 | Koutchadé, Bolarinwa Rodrigue Fidèle | CMP | `KOUTCHADE` |
| 2 | Fatah Djappi, Raissa | SHIFT — décodage | `raissa1997` |
| 3 | Omouala, Andre Kevin | SHIFT — unité de décalage | `kevin-and925` |
| 4 | Kalamata Katambwe, Caleb | BL — décodage et PC | `Evangea-code` |
| 5 | Koffi, Assoumou Faustin | BL — registre de lien R14 | `Marc-Artur` |

## 1. E2.1 — Plan de contribution

| Tâche | Responsable principal | Support | Reviewer | Dépendance d'intégration |
|---|---|---|---|---|
| CMP | Rodrigue | — | Caleb | Modifie `main_decoder` (RegW = 0 si opcode 1010) et `alu_decoder` (FlagW = 11) : fichiers partagés avec BL et SHIFT |
| Shift | Raissa (décodeur), Andre Kevin (shifter) | Rodrigue (intégration dans le datapath) | Rodrigue | Convention commune `ShiftControl` : 00 = LSL, 01 = LSR ; insertion entre RD2 et le mux ALUSrc dans `datapath.vhd` |
| BL | Caleb (décodage, PC, chemin R14 intégré) | Faustin (version R14 indépendante, comparaison) | Raissa **[proposé]** | `main_decoder` (signal BL, RegW = 1), `datapath` (A3 = 14, WD3 = PC+4), dépend du gating `RegWrite = RegW AND CondEx` de `condlogic` |
| Intégration | Rodrigue | Caleb | Caleb | Fusion de `feature/cmp`, `feature/bl`, `feature/shift-decoder`, `shister` dans `integration` ; passage en VHDL-2008 |
| Vérification / régression | Caleb (tb_bl, cas de diagnostic du chemin B) | Rodrigue (tb CMP 26 tests), Raissa et Andre Kevin (S1–S10) | Faustin **[proposé]** | Tous les bancs doivent tourner sur `final_design` intégré |
| Dépôt / reproductibilité | Rodrigue | Caleb (scripts Tcl Vivado) | Andre Kevin **[proposé]** | Structure imposée ; un membre qui n'a pas écrit le README doit le tester |
| Pratique d'ingénierie (E3–E7) | E3 : Caleb + Faustin ; E4 : Rodrigue ; E5 : Raissa ; E6 : Andre Kevin ; E7 : tous **[PROPOSÉ, À CONFIRMER]** | Tous | Croisé | E3 réutilise B6 ; E5 réutilise `condlogic` ; E6 dépend de E5 |

Une répartition équitable ne veut pas dire le même nombre de commits : Rodrigue a le plus de commits (27) parce qu'il gérait le dépôt et l'intégration, alors que Caleb a livré BL complet et ses preuves en 3 commits.

## 2. E2.2 — Contribution technique individuelle

Une fiche par étudiant, à remplir **par l'étudiant lui-même** (voir le gabarit `E2_2_Fiche_individuelle_GABARIT.md`). Les fiches complétées sont placées ici :

* `E2_2_Student01_Koutchade.md`
* `E2_2_Student02_FatahDjappi.md`
* `E2_2_Student03_Omouala.md`
* `E2_2_Student04_KalamataKatambwe.md`
* `E2_2_Student05_Assoumou.md`

## 3. E2.3 — Problème d'intégration

### Problème principal : deux implémentations de BL incompatibles, dont une qui cassait CMP

**[ Problème → Composants → Étudiants impliqués → Résolution → Revalidation ]**

| Étape | Contenu |
|---|---|
| **Symptôme** | Au moment de réunir les branches, deux versions de BL existaient : `feature/bl` (Caleb) et `BL-Registre-de-lien` (Faustin). Les deux modifiaient `main_decoder.vhd`, `datapath.vhd`, `register_file.vhd` et `arm_top.vhd`, avec des ports différents. En analysant la version de Faustin, on a constaté que son `main_decoder` mettait `RegW = 1` pour **toute** instruction data-processing (`when "00" => RegW <= '1'`), sans l'exception de l'opcode 1010. |
| **Cause** | 1) Les membres 4 et 5 n'avaient pas fixé leur interface avant de coder (le point d'attention de la répartition) : Caleb utilisait les signaux `BL` et `Opcode`, Faustin `Link` et `Funct4`. Chacun a donc fini par implémenter BL complet. 2) La version de Faustin partait du `main_decoder` du Lab 4, sans la modification CMP de Rodrigue. Intégrée telle quelle, elle aurait fait écrire le résultat de CMP dans Rd : le test C6 (R3 = valeur distinctive non écrasée) aurait échoué. |
| **Composants** | `main_decoder.vhd` (partagé CMP / BL), `datapath.vhd`, `register_file.vhd`, `arm_top.vhd` |
| **Étudiants impliqués** | Caleb et Faustin (deux versions BL), Rodrigue (CMP, intégrateur) |
| **Résolution technique** | Une seule implémentation BL retenue : celle de Caleb, parce qu'elle avait déjà B1–B8 et la régression 26/26 et qu'elle gardait le test `Opcode /= "1010"` de CMP. La version de Faustin est conservée dans `02_HDL/optional_extensions/` comme implémentation de comparaison (même principe A3 = 14, WD3 = PC+4, écriture gatée par CondEx), et sert de support à la revue BL et à E3. Le `main_decoder` final combine : `RegW = 0` si opcode = 1010 (CMP), `RegW = 1` et `BL = 1` si `Op = 10` et `L = 1`. |
| **Revalidation** | Sur `integration` : CMP 26/26 (20 tests Lab 4 + C1–C4, C6, C7), BL 19/19 cycles (B1–B8), puis après ajout de SHIFT : S1–S10 + C5 0/27 en échec, BL 19/19, CMP 26/26 (Vivado 2022.2, VHDL-2008 ; captures `04_RESULTS/*/Vivado_*_avecSHIFT.png`). |

### Problèmes secondaires rencontrés (traçabilité)

| Problème | Cause | Résolution | Preuve |
|---|---|---|---|
| Des fichiers `.zip` ont été commités au lieu des fichiers source (Raissa, Faustin) | Upload par l'interface web de GitHub | Contenu décompressé dans le dépôt | commits `a6310a0`, `e2e4131` |
| `shifter.vhd` poussé dans `02_HDL/baseline_lab4/` sur `main` | Mauvais dossier lors de l'upload | Déplacé vers `optional_extensions/SHIFT/` (la baseline doit rester le Lab 4 d'origine) | commits `3c50b9b`, `810a23f` |
| Le décodeur SHIFT livré en `.txt`, et non intégré au datapath | Livraison avant l'intégration ; interface à brancher | Converti en `shift_decoder.vhd`, branché entre `Instr` et le shifter | commit `d9084e6` |
| Erreur de compilation avec le standard VHDL par défaut | `adder.vhd` utilise une syntaxe VHDL-2008 | Tous les fichiers compilés en VHDL-2008 (réglage Vivado et `--std=08` dans GHDL) | `00_README/README.md`, section Outils |
| Chemin de B du Lab 4 faux (R15 lu à 0, extension d'immédiat par zéros) découvert avant BL | Défaut de la baseline jamais exercé (le programme Lab 4 ne contient aucun B) | Corrigé dans `register_file.vhd` et `extend.vhd` | `04_RESULTS/DEBUG_CASE/README.md` |

## 4. E2.4 — Revue technique par un pair

Chaque reviewer remplit sa ligne lui-même, après avoir réellement examiné le code et relancé au moins un test. Points de contrôle suggérés :

| Extension | Développeur | Reviewer | Date | Éléments contrôlés (à cocher / compléter) | Constat(s) | Correction(s) | Statut final |
|---|---|---|---|---|---|---|---|
| CMP | Rodrigue | Caleb | | `alu_decoder` : FlagW = 11 pour 1010 ; `main_decoder` : RegW = 0 pour 1010 ; `flag_registers` : écriture gatée par CondEx ; C1–C7 et attendus recalculés à la main ; C5 (V = 1) | | | |
| SHIFT | Raissa, Andre Kevin | Rodrigue | | Champs `Instr(11:7)`, `Instr(6:5)`, bit 4 = 0 ; convention 00/01 cohérente entre décodeur et shifter ; `shift_right` sur `unsigned` (remplissage par 0) ; chemin immédiat inchangé (mux ALUSrc après le shifter) ; S5, S10 relancés | | | |
| BL | Caleb | Raissa | | A3 = 14 et WD3 = PC+4 seulement si BL ; cible PC+8 ; écriture gatée par CondEx ; B ordinaire (L = 0) n'écrit pas R14 ; B6 relancé avec R14 initial distinctif | | | |

Une revue sans défaut trouvé est acceptable, à condition de dire précisément ce qui a été vérifié. « Looks good » ne suffit pas.

Constats déjà connus qui peuvent alimenter les revues (à confirmer par les reviewers) :

* SHIFT : `ShiftEnable` est calculé mais pas utilisé (sans effet : LSL #0 laisse RD2 inchangé). `LSR #0` est traité comme « pas de décalage », alors qu'en ARM il code LSR #32 ; c'est hors du sous-ensemble du guide (shamt 0–31), à mentionner comme limitation.
* CMP : `FlagW = 11` est forcé pour 1010 même si S = 0 ; acceptable car le guide impose le codage avec S = 1.

## 5. E2.5 — Traçabilité du dépôt

Nombre de commits ≠ niveau de contribution. Chaque preuve est reliée à une contribution précise.

| Étudiant | Contribution principale | Support | Intégration | Revue | Validation / debug | Preuve |
|---|---|---|---|---|---|---|
| Rodrigue | CMP : décodage, flags, suppression d'écriture | Dépôt, structure de remise | Fusion des branches dans `integration`, intégration SHIFT | SHIFT | tb CMP 26 tests, C1–C7 ; régression après intégration | `33a504e`, `e6a0e94`, `2317a30`, `ba5d357`, `4993843`, `d9084e6` ; `04_RESULTS/CMP/` |
| Raissa | Décodeur SHIFT (`shift_decoder`) | — | Interface `ShiftControl` | BL **[proposé]** | **[À compléter]** | `bbdba6c` ; `02_HDL/final_design/shift_decoder.vhd` |
| Andre Kevin | Shifter LSL/LSR (`shifter.vhd`) | Upload du décodeur | Interface avec le décodeur | Dépôt / README **[proposé]** | **[À compléter]** | `5a78585`, `2d24c00`, `74e5bbf`, `747a88c` ; `02_HDL/final_design/shifter.vhd` |
| Caleb | BL : décodage, PC, chemin R14 | Scripts Vivado | BL fusionné dans `integration` | CMP | Diagnostic du chemin B (T1–T4), B1–B8, régression 26/26 avec BL | `19a8a0b`, `0f4449d`, `55719fb`, `967e8af` ; `04_RESULTS/BL/`, `04_RESULTS/DEBUG_CASE/` |
| Faustin | BL : registre de lien R14 (implémentation indépendante) | Comparaison des deux BL | Version conservée dans `optional_extensions/` | Vérification **[proposé]** | `BL_Test_Results.txt` **[À compléter]** | `f38da09`, `e2e4131` ; `Rapport_Contribution_BL_R14.docx` |

**[À FAIRE : ajouter les identifiants de PR / issues s'il y en a, et le hash du commit final.]**
