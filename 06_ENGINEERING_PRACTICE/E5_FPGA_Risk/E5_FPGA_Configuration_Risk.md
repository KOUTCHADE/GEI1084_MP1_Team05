# E5 — Intégrité de la configuration FPGA et risque système

Équipe 05 — GEI1084 MP1

## 1. Contexte

Le processeur MP1 est implémenté dans un FPGA Artix-7 (classe XC7A35T) d'un contrôleur IoT connecté au réseau. Le FPGA charge sa configuration (bitstream) depuis une mémoire flash SPI à chaque mise sous tension. Le programme applicatif lit une mesure (par exemple une température), la compare à un seuil avec `CMP`, puis écrit à une adresse mémoire-mappée qui commande un actionneur (par exemple un relais de chauffage) avec un `STR` conditionnel.

Séquence conceptuelle : **Mesure → CMP → Flags → CondEx → MemWrite → Actionneur**.

Dans notre HDL, la décision matérielle tient en trois lignes :

```vhdl
-- condlogic.vhd
RegWrite <= RegW and CondEx_internal;
MemWrite <= MemW and CondEx_internal;   -- seule barrière entre le programme et l'actionneur
PCSrc    <= PCS  and CondEx_internal;
```

`CondEx` vient de `condcheck`, qui lit les flags NZCV mémorisés par `flag_registers`, eux-mêmes écrits par `CMP` (FlagW = 11). Toute cette logique **est le bitstream** : changer le bitstream, c'est changer ces équations sans toucher au logiciel.

## 2. Menace

Une personne non autorisée obtient un accès de programmation (port JTAG sur la carte), de maintenance (connecteur de service) ou de mise à jour (canal réseau qui écrit la flash), et installe une configuration modifiée. Il ne s'agit pas de concevoir une attaque ; on suppose seulement que l'accès existe et on analyse ses effets.

## 3. Chaîne de risque (E5.1)

| Étape | Ce qui se passe dans notre processeur |
|---|---|
| 1. Configuration FPGA non autorisée | Un bitstream modifié est écrit dans la flash SPI (ou chargé directement par JTAG) et accepté au démarrage, parce que rien ne vérifie son origine. |
| 2. Logique de contrôle modifiée | Exemple réaliste : `MemWrite <= MemW and (CondEx or Trig)`, où `Trig` vaut 1 pour une adresse ou une valeur précise. Ou bien `condcheck` inverse la condition `LT` quand la mesure dépasse un seuil. Le programme en mémoire n'a pas changé. |
| 3. CMP / Flags / CondEx incorrects ou gating MemWrite contourné | Le programme exécute `CMP R1, R2` (mesure vs limite), puis `STRLT R3, [R4]` (commande seulement si mesure < limite). Avec la logique modifiée, `MemWrite` passe à 1 même si `CondEx = 0`. |
| 4. MemWrite inattendu | Une écriture a lieu vers l'adresse de l'actionneur alors que le processeur d'origine l'aurait bloquée. |
| 5. Commande d'actionneur | Le registre mémoire-mappé met la sortie à « marche ». |
| 6. Conséquence physique | **Conséquence retenue : fonctionnement hors limites.** Le chauffage reste actif au-delà de la consigne. Effets plausibles : surchauffe de l'enceinte, usure accélérée du relais et de l'élément chauffant, produit ou procédé hors spécification, coût de maintenance. Une protection indépendante (thermostat bimétallique de sécurité) limite normalement le pire cas ; si elle est absente, il y a un risque d'incendie. |

Pourquoi c'est difficile à voir : les journaux logiciels montrent la bonne séquence (`CMP`, `STRLT`) et le code applicatif a une signature valide. Seul le comportement matériel a changé. C'est le même type de défaut silencieux que dans E3, mais intentionnel.

## 4. Alternatives de mitigation (E5.2–E5.5)

Distinction utile :
* **confidentialité** : empêcher de lire le design (protège la propriété intellectuelle) ;
* **intégrité** : détecter qu'une image a été modifiée ;
* **authenticité** : vérifier qu'une image vient d'une source autorisée.

Chiffrer donne la confidentialité, pas automatiquement l'authenticité. C'est l'authenticité qui bloque notre menace.

### 4.1 Authenticité / intégrité de la configuration

