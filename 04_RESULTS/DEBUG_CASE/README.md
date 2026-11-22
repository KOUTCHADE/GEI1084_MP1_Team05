# DEBUG_CASE — Défaut du chemin de branchement B (Lab 4 de base)

Diagnostic obligatoire (guide MP1, section 8.6.1).
Ce dossier contient la **reproduction du défaut avant correction** (tâche T1).

| Élément | Valeur |
|---|---|
| Version testée | `main`, commit `9a11a72`, dossier `02_HDL/baseline_lab4/` |
| Outil | Vivado 2022.2, simulation comportementale, VHDL-2008 |
| Composant | `xc7z007sclg225-2` |
| Date de la reproduction | 2026-11-21 |
| Branche de travail | `feature/bl` |

---

## 1. Contexte

L'instruction **BL** (partie BL du mini-projet) doit **réutiliser le chemin de branchement du B ordinaire** du Lab 4.
Avant d'ajouter BL, nous avons donc vérifié que ce chemin fonctionne.

Selon l'architecture ARM monocycle du cours, la cible d'un B est :

```
Cible = (PC + 8) + SignExt(imm24) × 4
```

- `PC + 8` est obtenu en lisant **R15** dans le banc de registres (RegSrc(0) = 1 → RA1 = 15).
- `SignExt(imm24) × 4` est produit par le bloc **extend** (ImmSrc = 10).
- L'ALU additionne les deux (ALUControl = 00), et le résultat est chargé dans le PC si PCSrc = 1.

**Constat de départ :** le programme de test du Lab 4 (20 instructions, `Instructions.txt` / `imem.vhd`) ne contient **aucun B**.
Le testbench `tb_arm_top` donne 20/20, mais il **n'exerce jamais** le chemin de branchement.

---

## 2. Symptôme

Avec un programme contenant deux B, la simulation donne de **mauvaises adresses de saut** :

| Instruction | Adresse | Cible attendue | Cible observée |
|---|---|---|---|
| `B` +1 (`EA000001`) | 0x00 | 0x00 + 8 + 4 = **0x0000000C** | **0x00000004** |
| `B` −4 (`EAFFFFFC`) | 0x0C | 0x0C + 8 − 16 = **0x00000004** | **0x03FFFFF0** |

Le saut vers l'avant arrive au mauvais endroit, et le saut vers l'arrière produit une adresse hors de la mémoire d'instructions.

---

## 3. Hypothèses

La cible est calculée par `ALUResult = SrcA + ExtImm`. Trois causes possibles :

| # | Hypothèse | Signal à observer |
|---|---|---|
| H1 | La base `SrcA` ne vaut pas PC + 8 (lecture de R15 incorrecte) | `SrcA_internal` |
| H2 | Le déplacement `ExtImm` est mal étendu | `ExtImm_internal` |
| H3 | L'addition de l'ALU est fausse | Comparer `ALUResult` à `SrcA + ExtImm` |

---

## 4. Reproduction et preuve diagnostique

### 4.1 Programme de test (`imem.vhd` de ce dossier)

Seul le contenu du ROM de `imem.vhd` est modifié. Tous les autres fichiers sont ceux de `baseline_lab4`, sans modification.

| Adresse | Code | Instruction | Rôle |
|---|---|---|---|
| 0x00 | `EA000001` | `B` +1 | Saut vers l'avant (cible 0x0C) |
| 0x04 | `E2801011` | `ADD R1, R0, #0x11` | Repère (ALUResult = 0x11) |
| 0x08 | `E2802022` | `ADD R2, R0, #0x22` | Repère (ALUResult = 0x22) |
| 0x0C | `EAFFFFFC` | `B` −4 | Saut vers l'arrière (cible 0x04) |

Le programme est choisi pour que le processeur exécute **les deux B même s'il est défectueux** : une seule simulation montre donc les deux défauts.

### 4.2 Testbench (`03_TESTBENCH/tb_t1_branch.vhd`)

