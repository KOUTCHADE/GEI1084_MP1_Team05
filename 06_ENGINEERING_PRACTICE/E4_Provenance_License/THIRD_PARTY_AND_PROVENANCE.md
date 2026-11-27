# Provenance, attribution et licence — Équipe 05

GEI1084 – Mini-projet 1 – Équipe 05.

## 1. Tableau de provenance (E4.1)

| Artefact | Origine | Créé par l'équipe ? | Modifié ? | Statut de redistribution | L'équipe peut-elle le licencier ? | Action requise |
|---|---|---|---|---|---|---|
| HDL baseline Lab 4 (`02_HDL/baseline_lab4/`) | Laboratoires 1 à 4 du cours GEI1084 (UQTR). Code VHDL écrit par un membre de l'équipe (Koutchadé, Bolarinwa Rodrigue Fidèle) pendant les laboratoires, à partir des énoncés du cours et de l'architecture monocycle du manuel Harris & Harris, *Digital Design and Computer Architecture, ARM Edition*. L'enseignant a fourni les énoncés, les figures du datapath et les fichiers de vecteurs de test. | Oui (travail du cours) | Non (copie de référence) | Incertain : matériel pédagogique, conditions de diffusion non publiées | Non, pas sans accord de l'enseignant | Attribution au cours ; exclure du dépôt public tant que l'enseignant n'a pas autorisé la diffusion |
| Programme de test Lab 4 (`Instructions.txt`, `imem.vhd`, `ExpectedData.txt`) | Fourni par l'enseignant avec le Lab 4 ; adapté du programme de test du manuel Harris & Harris, *ARM Edition*, chapitre 7 (mêmes instructions, branchements retirés) | Non | Non | Incertain (cours / manuel) | Non | Attribution au cours et au manuel ; exclure du public |
| Modifications CMP (`main_decoder`, `alu_decoder`, `condlogic`, tests C1–C7) | Koutchadé, Bolarinwa Rodrigue Fidèle | Oui | Oui, sur fichiers Lab 4 | Le **diff** appartient à l'équipe ; le fichier entier mélange code du cours et code de l'équipe | Le diff seulement | Publier comme patch ou avec attribution du fichier d'origine |
| HDL Shift (`shift_decoder.vhd`, `shifter.vhd`) | Fatah Djappi, Raissa (décodeur), Omouala, Andre Kevin (shifter) ; intégration dans `datapath.vhd` par Koutchadé, Bolarinwa Rodrigue Fidèle | Oui (nouveaux fichiers) | — | Diffusable par l'équipe | Oui | Licence MIT |
| Modifications BL (`main_decoder`, `datapath`, `register_file`, `extend`, `arm_top`) | Kalamata Katambwe, Caleb (version intégrée) ; version R14 indépendante de Koffi, Assoumou Faustin conservée dans `optional_extensions/` | Oui (diff) | Oui, sur fichiers Lab 4 | Comme CMP | Le diff seulement | Comme CMP |
| Ajouts testbench (`tb_bl`, `tb_shift`, `tb_arm_top` CMP, `tb_t1_branch`) | Équipe | Oui | — | Diffusable | Oui | Licence MIT |
| Diagrammes (`05_ARCHITECTURE/`) | Redessinés par l'équipe à partir du schéma monocycle du cours/manuel | Partiellement (œuvre dérivée) | Oui | Incertain : le schéma de base est celui du manuel | Seulement nos ajouts | Mention « adapté de Harris & Harris, fig. 7.x » ; ne pas les placer sous MIT sans réserve |
| Code externe éventuel | Aucun code tiers copié à notre connaissance | — | — | — | — | Si un membre en a utilisé : le déclarer ici |
| README / rapport / E1–E7 | Équipe | Oui | — | Diffusable | Oui | Licence CC BY 4.0 (documentation) ou MIT |
| Gabarit de remise et guide (`*.csv`, structure, `README_E7.md`) | Enseignant GEI1084 | Non | Remplis | Matériel de cours | Non | Ne pas relicencier ; mention « gabarit fourni par le cours » |

Principe retenu : **posséder une copie ≠ détenir les droits de relicence.** Le fait qu'un fichier soit dans notre dépôt ne nous donne aucun droit sur la partie écrite par l'enseignant ou par les auteurs du manuel.

