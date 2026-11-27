# E6 — Décision produit FPGA sous contrainte de coût

Équipe 05 — GEI1084 MP1

> Modèle de premier ordre. Chaque valeur porte une étiquette : **[M]** mesurée / relevée, **[R]** recherchée (source citée), **[S]** supposée (hypothèse raisonnable, à justifier). Les prix sont en dollars US, relevés en novembre 2026.

## 1. Hypothèses produit

| Hypothèse | Valeur |
|---|---|
| Produit | Contrôleur IoT connecté : une mesure analogique/numérique, un actionneur mémoire-mappé (relais), lien Wi-Fi |
| Cœur | Processeur MP1 (Lab 4 + CMP + LSL/LSR + BL) dans un FPGA Artix-7 XC7A35T, boîtier CPG236 |
| Volume | ≈ 1000 unités/an ; on évalue N = 100, 1000, 5000 |
| Cible | Coût matériel récurrent < 30 $/unité |
| Hors périmètre | Boîtier plastique, alimentation externe, logiciel du serveur, marge commerciale |
| Sécurité conservée | Flash double image (golden + mise à jour), clé eFUSE, sorties à l'arrêt par défaut (voir E5) |

## 2. Classification des dépenses (E6.1)

| Non récurrent (NRE) — payé une fois | Récurrent — payé à chaque unité |
|---|---|
| Heures d'ingénierie HDL, vérification, debug | FPGA |
| Conception du PCB, revues | Mémoire flash de configuration |
| Prototypes (cartes, composants) | PCB nu |
| Développement du test de production (gabarit, scripts) | Alimentation (régulateurs), horloge |
| Firmware réseau et infrastructure de mise à jour signée | Module réseau, I/O, connecteurs, passifs |
| Documentation, préparation de production | Assemblage, programmation, test de production |
| Outils et licences, essais CEM | Rebut, étiquetage, emballage |

## 3. NRE (E6.1)

Formule du guide : **C_NRE = H_eng × R_eng + C_prototype + C_tools**