- Horloge de 10 ns, reset actif jusqu'à 22 ns.
- Vérification à chaque **front montant** (25, 35, 45, 55 ns) de `PC`, `Instr`, `ALUResult` et `PCSrc`, comparés au comportement **correct** attendu.
- Affiche PASS ou FAIL par cycle, puis un bilan. La simulation s'arrête à 55 ns (`std.env.stop`).
- Le **même testbench** servira au retest après correction.

Résultats attendus (comportement correct) :

| Cycle | PC | Instr | ALUResult | PCSrc |
|---|---|---|---|---|
| 1 | 0x00 | EA000001 | 0x0000000C | 1 |
| 2 | 0x0C | EAFFFFFC | 0x00000004 | 1 |
| 3 | 0x04 | E2801011 | 0x00000011 | 0 |
| 4 | 0x08 | E2802022 | 0x00000022 | 0 |

### 4.3 Résultat observé (`T1_console_avant_correction.txt`)

**4 cycles sur 4 en échec — « CHEMIN DE BRANCHEMENT NON CONFORME ».**

| Cycle | PC observé | Instr observée | ALUResult observé | Interprétation |
|---|---|---|---|---|
| 1 | 0x00 | EA000001 | **0x00000004** | Le B +1 calcule une mauvaise cible |
| 2 | 0x04 | E2801011 | 0x00000011 | Conséquence : le processeur est sur le mauvais chemin |
| 3 | 0x08 | E2802022 | 0x00000022 | Conséquence |
| 4 | 0x0C | EAFFFFFC | **0x03FFFFF0** | Le B −4 calcule une mauvaise cible |

Les cycles 1 et 4 révèlent les causes. Les cycles 2 et 3 échouent par **conséquence** du premier mauvais saut.

### 4.4 Forme d'onde (`T1_waveform_avant_correction.png`)

Signaux : `CLK`, `reset`, `PC`, `Instr`, `PCSrc`, `ALUResult`, et deux signaux internes du datapath (`DUT/U_DP`) : `SrcA_internal`, `ExtImm_internal`.

| Intervalle | Instruction | SrcA_internal | ExtImm_internal | ALUResult |
|---|---|---|---|---|
| 0–25 ns | B +1 | **00000000** (attendu 00000008) | 00000004 | 00000004 |
| 25–35 ns | ADD | 00000000 (R0, normal) | 00000011 | 00000011 |
| 35–45 ns | ADD | 00000000 (R0, normal) | 00000022 | 00000022 |
| 45–55 ns | B −4 | **00000000** (attendu 00000014) | **03FFFFF0** (attendu FFFFFFF0) | 03FFFFF0 |

### 4.5 Conclusion sur les hypothèses

| # | Hypothèse | Verdict | Preuve |
|---|---|---|---|
| H1 | Base ≠ PC + 8 | ✅ **Confirmée** | `SrcA_internal = 0` pour les deux B |
| H2 | Extension incorrecte | ✅ **Confirmée** | `ExtImm_internal = 03FFFFF0` au lieu de `FFFFFFF0` |
| H3 | ALU défectueuse | ❌ **Rejetée** | `ALUResult = SrcA + ExtImm` dans tous les cas (0 + 4 = 4 ; 0 + 03FFFFF0 = 03FFFFF0) |

---

## 5. Causes racines

Deux défauts **indépendants**, tous deux dans `02_HDL/baseline_lab4/`.

### Défaut 1 — `register_file.vhd` : R15 n'est jamais lu

Ligne 34 (déclaration du port) :
```vhdl
R15 : in STD_LOGIC_VECTOR (31 downto 0);
```
Lignes 47–48 (lecture) :
```vhdl
RD1 <= RAM(to_integer(unsigned(RA1)));
RD2 <= RAM(to_integer(unsigned(RA2)));
```

- `datapath.vhd` envoie bien `PCPlus8` au port `R15`.
- Mais la lecture renvoie toujours une **case du tableau `RAM`**. Pour RA1 = 15, elle lit `RAM(15)`, qui n'est jamais écrite et vaut 0.
- Le port `R15` n'est utilisé **nulle part** dans l'architecture.
- **Effet :** pour un B, la base de la cible vaut 0 au lieu de PC + 8.