* **Mécanisme** : la famille 7-series offre le chiffrement AES-256 du bitstream avec authentification HMAC/SHA-256 (DS180 ; UG470 ; XAPP1239). La clé est stockée en eFUSE ou en BBRAM (alimentée par pile). Avec l'authentification, le FPGA refuse un bitstream dont le HMAC est incorrect.
* **Menace adressée** : bitstream modifié ou fabriqué par quelqu'un qui n'a pas la clé.
* **Bénéfice** : c'est la seule mesure qui agit sur l'image elle-même, quel que soit le canal d'arrivée.
* **Limite** : la clé est symétrique et identique pour toute la flotte si on la programme ainsi ; une fuite compromet tous les appareils. Surtout, Ender, Moradi et Paar (USENIX Security 2020, « Starbleed ») ont montré une attaque qui fait perdre **à la fois la confidentialité et l'authenticité** du chiffrement des bitstreams 7-series, en se servant du FPGA comme oracle de déchiffrement ; elle exige un accès à l'interface de configuration (JTAG ou SelectMAP) et vise un défaut du silicium que l'on ne peut pas corriger par mise à jour. On ne peut donc pas présenter le chiffrement 7-series comme une garantie complète.
* **Coût / complexité** : pas de composant supplémentaire en eFUSE ; une pile si BBRAM ; procédure de gestion des clés en production (poste sécurisé, traçabilité). Programmer l'eFUSE est irréversible.
* **Impact opérationnel** : chaque image doit être chiffrée et signée avec la clé ; perdre la clé rend les mises à jour impossibles.

### 4.2 Restriction des accès programmation / debug

* **Mécanisme** : ne pas monter le connecteur JTAG en production (pastilles de test seulement), boîtier scellé avec étiquettes d'inviolabilité, accès service avec authentification. Les bits de configuration 7-series permettent aussi de restreindre la relecture (readback) et, en mode eFUSE, d'imposer le chargement de bitstreams chiffrés seulement (UG470).
* **Menace adressée** : accès physique opportuniste ; chargement direct par JTAG ; condition préalable de l'attaque Starbleed.
* **Bénéfice** : réduit fortement la surface d'attaque, peu coûteux.
* **Limite** : réduire une interface **n'authentifie pas une image**. Quelqu'un qui écrit directement la flash SPI, ou qui passe par le canal de mise à jour réseau, contourne cette mesure.
* **Coût / complexité** : faible (quelques cents ; boîtier).
* **Impact opérationnel** : le diagnostic en usine et le retour SAV exigent un gabarit spécial.

### 4.3 Processus de mise à jour authentifié

* **Mécanisme** : le microcontrôleur réseau de la carte (ou un petit bloc de démarrage) reçoit l'image, vérifie une **signature asymétrique** (par exemple ECDSA P-256) produite par le serveur de l'entreprise, vérifie un numéro de version (pas de retour vers une version vulnérable), écrit dans une zone flash inactive, puis bascule. Chaque mise à jour est journalisée (version, date, empreinte SHA-256).
* **Menace adressée** : mise à jour malveillante à distance, image corrompue en transit, retour en arrière (rollback).
* **Bénéfice** : la clé privée ne quitte jamais le serveur de signature ; une clé publique dans l'appareil ne permet pas de signer. Traçabilité complète de la flotte.
* **Limite** : ne protège pas contre une écriture physique directe de la flash ; repose sur l'intégrité du microcontrôleur qui vérifie.
* **Coût / complexité** : moyen ; un MCU avec démarrage sécurisé est souvent déjà présent pour le réseau ; infrastructure de signature et de versionnage à développer (NRE).
* **Impact opérationnel** : procédure de publication plus lourde, mais elle s'aligne sur la gestion de version de E3.

### 4.4 Récupération / image connue bonne / état sûr

* **Mécanisme** : MultiBoot avec image *golden* de repli dans la flash SPI (XAPP1247 ; UG470). Si le chargement de l'image de mise à jour échoue (erreur de CRC, d'authentification, watchdog de configuration), le FPGA recharge automatiquement l'image golden. Matériel : les sorties actionneur ont des résistances de tirage vers l'état « arrêt » tant que le FPGA n'est pas configuré (broche DONE basse).
* **Menace adressée** : mise à jour corrompue, interrompue (coupure de courant) ou rejetée.
* **Bénéfice** : l'appareil reste utilisable et sûr ; pas de déplacement d'un technicien.
* **Limite** : l'image golden doit elle-même être protégée (zone flash en écriture verrouillée) ; elle peut contenir d'anciens défauts.
* **Coût / complexité** : flash deux fois plus grande (quelques dizaines de cents), logique de repli à valider.
* **Impact opérationnel** : il faut tester le repli en production et à chaque nouvelle version.

## 5. Matrice de comparaison (E5.2–E5.5, 0,75 pt)