Taux chargé supposé : **R_eng = 95 $/h** [S] (salaire d'un ingénieur junior au Québec plus charges et frais généraux ; à ajuster).

| Activité | Heures | Taux | Coût |
|---|---:|---:|---:|
| Nettoyage du HDL étudiant, contraintes de timing, synthèse sur cible réelle | 60 | 95 $ | 5 700 $ |
| Vérification et régression (étendre C/S/B/R, tests au niveau carte) | 120 | 95 $ | 11 400 $ |
| Conception du PCB 4 couches et revues | 80 | 95 $ | 7 600 $ |
| Firmware réseau, mise à jour signée, MultiBoot (E5) | 80 | 95 $ | 7 600 $ |
| Développement du test de production | 40 | 95 $ | 3 800 $ |
| Documentation et préparation de production | 30 | 95 $ | 2 850 $ |
| Gestion de projet, revues de conception | 30 | 95 $ | 2 850 $ |
| **Sous-total ingénierie (H_eng × R_eng)** | **440** | | **41 800 $** |
| Prototypes : 2 itérations × 5 cartes (PCB, composants, assemblage rapide) [S] | | | 3 000 $ |
| Essais CEM / certification (module radio précertifié, essais d'émissions de la carte) [S] | | | 8 000 $ |
| **Sous-total C_prototype** | | | **11 000 $** |
| Vivado ML Standard (gratuit pour les petits Artix-7) [R, à vérifier pour la version utilisée] | | | 0 $ |
| Sonde JTAG de production [S] | | | 300 $ |
| Gabarit de test (lit à pointes) [S] | | | 1 500 $ |
| **Sous-total C_tools** | | | **1 800 $** |
| **C_NRE total** | | | **54 600 $** |

Le NRE n'est pas nul même si le processeur existe déjà : le passage d'un projet étudiant à un produit exige nettoyage, validation sur matériel réel, intégration réseau et préparation de la production.

## 4. BOM récurrent (E6.2)

Prix unitaires selon le volume ; le prix baisse avec les ruptures de quantité des distributeurs et des assembleurs.

| Poste | Qté | N = 100 | N = 1000 | N = 5000 | Source / hypothèse |
|---|---:|---:|---:|---:|---|
| FPGA XC7A35T-1CPG236C | 1 | 46,00 | 35,00 | 30,00 | [R] FindChips (nov. 2026) : offres de 25,68 $ à 51,87 $ ; LCSC « à partir de » 24,84 $ (rupture de stock). Valeur centrale prudente. |
| Flash SPI 32 Mb (golden + mise à jour) | 1 | 0,70 | 0,50 | 0,40 | Taille [R] : bitstream XC7A35T = 17 536 096 bits (UG470 v1.17, tableau 1-1), donc deux images demandent 32 Mb (UG470 donne 32 Mb comme taille minimale de flash pour une image). Prix [S] : flash NOR série courante |
| Alimentation : 3 rails (1,0 V cœur, 1,8 V aux, 3,3 V I/O) | 1 lot | 3,50 | 3,00 | 2,60 | [S] Régulateurs à découpage + LDO |
| Oscillateur 100 MHz | 1 | 1,00 | 0,80 | 0,60 | [S] |
| Module Wi-Fi précertifié (ESP32-C3-MINI-1-N4) | 1 | 2,60 | 2,25 | 2,10 | [R] Digi-Key (26 nov. 2026) : 3,36 SGD à 100, 2,90 SGD à 1300, 2,71 SGD à 4550 ; converti au taux supposé 1 SGD ≈ 0,77 $ US [S]. Il sert aussi de vérificateur de mise à jour (E5) |
| Pilote d'actionneur + protection des I/O | 1 lot | 1,80 | 1,50 | 1,30 | [S] |
| Connecteurs (alim, actionneur, capteur, pastilles JTAG) | 1 lot | 1,50 | 1,20 | 1,00 | [S] |
| Passifs (≈ 80 composants) | 1 lot | 1,50 | 1,00 | 0,80 | [S] |
| PCB 4 couches ≈ 50 × 50 mm | 1 | 6,00 | 2,50 | 1,80 | [S] Devis typique de fabricant asiatique |
| Assemblage (BGA + CMS, deux faces) | 1 | 8,00 | 4,00 | 3,20 | [S] Les frais fixes de mise en route pèsent beaucoup à 100 unités |
| Programmation + test de production | 1 | 2,50 | 1,50 | 1,20 | [S] ≈ 1 min de banc par carte |
| Divers : rebut 3 %, étiquettes, emballage | — | 2,00 | 1,50 | 1,20 | [S] |
| **C_recurring / unité** | | **77,10 $** | **54,75 $** | **46,20 $** | |

Les postes encore marqués [S] (PCB, assemblage, passifs, connecteurs, alimentation) sont des estimations de l'équipe : ils représentent moins de 30 % du BOM à N = 1000 et ne changent pas la décision de la section 6, dominée par le prix du FPGA relevé [R].

## 5. Amortissement par volume (E6.3)

**C_effective/unit = C_recurring/unit + C_NRE / N**, avec C_NRE = 54 600 $.

| N | Coût récurrent/unité | NRE/unité | Coût effectif/unité |
|---:|---:|---:|---:|
| 100 | 77,10 $ | 546,00 $ | 623,10 $ |
| 1000 | 54,75 $ | 54,60 $ | 109,35 $ |
| 5000 | 46,20 $ | 10,92 $ | 57,12 $ |

Interprétation :

* La part de NRE décroît en 1/N : le même montant est réparti sur plus d'unités. Entre 100 et 5000 unités, elle passe de 546 $ à 11 $.
* Le coût récurrent ne disparaît pas : chaque unité consomme un FPGA, un PCB, un assemblage. Il baisse un peu avec le volume (ruptures de prix), mais tend vers un plancher dominé par le FPGA.
* Les deux nombres ne répondent pas à la même question. Le **coût récurrent** dit si le produit peut être vendu avec une marge à long terme. Le **coût effectif** dit combien chaque unité coûte réellement à l'entreprise pour une série donnée, développement compris.

## 6. Décision face à 30 $ (E6.4)

```
Coût matériel récurrent estimé : 54,75 $/unité (N = 1000)
Cible                          : < 30,00 $/unité
Décision                       : NON ATTEINTE
```

* **Écart** : +24,75 $ (83 % au-dessus de la cible).
* **Poste dominant** : le FPGA, 35 $ sur 54,75 $, soit **64 %** du BOM. À lui seul, il dépasse la cible.
* **Sensibilité** : même au prix le plus bas relevé (≈ 25 $), le BOM serait ≈ 45 $. Même à 5000 unités, il reste à 46,20 $. Le résultat ne dépend donc pas de nos hypothèses incertaines sur les petits postes.
* **Conclusion** : l'Artix-7 XC7A35T est un bon choix de prototype (outils du cours, logique largement suffisante), mais pas de produit à 30 $.

## 7. Alternatives (E6.5)

Estimations à N = 1000.

| Alternative | Impact coût récurrent | Impact NRE | Risque technique | Flexibilité | Recommandation |
|---|---|---|---|---|---|
| A. FPGA plus petit, même écosystème : Spartan-7 XC7S15 ou Artix-7 XC7A12T (12 800 cellules logiques, DS180) | FPGA [R] Digi-Key (26 nov. 2026) : XC7S15-1CPGA196C 26,72 $ (qté 1, aucun stock, livraison prévue juillet 2027) ; XC7A12T-1CPG238C 36,57 $ (qté 11) → BOM ≈ 47–57 $ | + ≈ 40 h (resynthèse, timing, revalidation) ≈ 3 800 $ | Faible : même outil Vivado, même HDL ; le processeur MP1 est petit | Conservée (matériel reconfigurable) | **Non retenue** : un 7-series plus petit coûte presque autant que le XC7A35T, et la disponibilité est mauvaise. Le gain de coût est négligeable. |
| B. Réduction du BOM non essentiel (régulateur multi-rails intégré, PCB plus petit, connecteurs regroupés) | − 2 à 4 $ → BOM ≈ 51–53 $ avec l'Artix-7 | + ≈ 30 h de PCB ≈ 2 900 $ | Moyen : marge thermique et bruit d'alimentation à revalider | Inchangée | Utile en complément de C ou D, mais insuffisante seule : l'écart vient du FPGA |
| C. Autre plateforme : microcontrôleur Wi-Fi seul (type ESP32-C3), le programme applicatif tourne en logiciel | Retire FPGA, flash externe, oscillateur, 2 rails, BGA → BOM ≈ 14 $ | + ≈ 120 h ≈ 11 400 $ (réécrire la logique en firmware, nouvelle validation) | Moyen : nouveau code, mais technologie très répandue | Mise à jour logicielle facile ; perte de l'architecture matérielle personnalisée | **Recommandée pour le produit** si le processeur MP1 n'est pas lui-même la valeur du produit. Démarrage sécurisé et chiffrement de la flash à vérifier dans la documentation du fabricant. |
| D. Famille FPGA moins chère : Lattice iCE40 UltraPlus (ICE40UP5K-SG48I, 5280 LUT, boîtier QFN 48) | FPGA [R] Digi-Key.ca (26 nov. 2026) : 16,72 CAD à 2000 (20,47 CAD à l'unité), soit ≈ 12 $ US au taux supposé 1 CAD ≈ 0,72 $ US [S] ; pas de BGA, oscillateur interne → BOM ≈ 31 $ | + ≈ 120 h (nouvel outil, portage, contraintes) ≈ 11 400 $ | Moyen à élevé : nouvel outil ; capacité de 5280 LUT à confirmer par synthèse ; fonctions de sécurité différentes | Conservée | Seule option FPGA proche de 30 $ ; exige une synthèse d'essai et une nouvelle analyse E5 avant de s'engager |

On ne choisit pas uniquement sur le prix du composant : C est la moins chère, mais elle supprime la reconfigurabilité matérielle et exige une revalidation complète ; A est la plus sûre techniquement, mais les prix relevés montrent qu'elle ne réduit presque pas le coût.

## 8. Raisonnement cycle de vie (E6.6)

**C_lifecycle = C_NRE + C_production + C_maintenance + C_support + C_redesign**

* **Corrections de bugs** : un défaut comme celui de E3 exige une nouvelle version, une régression et une mise à jour de la flotte. Avec FPGA ou MCU, la correction se fait à distance, à condition que le mécanisme de mise à jour signée (E5) existe. Sans lui, chaque correction coûte un déplacement (≈ 50–100 $ par unité [S]).
* **Correctifs de sécurité** : Starbleed (E5) est un défaut du silicium 7-series qu'aucune mise à jour ne corrige. Cela pèse sur la durée de vie du produit : la protection repose sur l'accès physique restreint, pas sur le chiffrement seul.
* **Test de production** : le gabarit et les tests C/S/B/R automatisés sont réutilisés à chaque version ; ils réduisent le coût de régression.
* **Disponibilité / obsolescence** : les familles 7-series ont une longue durée de production annoncée par AMD, mais les prix et délais ont fortement varié depuis 2021 (rupture de stock observée chez LCSC en nov. 2026). Un second fournisseur ou une alternative qualifiée réduit le risque de redesign forcé.
* **Récupération après mise à jour** : l'image golden évite les retours SAV en cas de mise à jour interrompue.
* **Redesign** : passer plus tard d'Artix-7 à MCU coûterait le NRE de C en plus du NRE déjà dépensé ; il vaut mieux décider avant la production.

## 9. Lien risque / maintenabilité (E6.7)

* Supprimer la **flash double image** économiserait ≈ 0,20 $, mais retirerait la récupération (E5 §7) : une mise à jour interrompue rendrait l'appareil inutilisable. **Conservée.**
* Ne pas programmer l'**eFUSE** ou ne pas gérer les clés économise du temps de production, mais rend le bitstream modifiable par quiconque accède à la flash. **Conservé.**
* Supprimer les **pastilles JTAG** réduit l'accès de service ; on garde des pastilles (pas de connecteur) pour le diagnostic en usine.
* Réduire l'**infrastructure de régression** pour diminuer le NRE augmenterait le risque de défauts silencieux comme E3. **Conservée.**
* Avec l'alternative C, la sécurité repose sur le démarrage sécurisé du MCU : l'analyse E5 doit être refaite.

## 10. Recommandation finale

1. **Prototype et validation** : rester sur l'Artix-7 XC7A35T (outils du cours, marge de logique, sécurité documentée).
2. **Produit à 1000 unités/an** : la cible de 30 $ n'est **pas atteinte** avec l'Artix-7 (≈ 55 $), et un 7-series plus petit ne règle pas le problème (prix relevés ≈ 27–37 $). Si le client a seulement besoin d'un contrôleur, passer à l'alternative **C (MCU, ≈ 14 $)**. Si le matériel reconfigurable est une exigence, viser **D (iCE40 UltraPlus, ≈ 31 $)**, complétée par B, et confirmer par une synthèse d'essai et un devis avant de s'engager.
3. Dans tous les cas, garder les mesures E5 (mise à jour signée, image golden, sorties à l'arrêt par défaut) : elles coûtent peu en BOM et protègent le coût de cycle de vie.

## 11. Sources

| Entrée | Source | Date / volume | Type |
|---|---|---|---|
| Prix XC7A35T-1CPG236C | FindChips, https://www.findchips.com/detail/XC7A35T-1CPG236C (offres 25,68–51,87 $) | nov. 2026, quantité non précisée | [R] |
| Prix XC7A35T-1CPG236C | LCSC C1521738, « à partir de » 24,84 $, en rupture | nov. 2026 | [R] |
| Capacité XC7S15, XC7A12T, XC7A35T | AMD DS180 v2.6.1, tableaux 2 et 4 | — | [R] |
| Taille du bitstream XC7A35T | AMD UG470 v1.17 (5 déc. 2023), tableau 1-1 : 17 536 096 bits | — | [R] |
| Taux horaire, heures, PCB, assemblage, passifs | Hypothèses de l'équipe | — | [S] |
| Prix XC7S15-1CPGA196C, XC7A12T-1CPG238C | Digi-Key, pages produit 9380258 et 8628412 | 26 nov. 2026 ; qté 1 et 11 | [R] |
| Prix ICE40UP5K-SG48I | Digi-Key Canada, page produit 7785190 (en CAD) | 26 nov. 2026 ; qté 1 et 2000 | [R] |
| Prix ESP32-C3-MINI-1-N4 | Digi-Key Singapour, page produit 13877574 (en SGD) | 26 nov. 2026 ; qté 100 à 4550 | [R] |
| Taux de change CAD et SGD vers USD | Hypothèse de l'équipe (ordre de grandeur) | — | [S] |
