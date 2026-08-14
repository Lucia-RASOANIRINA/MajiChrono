# MajiChrono — application mobile Flutter

Refonte Flutter de l'application mobile MajiChrono, plateforme de livraison à la
demande pour Madagascar.

Ce dépôt met en oeuvre le cahier des charges
`MajiChrono_Cahier_des_Charges_Mobile_Flutter.md` version 1.0. Les références
`§x.y` et `EXI-xx##` qui apparaissent dans ce document et dans les commentaires
du code renvoient à ce cahier des charges.

---

## Sommaire

1. [Démarrer](#1-démarrer)
2. [Les trois profils](#2-les-trois-profils)
3. [Architecture](#3-architecture)
4. [Le backend simulé](#4-le-backend-simulé)
5. [Règles de conception](#5-règles-de-conception)
6. [Avancement par module](#6-avancement-par-module)
7. [Détail des tâches par module](#7-détail-des-tâches-par-module)
8. [Tests](#8-tests)
9. [Environnement de développement](#9-environnement-de-développement)
10. [Décisions à arbitrer](#10-décisions-à-arbitrer)

---

## 1. Démarrer

### Prérequis

| Élément | Version | Remarque |
|---|---|---|
| Flutter | 3.44 ou plus, canal stable | Dart 3.12 |
| JDK | 21 | Celui d'Android Studio (`jbr`). Voir §9. |
| Android SDK | API 35 pour compiler | Minimum d'exécution : API 26 |

### Installation

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

### Lancer

```bash
# Backend simulé — mode par défaut, aucun serveur requis
flutter run --dart-define=API_MODE=mock

# Backend réel, le jour où il existe
flutter run --dart-define=API_MODE=live \
            --dart-define=API_BASE_URL=https://api.majichrono.mg/v2
```

### Vérifier

```bash
flutter analyze
flutter test
```

---

## 2. Les trois profils

Une application unique sert trois populations. Le profil détermine la coquille
de navigation et les écrans accessibles.

| Profil | Nom dans l'interface | Ce qu'il fait |
|---|---|---|
| Expéditeur | Client | Crée une course, suit son colis, paie, note le livreur |
| Livreur | Livreur | Accepte, exécute, produit les constats, encaisse |
| Exploitation | Administrateur | Valide les KYC, supervise la flotte, arbitre les litiges |

Un quatrième acteur n'installe rien : le **destinataire**. Il reçoit un lien de
suivi par SMS et signe à la remise sur l'écran du livreur.

Le profil administrateur n'est jamais choisi par l'utilisateur : il est attribué
côté serveur (EXI-T02).

---

## 3. Architecture

Découpage en quatre couches, conforme au §8.1. La règle de dépendance est
stricte : **une couche ne connaît que celle du dessous, et le domaine ne connaît
personne**. Toute violation est bloquante en revue.

```
Présentation    écrans, widgets, contrôleurs
      |
Domaine         entités, cas d'usage, interfaces      (aucune dépendance externe)
      |
Données         implémentations, sources, DTO
      |
Socle           réseau, stockage, journaux, i18n
```

### Organisation des fichiers

```
lib/
  main.dart, bootstrap.dart     amorçage, injection des dépendances prêtes
  app/
    router/                     go_router, redirections par profil
    theme/                      jetons, palette, thèmes clair et sombre
    shell/                      coquille commune aux trois profils
  core/
    config/                     configuration injectée à la compilation
    error/                      hiérarchie de Failure typées
    i18n/                       bascule français / malgache à chaud
    logging/                    journal circulaire, expurgation
    network/                    client HTTP, intercepteurs, sonde, transport simulé
    providers/                  injection Riverpod du socle
    session/                    profil actif
    storage/                    base drift, stockage sécurisé, préférences
  features/
    <fonctionnalité>/           chacune en data/ · domain/ · presentation/
  shared/                       composants et utilitaires transverses
  l10n/arb/                     traductions français et malgache
```

### Choix techniques

| Domaine | Choix | Motif |
|---|---|---|
| État et injection | Riverpod 2 | Testable sans widget, un seul mécanisme |
| Navigation | go_router | Liens profonds requis par EXI-N04 et EXI-C24 |
| Réseau | dio | Intercepteurs, reprise, annulation |
| Base locale | drift, SQLite en mode WAL | SQL réel, migrations versionnées, requêtes réactives |
| Secrets | flutter_secure_storage | Keystore Android, Keychain iOS |
| Traductions | ARB, deux langues | Français et malgache |

---

## 4. Le backend simulé

Le §12 du cahier des charges décrit le contrat d'interface du backend, mais ce
backend n'existe pas encore. Plutôt que d'attendre, le socle embarque un
transport simulé.

Le point important est l'endroit où la simulation se branche. `MockHttpAdapter`
remplace le `HttpClientAdapter` de dio, c'est-à-dire l'octet qui part sur le
réseau, et rien d'autre. Toute la pile réelle est traversée à l'identique :
intercepteur d'idempotence, compteur de données, journalisation expurgée,
traduction des erreurs.

Trois conséquences :

- passer de `mock` à `live` ne change aucune ligne hors du socle ;
- les chemins consommés sont les constantes de `ApiEndpoints`, donc exactement
  ceux du §12.2 ;
- le simulateur reproduit le réseau malgache décrit au §4.1 : latence par profil
  (4G, 3G, 2G), temps de transfert proportionnel au débit, coupures injectées.

Ce dernier point rend jouables les scénarios de recette obligatoires du §16.2
sans quitter le bureau. Le **panneau développeur**, accessible par l'icône en
forme d'insecte ou par Réglages, pilote le profil réseau et le taux d'échec.

Chaque module métier enregistre ses propres routes simulées au moyen d'un
`MockModule`, sans toucher au socle.

---

## 5. Règles de conception

Reprises du §9.3 du cahier des charges. Elles sont vérifiées en revue, et pour
certaines par des tests automatiques.

| Règle | Vérification |
|---|---|
| Aucune logique métier dans un widget | Revue |
| Aucun appel réseau depuis la présentation, toujours via un cas d'usage | Revue |
| Toute écriture passe par la file de synchronisation, jamais par le réseau | Revue |
| Toute erreur est typée, aucun message technique affiché | `error_mapper_test.dart` |
| Tout texte affiché vient des fichiers ARB | `no_literal_strings_test.dart` |
| Une dépendance de plus de 2 Mo doit être justifiée | Revue |

---

## 6. Avancement par module

Chaque module est construit, testé sur émulateur, puis validé avant le suivant.

| Module | Objet | Lot du cahier des charges | État |
|---|---|---|---|
| 0 | Socle technique et coquille navigable | Lot 0 | Livré |
| 1 | Authentification et session | Lot 1 | Livré |
| 2 | Expéditeur : création de course | Lot 1 | Livré |
| 3 | Suivi cartographique et notifications | Lot 1 | Livré, sauf notifications |
| 4 | Livreur : KYC, file, progression | Lot 2 | À faire |
| 5 | Chaîne de responsabilité et preuve | Lot 2 | À faire |
| 6 | Mode hors ligne intégral | Lot 2 | À faire |
| 7 | Paiement délégué à MajiPay | Lot 3 | À faire |
| 8 | Supervision depuis mobile | Lot 4 | À faire |
| 9 | Différenciants concurrentiels | Lot 5 | À faire |
| 10 | Durcissement et recette terrain | Lot 6 | À faire |

Le module 5 est le coeur différenciant du produit. C'est lui qui produit la
preuve opposable qu'aucun concurrent local ne fournit aujourd'hui (§3.3).

---

## 7. Détail des tâches par module

La colonne **Profil** indique qui utilise la fonction : *Transverse* désigne ce
qui sert les trois profils.

### Module 0 — Socle technique (livré)

| Tâche | Profil | Exigences | État |
|---|---|---|---|
| Projet Flutter, découpage en quatre couches, organisation par fonctionnalité | Transverse | §8.1, §8.2 | Fait |
| Design system : jetons, palette, thèmes clair et sombre, composants partagés | Transverse | §15.1 | Fait |
| Bascule français / malgache à chaud, sans redémarrage | Transverse | EXI-T05 | Fait |
| Libellés intégrés de Flutter en malgache, repli français | Transverse | Critère 7 du §18 | Fait |
| Bandeau permanent d'état réseau, au-dessus de tout écran empilé | Transverse | EXI-T06 | Fait |
| Sonde applicative réelle, qualification du profil réseau par temps de réponse | Transverse | §9.2, EXI-C20 | Fait |
| Compteur de données consommées, ventilé par usage | Transverse | EXI-T07, D8 | Fait |
| Client HTTP, intercepteurs, clé d'idempotence stable entre reprises | Transverse | EXI-S01, EXI-B01 | Fait |
| Transport simulé reproduisant 4G, 3G, 2G et coupure | Transverse | §4.1, §16.2 | Fait |
| Hiérarchie d'erreurs typées et restitution en langage courant | Transverse | §9.3, §15.2 | Fait |
| Journal local circulaire, expurgé des données personnelles | Transverse | EXI-T10, EXI-P10 | Fait |
| Base locale drift en mode WAL, table de file de synchronisation | Transverse | EXI-P08, §10.2 | Fait |
| Stockage sécurisé des secrets au Keystore | Transverse | EXI-SEC03 | Fait |
| Routage, redirections par profil, cloisonnement des routes | Transverse | EXI-N04 | Fait |
| Coquille navigable des trois profils | Transverse | §2.1 | Fait |
| Panneau développeur pilotant le réseau simulé | Transverse | §16.2 | Fait |
| Configuration Android : API 26 minimum, HTTPS exclusif, obfuscation | Transverse | EXI-P09, EXI-SEC01, EXI-SEC09 | Fait |

Reste ouvert sur ce module : l'épinglage de certificat à double empreinte
(EXI-SEC02), qui attend le certificat de production, et sera posé au module 10.

### Module 1 — Authentification et session (livré)

| Tâche | Profil | Exigences | État |
|---|---|---|---|
| Saisie et normalisation du numéro malgache `+261 3x xx xxx xx` | Transverse | EXI-T01 | Fait |
| Détection de l'opérateur par préfixe : Orange, Airtel, YAS | Transverse | EXI-T01, M11 | Fait |
| Code OTP à 6 chiffres, validité 5 minutes, 3 tentatives, usage unique | Transverse | EXI-T01 | Fait |
| Renvoi de code et compte à rebours d'expiration | Transverse | EXI-T01 | Fait |
| Choix du profil client ou livreur, définitif | Transverse | EXI-T02 | Fait |
| Refus serveur du profil exploitation réclamé par le mobile | Transverse | EXI-T02 | Fait |
| Jeton d'accès 15 minutes, rafraîchissement 30 jours, rotation à chaque usage | Transverse | EXI-T03 | Fait |
| Rejeu automatique d'une requête après expiration du jeton | Transverse | EXI-T03 | Fait |
| Rafraîchissement partagé : deux expirations simultanées, une seule rotation | Transverse | EXI-T03 | Fait |
| Code PIN à 4 chiffres, dérivé et jamais stocké en clair | Transverse | EXI-T04 | Fait |
| Compteur de tentatives : cinq échecs détruisent le verrou | Transverse | EXI-T04 | Fait |
| Déverrouillage biométrique quand l'appareil le permet | Transverse | EXI-T04 | Fait |
| Verrouillage automatique après 5 minutes d'inactivité | Livreur, Exploitation | EXI-SEC07 | Fait |
| Session et compte relus au démarrage, y compris sans réseau | Transverse | EXI-T03, EXI-P07 | Fait |
| Déconnexion : effacement complet des données de l'appareil | Transverse | EXI-SEC10 | Fait |
| Navigation entièrement pilotée par l'état de session | Transverse | EXI-T02 | Fait |

**Numéros de recette.** Le backend simulé pré-inscrit trois comptes, qui évitent
de rejouer le choix de profil et donnent accès au profil exploitation, que
l'inscription mobile ne peut pas produire :

| Numéro | Profil | Nom |
|---|---|---|
| `034 00 000 01` | Expéditeur | Hery Rakoto |
| `033 00 000 02` | Livreur | Naina Andria |
| `032 00 000 03` | Exploitation | Miora Rasoa |

Tout autre numéro valide crée un compte neuf et passe par le choix de profil.
En mode simulé, le code OTP est affiché à l'écran dans un encart signalé : sans
passerelle SMS, c'est le seul moyen de dérouler le parcours.

**Deux points de conception à connaître.**

Le §12.2 ne prévoit aucun point d'entrée d'inscription : le cycle de session
s'arrête à `otp/request`, `otp/verify`, `refresh` et `logout`. Plutôt que
d'ajouter une route hors contrat, l'inscription se fait en deux temps sur les
routes existantes — la vérification OTP ouvre une session, puis `PATCH /me` pose
le profil. Un compte tout juste créé existe donc réellement, mais sans profil.

Le profil fait partie des informations portées par le jeton. Le modifier sans
réémettre la session laisserait circuler un jeton qui contredit le compte : le
serveur croirait le profil posé, le jeton dirait le contraire, et une seconde
tentative de choix passerait au travers du contrôle. Toute donnée d'identité qui
change entraîne donc une rotation des jetons.

### Module 2 — Expéditeur : création de course (livré)

| Tâche | Profil | Exigences | État |
|---|---|---|---|
| Adresse composite : point GPS, quartier, point de repère, téléphone | Expéditeur | EXI-C02 | Fait |
| Repère et téléphone obligatoires, rue et numéro facultatifs | Expéditeur | EXI-C02, D3 | Fait |
| Carnet d'adresses avec favoris nommés, tri par usage | Expéditeur | EXI-C05 | Fait |
| Type de course : standard, document, fragile, alimentaire | Expéditeur | EXI-C06 | Fait |
| Déclaration du colis : catégorie de poids, valeur, description | Expéditeur | EXI-C08 | Fait |
| Estimation de prix ventilée, affichée avant confirmation | Expéditeur | EXI-C10 | Fait |
| Créneau immédiat ou programmé par tranche de 2 heures | Expéditeur | EXI-C11 | Fait |
| Création de course entièrement hors ligne | Expéditeur | EXI-C13 | Fait |
| Course non transmise signalée explicitement dans la liste | Expéditeur | EXI-C13 | Fait |
| Historique consultable hors ligne | Expéditeur | EXI-C33 | Fait |
| Annulation avant prise en charge | Expéditeur | EXI-C26 | Fait |
| Mode de paiement : espèces par défaut | Expéditeur | EXI-C40 | Fait |
| Photo de façade et note vocale d'itinéraire | Expéditeur | EXI-C03, EXI-C04 | Module 5 |
| Photo du colis à la création | Expéditeur | EXI-C09 | Module 5 |
| Saisie d'adresse par carte et position actuelle | Expéditeur | EXI-C01 | Module 3 |
| Achat pour compte | Expéditeur | EXI-C06, D5 | Module 9 |
| Point relais | Expéditeur | D6 | Module 9 |
| Reçu partageable en PDF | Expéditeur | EXI-C34 | Module 7 |

**Ce qui a été volontairement reporté, et pourquoi.** Trois exigences de ce
module demandent la caméra — photo de façade, photo du colis, et plus tard les
photos guidées des constats. Toute la chaîne photo est un bloc cohérent :
capture dans l'application uniquement, compression à 200 Ko, horodatage et
position, stockage chiffré. La découper en deux reviendrait à construire ce
pipeline deux fois. Elle est donc traitée d'un seul tenant au module 5. De même,
la saisie d'adresse par carte attend `flutter_map` au module 3 ; le modèle porte
déjà le point GPS, de sorte que l'arrivée de la carte ne touchera pas le
formulaire.

**L'adresse est le différenciant D3, et sa forme le montre.** L'ordre des champs
n'est pas cosmétique : quartier, puis point de repère, puis téléphone — les
trois obligatoires — et la rue tout en bas, explicitement marquée facultative.
Un formulaire qui commencerait par « rue et numéro » inviterait l'utilisateur à
remplir le champ le moins utile et à bâcler celui dont le livreur a réellement
besoin. À Madagascar, l'adresse s'énonce « Ambohipo, après l'épicerie Tsiky,
portail vert, appeler en arrivant » (§4.3).

**Le prix est provisoire, et l'application le dit.** La décision DO-3 du §19.2 —
modèle de commission et grille tarifaire — n'est pas arbitrée. L'estimation
affiche donc une mention explicite : annoncer un prix ferme issu d'une hypothèse
serait promettre à l'expéditeur un montant que l'exploitation ne tiendra pas. La
grille est isolée dans une classe paramétrée, de sorte qu'une grille servie par
le serveur la remplacera sans toucher au calcul ni aux écrans.

**La distance est majorée d'un facteur de détour de 1,35.** Les rues
d'Antananarivo ne vont pas en ligne droite ; retenir la distance à vol d'oiseau
reviendrait à sous-payer le livreur. Ce facteur disparaîtra au module 3, quand
un calcul d'itinéraire réel sera disponible.

### Module 3 — Suivi et notifications (livré, sauf notifications)

| Tâche | Profil | Exigences | État |
|---|---|---|---|
| Cache de tuiles sur disque, 150 Mo sur 30 jours glissants | Expéditeur | §9.2, §10.1 | Fait |
| Tuiles imputées au poste « cartes » du compteur de données | Transverse | EXI-T07 | Fait |
| Dégradation annoncée quand une tuile manque, au lieu d'un carré gris | Expéditeur | §15.3 | Fait |
| Placement du point GPS sur la carte, viseur fixe | Expéditeur | EXI-C01 | Fait |
| Rafraîchissement adaptatif dérivé du profil réseau mesuré | Expéditeur | EXI-C20 | Fait |
| Lien de suivi public, sans session ni installation | Destinataire | EXI-C24, D9 | Fait |
| Backend simulé : livreur en mouvement, statuts, trace | Transverse | §16.2 | Fait |
| Frise chronologique horodatée des statuts | Expéditeur | EXI-C21 | Fait |
| Fiche livreur : note, plaque, véhicule, numéro masqué | Expéditeur | EXI-C22, EXI-C23 | Fait |
| Messagerie interne avec le livreur | Expéditeur, Livreur | EXI-C23 | À faire |
| Notifications distantes et canaux Android | Transverse | EXI-N01, EXI-N02 | À faire |
| Lien profond depuis une notification | Transverse | EXI-N04 | À faire |
| Repli SMS sous 60 s | Transverse | EXI-N06 | À faire |

**Un défaut de composant partagé, trouvé et corrigé.** L'écran de suivi
s'affichait entièrement vide : barre de titre présente, corps blanc, aucune
exception journalisée. La cause était `McSkeletonList`, une `ListView` imbriquée
dans la `ListView` de l'écran. Sans contrainte de hauteur, la liste interne
reçoit une hauteur non bornée, sa mise en page échoue — et l'échec ne se
manifeste pas par un message : **c'est toute la liste parente qui cesse de
peindre**. Un écran vide, sans rien pour l'expliquer.

Le composant accepte désormais un paramètre `nested`, et la frise chronologique
a été réécrite sans `IntrinsicHeight` autour d'un enfant flexible — même famille
de piège. La leçon retenue : un composant de liste partagé doit savoir qu'il
peut être imbriqué, sinon chaque écran qui l'imbrique tombe silencieusement.

Le sélecteur de point sur carte ferme EXI-C01 et corrige au passage un défaut du
module 2 — sans coordonnées réelles, les deux adresses partageaient le point par
défaut, la distance valait zéro et la tarification était dégénérée.

**Les notifications distantes attendent une décision d'exploitation.**
`firebase_messaging` exige un projet Firebase et un fichier
`google-services.json` ; les déclarer sans eux casserait la compilation Android.
La couche de présentation des notifications — canaux, liens profonds, traduction
— peut être construite indépendamment du transport, et le sera au module 4 avec
`flutter_local_notifications`, déjà déclaré. Le branchement FCM reste suspendu à
la création du projet Firebase.

### Module 4 — Livreur : KYC, file et progression

| Tâche | Profil | Exigences |
|---|---|---|
| Dossier KYC : CIN, permis, visage, carte grise, véhicule, plaque | Livreur | EXI-L01 |
| Suivi de l'état du dossier, refus motivé | Livreur | EXI-L02 |
| Interrupteur en ligne et hors ligne, persistant après redémarrage | Livreur | EXI-L03 |
| File des courses disponibles, triée par distance, gain estimé | Livreur | EXI-L04 |
| Acceptation en un geste, compte à rebours de 30 secondes | Livreur | EXI-L05 |
| Navigation déléguée à l'application cartographique installée | Livreur | EXI-L07 |
| Progression par bouton unique plein écran | Livreur | EXI-L08, §15.3 |
| Émission de position en arrière-plan, écran verrouillé | Livreur | EXI-L09 |
| Cadence adaptative : 15 s en mouvement, 60 s à l'arrêt | Livreur | EXI-L11 |
| Tableau de bord des gains par jour, semaine et mois | Livreur | EXI-L12 |
| Signalement d'incident avec photo et conséquence définie | Livreur | EXI-L14 |
| Notation reçue et historique | Livreur | EXI-L16 |

### Module 5 — Chaîne de responsabilité et preuve

Coeur différenciant du produit (D2, D11). Le principe : à chaque transfert de
responsabilité, l'application produit un constat contradictoire, horodaté,
géolocalisé, photographié et signé par les deux parties.

| Tâche | Profil | Exigences |
|---|---|---|
| Constat de prise en charge : 4 photos guidées par gabarit | Livreur, Expéditeur | EXI-CC10 |
| Prise de vue dans l'application uniquement, import galerie interdit | Livreur | EXI-CC11 |
| Grille d'état à cocher, photo et commentaire imposés par anomalie | Livreur | EXI-CC12, EXI-CC13 |
| Numéro de scellé par saisie ou scan de code-barres | Livreur | EXI-CC14 |
| Signature manuscrite de l'expéditeur et contre-signature du livreur | Expéditeur, Livreur | EXI-CC16, EXI-CC17 |
| Constat de remise au même gabarit, affichage côte à côte | Livreur, Destinataire | EXI-CC20, EXI-CC21 |
| Vérification du scellé, incident automatique si rompu ou absent | Livreur | EXI-CC22 |
| Signature du destinataire et code OTP, double preuve d'identité | Destinataire | EXI-CC24 |
| Réception avec réserves, refus de réception, remise à un tiers | Destinataire | EXI-CC26 à EXI-CC28 |
| Écran comparateur avant et après, écarts surlignés | Expéditeur, Livreur, Exploitation | EXI-CC30, EXI-CC31 |
| Signature capturée en vectoriel, rendu PNG dérivé | Transverse | EXI-CC40 |
| Empreinte SHA-256 du constat, chaînage remise sur prise en charge | Transverse | EXI-CC43, EXI-CC44 |
| Constat scellé à la validation, aucune modification ultérieure | Transverse | EXI-CC04 |
| Constat stocké chiffré tant qu'il n'est pas accusé par le serveur | Transverse | EXI-CC46 |
| Export du constat en PDF signé | Expéditeur, Exploitation | EXI-CC32 |

### Module 6 — Mode hors ligne intégral

| Tâche | Profil | Exigences |
|---|---|---|
| File de synchronisation, écriture locale avant toute tentative réseau | Transverse | §10.2 |
| Ordre de priorité : constats, transitions, positions, notations | Transverse | EXI-S02 |
| Reprise exponentielle jusqu'à 15 essais, puis signalement | Transverse | §10.2 |
| Conflit détecté : le serveur fait foi, l'utilisateur est informé | Transverse | EXI-S04 |
| Un constat n'est jamais abandonné automatiquement | Transverse | EXI-S05 |
| Écran « éléments en attente » : liste, âge, cause, relance manuelle | Transverse | EXI-S06 |
| Positions en tampon local, envoi par lots compressés de 50 points | Livreur | EXI-L10, EXI-S03 |
| Purge des photos transmises et accusées | Transverse | EXI-S07 |
| Parcours livreur complet exécutable hors ligne | Livreur | EXI-L15, EXI-P07 |

### Module 7 — Paiement délégué à MajiPay

| Tâche | Profil | Exigences |
|---|---|---|
| Simulateur MajiPay implémentant le contrat, avant livraison du vrai | Transverse | EXI-MP12 |
| Intention de paiement créée côté serveur, aucun secret sur le mobile | Transverse | EXI-MP02 |
| Ouverture app-to-app par lien profond, retour automatique | Expéditeur | EXI-MP03 |
| Écran d'attente et consigne USSD si MajiPay n'est pas installé | Expéditeur | EXI-MP04 |
| État du paiement par notification, sondage de repli plafonné à 120 s | Expéditeur | EXI-MP05 |
| Idempotence stricte, jamais deux débits pour une intention | Transverse | EXI-MP06 |
| Repli espèces automatique, la course n'est jamais bloquée | Expéditeur | EXI-MP08, EXI-C43 |
| Reçu consultable et partageable depuis l'historique | Expéditeur | EXI-MP10 |
| Aucune donnée de paiement dans les journaux | Transverse | EXI-MP11 |

### Module 8 — Supervision depuis mobile

| Tâche | Profil | Exigences |
|---|---|---|
| Tableau de bord : courses, livreurs en ligne, incidents, chiffre du jour | Exploitation | EXI-A01 |
| Carte de flotte temps réel, filtrable par statut | Exploitation | EXI-A02 |
| File de validation KYC, visionneuse de pièces, refus motivé | Exploitation | EXI-A03 |
| Liste des courses, filtres multicritères, accès aux deux constats | Exploitation | EXI-A04 |
| Gestion des litiges : comparateur, échange, décision, clôture | Exploitation | EXI-A05 |
| Suspension et réactivation d'un compte, motif obligatoire | Exploitation | EXI-A06 |
| Réaffectation manuelle d'une course | Exploitation | EXI-A07 |

### Module 9 — Différenciants concurrentiels

| Tâche | Profil | Exigences |
|---|---|---|
| Achat pour compte : liste d'articles, plafond, photo du ticket | Expéditeur, Livreur | EXI-C07, D5 |
| Groupage de 2 à 3 courses sur un même axe | Livreur | EXI-L06, D7 |
| Bouton d'urgence accessible en deux appuis | Livreur | EXI-L13, D10 |
| Réseau de points relais partenaires | Expéditeur, Destinataire | D6 |
| Mode économie : tuiles pré-téléchargées, photos différées | Transverse | EXI-T08 |
| Option assurance sur valeur déclarée | Expéditeur | EXI-C12 |
| Payeur désignable, port dû | Expéditeur, Destinataire | EXI-C42 |

### Module 10 — Durcissement et recette terrain

| Tâche | Profil | Exigences |
|---|---|---|
| Budgets tenus : démarrage, mémoire, taille, batterie, données | Transverse | EXI-P01 à EXI-P06 |
| Épinglage de certificat à double empreinte et rotation | Transverse | EXI-SEC02 |
| Détection d'appareil rooté, capture d'écran interdite sur les écrans sensibles | Transverse | EXI-SEC05, EXI-SEC06 |
| Accessibilité : contraste AA, cibles de 48 dp, TalkBack | Transverse | EXI-T09 |
| Les 8 scénarios de recette du §16.2 sur trois appareils réels | Transverse | §16.2 |
| Recette terrain par 10 livreurs sur 5 jours | Livreur | Critère 10 du §18 |
| Préparation de la publication iOS | Transverse | §2.1 |

---

## 8. Tests

| Suite | Ce qu'elle verrouille |
|---|---|
| `mock_transport_test.dart` | Comportement du transport simulé : hors ligne, latence 2G, erreurs au format du §12.1, compteur de données |
| `idempotency_test.dart` | La clé d'idempotence est posée sur les écritures et **reste identique entre deux reprises** |
| `error_mapper_test.dart` | Traduction des codes HTTP en erreurs typées, état serveur conservé en cas de conflit |
| `redaction_test.dart` | Numéros, OTP, soldes et positions absents des journaux |
| `translation_completeness_test.dart` | Aucune clé manquante ni orpheline entre français et malgache, paramètres cohérents |
| `no_literal_strings_test.dart` | Aucun libellé écrit en dur dans les widgets |
| `malagasy_phone_test.dart` | Normalisation du numéro, rejets, opérateur, forme masquée |
| `auth_flow_test.dart` | Parcours complet OTP, profil, rotation des jetons, code PIN, réseau dégradé |
| `delivery_test.dart` | Adresse composite, grille tarifaire, création en ligne et hors ligne, carnet d'adresses |
| `widget_test.dart` | Redirections par état de session, bascule de langue, permanence du bandeau réseau |

Le parcours d'authentification est testé à travers la **pile réelle** — client
dio, intercepteurs, transport simulé — et non contre des bouchons. C'est le seul
moyen de vérifier que la clé d'idempotence, l'en-tête d'autorisation et la
rotation des jetons fonctionnent ensemble, et pas seulement isolément.

Deux de ces tests méritent une explication, car ils protègent contre des défauts
qui ne cassent rien à la compilation :

- **Complétude des traductions.** Une clé oubliée dans `app_mg.arb` ne provoque
  aucune erreur : Flutter retombe silencieusement sur le français. Le défaut ne
  se verrait qu'en recette terrain, chez un livreur malgachophone.
- **Absence de chaînes littérales.** Un libellé écrit en dur reste en français
  au milieu d'un écran par ailleurs traduit. C'est arrivé sur l'accueil du socle
  et cela ne se voyait qu'à l'écran, en malgache.

---

## 9. Environnement de développement

### JDK

Gradle doit utiliser le JDK 21 fourni par Android Studio. Avec un JDK plus
récent, la compilation Kotlin échoue par intermittence sur des verrous de cache
sous Windows.

```bash
flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"
```

La compilation incrémentale Kotlin est désactivée dans `android/gradle.properties`
pour la même raison. Le coût est de quelques dizaines de secondes par
compilation, le gain est un build reproductible.

### Tests sur le poste

`flutter test` s'exécute sur la machine de développement, où la bibliothèque
native SQLite livrée pour Android n'est pas chargée. Les tests de widget
n'ouvrent donc pas la base locale : ils substituent les providers concernés. La
file de synchronisation aura ses propres tests d'intégration au module 6.

---

## 10. Décisions à arbitrer

Reprises du §19.2 du cahier des charges, dans l'ordre où elles bloquent le
développement mobile.

| Décision | Échéance | Impact sur le mobile |
|---|---|---|
| DO-5 — valeur juridique des constats, à valider par un conseil juridique local | Avant le module 5 | Fixe la rédaction des mentions d'engagement affichées au-dessus des signatures |
| DO-2 — fond cartographique : OpenStreetMap seul ou repli commercial | Avant le module 3 | Coût récurrent et qualité de la carte en province |
| DO-3 — modèle de commission et grille tarifaire | Avant le module 2 | Écrans d'estimation de prix et de gains |
| DO-1 — trajectoire réglementaire de MajiPay : passerelle ou établissement de monnaie électronique | Avant le module 7 | Détermine 4 des 26 modules MajiPay. En l'absence d'arbitrage, la trajectoire passerelle est retenue |
| DO-4 — recrutement du réseau de points relais | Avant le module 9 | Couverture hors Antananarivo |
| DO-6 — publication iOS en phase 1 ou 2 | Avant le module 10 | Coût du compte développeur et de la recette |