## 2. Attribution et redistribution (E4.2)

* **Du cours** : architecture et HDL du Lab 4, programme de test, gabarit de remise, guide. Action : attribution, conservation hors du dépôt public, ou diffusion uniquement si l'enseignant l'autorise par écrit.
* **Du manuel** (Harris & Harris) : architecture monocycle et schémas d'origine. Action : citer la source sous chaque figure ; nos figures sont des œuvres dérivées, nous ne revendiquons que les ajouts (couleurs « modifié / nouveau », signaux CMP, Shift, BL).
* **De l'équipe** : extensions CMP, Shift, BL, bancs de test, documentation. Action : licence MIT (code) et CC BY 4.0 (documents).

## 3. Stratégie de diffusion (E4.3)

| Option | Avantages | Problèmes avec notre provenance | Verdict |
|---|---|---|---|
| A. Dépôt public complet | Simple, transparent | Publierait le Lab 4 et le gabarit du cours sans droit établi ; faciliterait le plagiat par les cohortes suivantes | Rejeté |
| B. Sous-ensemble public | Montre notre travail (portfolio), respecte les droits | Demande de séparer nos fichiers ; les fichiers modifiés doivent être publiés comme diff ou avec instructions d'intégration | Possible après la session |
| C. Dépôt complet privé / restrictif | Respecte le cours, l'enseignant a accès à tout l'historique | Pas visible publiquement | **Retenu pour la remise** |

**Choix :** C pendant la session (dépôt `KOUTCHADE/GEI1084_MP1_Team05` privé, accès donné à l'enseignant). Après la note finale, et seulement avec l'accord de l'enseignant, B : un dépôt public qui contient `shift_decoder.vhd`, `shifter.vhd`, nos bancs de test, la documentation et des patchs pour CMP et BL, avec l'instruction « appliquer sur votre propre base Lab 4 ». Justification : la provenance du Lab 4 est incertaine, donc on ne la redistribue pas.

## 4. Choix de licence (E4.4)

Pour le code que l'équipe possède réellement : **MIT**.

* **Permissions** : utiliser, copier, modifier, fusionner, publier, redistribuer, y compris commercialement.
* **Attribution** : la mention de copyright et le texte de la licence doivent accompagner les copies.
* **Garantie** : exclusion totale (« AS IS »). C'est important pour un processeur d'enseignement non certifié.
* **Portée** : la licence couvre *uniquement* les fichiers et parties listés dans `LICENSE_SCOPE.md`, à la racine du dépôt. Un fichier `LICENSE` à la racine **ne change pas** le statut des fichiers du cours ou du manuel. Pour les fichiers mixtes (base Lab 4 + modifications), `LICENSE_SCOPE.md` précise, fichier par fichier, que seules les modifications de l'équipe sont couvertes.

BSD-2 serait équivalente ; MIT est retenue car c'est la plus courte et la plus connue. Une licence copyleft (GPL) n'est pas justifiée pour un projet pédagogique et compliquerait la réutilisation.

## 5. Cas imposé : HDL public sans licence claire (E4.5)

Scénario : nous trouvons sur GitHub un shifter VHDL utile, sans fichier LICENSE.

* **Visible ≠ libre.** Sans licence, le droit d'auteur s'applique par défaut : l'auteur conserve tous les droits. Les conditions de GitHub permettent de *voir* et de *forker* sur la plateforme, pas de copier le code dans notre projet ni de le relicencier.
* **Vérifier les droits** : chercher un LICENSE, un en-tête dans les fichiers, une mention dans le README, la licence du dépôt parent ; vérifier que l'auteur publiant est bien l'auteur (pas une copie d'un manuel ou d'un cours) ; écrire à l'auteur pour demander une autorisation écrite ou l'ajout d'une licence.
* **Si l'incertitude demeure** : ne pas copier. Options : réimplémentation indépendante à partir de la spécification ARM (ce que l'équipe a fait pour `shifter.vhd`), ou lien vers le dépôt sans redistribuer. Si on s'en est inspiré, le mentionner dans ce tableau.

## 6. Déclaration IAg

Voir `00_README/AI_USE_DECLARATION.md`.