### Défaut 2 — `extend.vhd` : extension par des zéros au lieu de l'extension de signe

Lignes 32–34 :
```vhdl
when "10" =>
    ExtImm <= (31 downto 26 => '0') &
              Instr(23 downto 0) & "00";
```

- imm24 est un nombre **signé** (complément à deux). Les 6 bits de poids fort doivent recopier le bit de signe `Instr(23)`.
- Le code les met toujours à 0.
- **Effet :** un déplacement négatif devient un grand nombre positif. Exemple : imm24 = −4 (0xFFFFFC) donne 0x03FFFFF0 (+67 108 848) au lieu de 0xFFFFFFF0 (−16).
- **Pourquoi le défaut se cache :** pour un saut vers l'avant, le bit 23 vaut 0, et le résultat est juste par coïncidence. Seul un saut vers l'arrière le révèle.

### Indépendance des deux défauts

Vérifiée en appliquant chaque correction séparément :

| Version | B +1 (attendu 0x0C) | B −4 (attendu 0x04) |
|---|---|---|
| Code d'origine | 0x04 | 0x03FFFFF0 |
| Correction 1 seule | 0x0C ✅ | 0x04000004 ❌ |
| Correction 2 seule | 0x04 ❌ | 0xFFFFFFF0 ❌ |
| Les deux corrections | 0x0C ✅ | 0x04 ✅ |

---

## 6. Impact

- **B ordinaire (R7) :** non fonctionnel dans la base du Lab 4.
- **BL (T1.3, B1–B8) :** BL réutilise ce chemin. Sans correction, aucun test BL ne peut réussir.
- **Toute l'équipe :** `register_file` et `extend` sont partagés. Les corrections doivent être intégrées dans `main` par une Pull Request relue.

---

## 7. Suite du diagnostic (à compléter)

| Étape | Tâche | Statut |
|---|---|---|
| Correction 1 | T2 — lire l'entrée `R15` quand l'adresse vaut `1111` | À faire |
| Correction 2 | T3 — étendre le signe de `Instr(23)` pour ImmSrc = 10 | À faire |
| Retest | Relancer `tb_t1_branch` : attendu 4/4 PASS | À faire |
| Régression | Relancer `tb_arm_top` (20 tests du Lab 4) : attendu 20/20 | À faire |

---

## 8. Reproduire ce résultat

1. Copier `02_HDL/baseline_lab4/` dans un dossier de travail (ex. `T1_repro`).
2. Remplacer `imem.vhd` par celui de ce dossier, et ajouter `03_TESTBENCH/tb_t1_branch.vhd`.
3. Créer un projet Vivado (`xc7z007sclg225-2`) :
   - Design Sources : tous les `.vhd` du dossier sauf ceux commençant par `tb_` (20 fichiers), top = `arm_top` ;
   - Simulation Sources : `tb_t1_branch.vhd`, top = `tb_t1_branch` ;
   - console Tcl : `set_property file_type {VHDL 2008} [get_files *.vhd]`.
4. Lancer **Run Behavioral Simulation** (arrêt automatique à 55 ns).
5. Ajouter les signaux internes :
   ```
   add_wave -radix hex /tb_t1_branch/DUT/U_DP/SrcA_internal
   add_wave -radix hex /tb_t1_branch/DUT/U_DP/ExtImm_internal
   restart
   run all
   ```
6. Attendu : 4 FAIL et « CHEMIN DE BRANCHEMENT NON CONFORME », avec les valeurs de la section 4.3.

---

## 9. Fichiers de ce dossier

| Fichier | Contenu |
|---|---|
| `README.md` | Ce document |
| `imem.vhd` | `imem` de la base avec le programme de test T1 (seul le ROM change) |
| `T1_console_avant_correction.txt` | Sortie console Vivado de la simulation |
| `T1_waveform_avant_correction.png` | Forme d'onde Vivado (8 signaux, 0–55 ns) |