| Mitigation | Menace principale | Efficacité attendue | Complexité | Impact coût | Limitation opérationnelle |
|---|---|---|---|---|---|
| Authenticité / intégrité de la configuration (AES-256 + HMAC 7-series) | Bitstream modifié ou fabriqué | Élevée contre un attaquant sans clé ; affaiblie par Starbleed si l'accès JTAG est possible | Moyenne (gestion des clés) | Faible en BOM ; NRE de procédure | Clé partagée par la flotte ; eFUSE irréversible |
| Restriction programmation / debug | Accès JTAG ou connecteur de service | Moyenne : bloque l'opportuniste, pas l'écriture directe de la flash | Faible | Très faible | SAV plus difficile |
| Mise à jour authentifiée (signature asymétrique + versions) | Mise à jour réseau malveillante, rollback | Élevée sur le canal à distance | Moyenne à élevée | Faible en BOM ; NRE élevé (infrastructure) | Publication plus lourde ; dépend du MCU |
| Recovery / image golden / état sûr | Mise à jour corrompue ou rejetée | Élevée pour la disponibilité et la sûreté ; ne bloque pas l'attaque | Moyenne | Faible (flash plus grande) | Repli à tester à chaque version |

## 6. Recommandation (0,75 pt)

Pour un produit IoT bas coût, par ordre de priorité :

1. **Protection primaire : mise à jour authentifiée par signature asymétrique.** Le canal réseau est la voie d'attaque la plus probable et la plus massive (toute la flotte d'un coup). La signature est vérifiée avant d'écrire la flash.
2. **Défense complémentaire : chiffrement + authentification HMAC du bitstream, clé en eFUSE, chargement chiffré obligatoire, readback désactivé, JTAG non monté.** Elle couvre l'écriture directe de la flash. Les deux mesures se renforcent : Starbleed demande l'accès à l'interface de configuration, que la restriction physique rend plus difficile.
3. **Mécanisme de mise à jour** : double image (golden + mise à jour), numéro de version monotone, journal.
4. **Récupération** : repli automatique MultiBoot vers l'image golden ; sorties actionneur à l'arrêt par défaut.
5. **Hors FPGA** : garder une protection physique indépendante (thermostat de sécurité). Elle ne dépend d'aucun bitstream.

Coût accepté : quelques dizaines de cents de BOM (flash plus grande, résistances de tirage) et un NRE d'infrastructure de signature (estimé dans E6). Ce compromis est adapté à un produit bas coût, car l'essentiel du coût est non récurrent.

## 7. Que fait le système si la mise à jour échoue ? (0,50 pt)

* **Signature invalide** : l'image est **rejetée** avant d'être écrite ; l'appareil continue avec l'image actuelle et signale l'échec au serveur.
* **Écriture interrompue ou image corrompue** : au redémarrage, le FPGA détecte l'erreur (CRC/HMAC) et **revient à l'image golden** connue bonne.
* **Aucune image de confiance ne charge** : le FPGA reste non configuré ; les sorties actionneur restent **inactives** grâce aux résistances de tirage, jusqu'à l'intervention d'un technicien autorisé. On préfère un appareil arrêté à un appareil qui commande l'actionneur sans contrôle.

## 8. Impacts coût / complexité

Voir E6, section 7 : la flash double image et la gestion des clés sont conservées dans le BOM ; elles ne doivent pas être supprimées pour atteindre la cible de 30 $ sans analyse de risque.

## 9. Références

1. AMD, *7 Series FPGAs Data Sheet: Overview*, DS180 (v2.6.1) — chiffrement AES-256 avec authentification HMAC/SHA-256. https://docs.amd.com/v/u/en-US/ds180_7Series_Overview
2. AMD, *7 Series FPGAs Configuration User Guide*, UG470 (v1.17, 5 décembre 2023) — chap. 5 « Configuration Details » : *Bitstream Security* (p. 89) et *eFUSE* (p. 94) ; chap. 7 « Reconfiguration and MultiBoot » : *Fallback MultiBoot* (p. 133) et *Watchdog* (p. 140) ; tableau 1-1 : taille du bitstream.
3. AMD, *Using Encryption to Secure a 7 Series FPGA Bitstream*, XAPP1239 (v1.2, 26 mars 2021). https://docs.amd.com/v/u/en-US/xapp1239-fpga-bitstream-encryption
4. AMD, *MultiBoot with 7 Series FPGAs and SPI*, XAPP1247 (v1.1, 28 février 2017). https://docs.amd.com/v/u/en-US/xapp1247-multiboot-spi
5. AMD, *Vivado Design Suite User Guide: Programming and Debugging*, UG908 — section « Generating Encrypted and Authenticated Files for 7 Series Devices » (clé AES de 256 bits, clé d'authentification HMAC, clé en BBRAM ou eFUSE).
6. M. Ender, A. Moradi, C. Paar, « The Unpatchable Silicon: A Full Break of the Bitstream Encryption of Xilinx 7-Series FPGAs », USENIX Security 2020. https://www.usenix.org/conference/usenixsecurity20/presentation/ender
7. Ruhr-Universität Bochum, communiqué « Critical Starbleed vulnerability in FPGA chips identified », 2020-04-16.
