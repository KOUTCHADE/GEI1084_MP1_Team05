# E7 — Matrice de comparaison et sélection (phase équipe)

Équipe 05 — à remplir **après** réception des 5 propositions individuelles, en réunion. Exporter en `E7_Comparison_Matrix.pdf`.

## 1. Propositions reçues

| N° | Étudiant | Titre de la proposition | Date de remise | Fichier |
|---|---|---|---|---|
| 1 | Koutchadé, Bolarinwa Rodrigue Fidèle | | | `E7_Student01_Proposal.pdf` |
| 2 | Fatah Djappi, Raissa | | | `E7_Student02_Proposal.pdf` |
| 3 | Omouala, Andre Kevin | | | `E7_Student03_Proposal.pdf` |
| 4 | Kalamata Katambwe, Caleb | | | `E7_Student04_Proposal.pdf` |
| 5 | Koffi, Assoumou Faustin | | | `E7_Student05_Proposal.pdf` |

## 2. Échelle (1 à 5, 5 = favorable)

| Critère | Poids | 1 | 3 | 5 |
|---|---:|---|---|---|
| Pertinence technique MP1 | 20 % | Sans lien avec CMP/Shift/BL ni avec nos tests | Lien indirect | Corrige un problème réellement rencontré dans MP1 |
| Bénéfice d'ingénierie attendu | 20 % | Négligeable | Utile mais local | Gain mesurable (temps, défauts détectés, coût) |
| Faisabilité dans la portée du projet | 20 % | Impossible dans le temps restant | Partielle | Réalisable et démontrable avant la remise |
| Qualité des preuves | 15 % | Aucune source crédible | 1–2 sources, faible lien | ≥ 3 sources primaires qui soutiennent directement |
| Complexité d'intégration (**5 = faible complexité**) | 10 % | Touche beaucoup de modules, casse des tests | Quelques modules | Aucun module existant à changer, ou un seul |
| Coût / risque (**5 = faible coût et faible risque**) | 10 % | Risque élevé de régression ou coût important | Modéré | Risque et coût négligeables |
| Extensibilité future | 5 % | Cas unique | Réutilisable | Réutilisable pour MP2 et au-delà |

## 3. Matrice pondérée

Score pondéré = Σ (note × poids). Maximum = 5,00.

| Critère | Poids | P1 | P2 | P3 | P4 | P5 |
|---|---:|---:|---:|---:|---:|---:|
| Pertinence technique MP1 | 0,20 | | | | | |
| Bénéfice d'ingénierie | 0,20 | | | | | |
| Faisabilité | 0,20 | | | | | |
| Qualité des preuves | 0,15 | | | | | |
| Complexité d'intégration (5 = faible) | 0,10 | | | | | |
| Coût / risque (5 = faible) | 0,10 | | | | | |
| Extensibilité | 0,05 | | | | | |
| **Score pondéré** | 1,00 | | | | | |

Exemple de calcul : notes 5, 4, 4, 3, 4, 5, 3 → 0,20·5 + 0,20·4 + 0,20·4 + 0,15·3 + 0,10·4 + 0,10·5 + 0,05·3 = **4,10**.

## 4. Discussion (obligatoire, la matrice ne suffit pas)

* Justification des notes qui ont fait débat :
* Écarts faibles (< 0,3 point) et comment ils ont été tranchés :
* Compromis principaux :

## 5. Sélection

* **Idée retenue :**
* **Pourquoi elle est retenue :**
* **Pourquoi chaque autre idée n'est pas retenue** (trop large, risquée, difficile à intégrer, déjà couverte…) :

## 6. Tableau de responsabilité individuelle

| Étudiant | Proposition | Principales sources | Mérite | Limite | Sélectionnée ? |
|---|---|---|---|---|---|
| | | | | | |

## 7. Plan de `E7_Selected_Idea_Development.pdf`

1. Idée sélectionnée et proposition originale
2. Raisons de la sélection
3. Preuves (sources, mesures)
4. Idée raffinée (ce qui a changé depuis la proposition)
5. Développement / implémentation (HDL, banc de test, script, analyse quantitative…)
6. Méthode de validation et **critère de succès mesurable**
7. Résultat observé
8. Limites
9. Recommandation finale

Note : si l'idée retenue porte sur la vérification ou la régression, le script `03_TESTBENCH/regression/run_regression_ghdl.sh` et l'expérience d'injection de défaut de E3 peuvent servir de point de départ mesurable (par exemple : nombre de défauts injectés détectés par la suite de tests).
