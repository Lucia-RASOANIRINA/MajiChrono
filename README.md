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
| 4 | Livreur : KYC, file, progression | Lot 2 | Livré, sauf captures et arrière-plan |
| 5 | Chaîne de responsabilité et preuve | Lot 2 | Noyau de preuve livré, capture à faire |
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

### Module 4 — Livreur : KYC, file et progression (livré, sauf captures et arrière-plan)

| Tâche | Profil | Exigences | État |
|---|---|---|---|
| Interrupteur en ligne / hors service, persistant après redémarrage | Livreur | EXI-L03 | Fait |
| File des courses disponibles, triée par distance à vide | Livreur | EXI-L04 | Fait |
| Gain net estimé, commission déduite, et rendement par kilomètre | Livreur | EXI-L04 | Fait |
| Acceptation en un geste, compte à rebours de 30 secondes | Livreur | EXI-L05 | Fait |
| Course déjà prise traitée comme un conflit normal, pas une panne | Livreur | EXI-L05 | Fait |
| Navigation déléguée à l'application cartographique installée | Livreur | EXI-L07 | Fait |
| Progression par bouton unique plein écran, 64 dp | Livreur | EXI-L08, §15.3 | Fait |
| Transitions validées côté serveur, refus avec état courant | Livreur | EXI-B02 | Fait |
| Étapes exigeant un constat déjà identifiées | Livreur | EXI-CC03 | Fait |
| Tableau de bord des gains : jour, semaine, mois, détail par course | Livreur | EXI-L12 | Fait |
| Signalement d'incident, chaque motif portant sa conséquence | Livreur | EXI-L14 | Fait |
| Suivi de l'état du dossier KYC | Livreur | EXI-L02 | Fait |
| Cadence d'émission : 15 s en mouvement, 60 s à l'arrêt | Livreur | EXI-L11 | Règle posée |
| Capture des pièces du dossier KYC | Livreur | EXI-L01 | Module 5 |
| Émission de position en arrière-plan, écran verrouillé | Livreur | EXI-L09 | Module 6 |
| Positions en tampon local, envoi par lots de 50 | Livreur | EXI-L10 | Module 6 |
| Notation reçue et historique | Livreur | EXI-L16 | Module 8 |

**Deux défauts trouvés à l'écran, invisibles aux tests.** Les deux portaient sur
la même fonction — la fenêtre d'acceptation de 30 secondes — et aucun n'aurait
été vu autrement qu'en regardant l'application vivre.

Le premier : à l'expiration du compte à rebours, les propositions restaient
affichées avec un bouton mort. Le livreur se retrouvait devant un mur d'offres
périmées, sans autre issue qu'un tirer-pour-rafraîchir qu'il ne devine pas. La
file se renouvelle désormais à l'expiration de la fenêtre, à une cadence dérivée
du profil réseau mesuré — en 2G, rafraîchir toutes les 30 secondes coûterait du
forfait pour une file qui n'a pas eu le temps de changer (§4.4).

Le second, révélé par la correction du premier : la file se renouvelait bien,
mais **tous les boutons restaient désactivés**. Sans clé distincte, Flutter
recycle l'objet `State` de la carte occupant la même position dans la liste ; le
compte à rebours, porté par cet état, ne repartait jamais de 30 secondes. La clé
de chaque carte intègre maintenant le numéro du cycle de rafraîchissement.

**Un défaut de routage trouvé par les tests.** Le §12.2 déclare à la fois
`/deliveries/available` et `/deliveries/{id}`. Le routeur du backend simulé
prenait la première route qui correspondait, dans l'ordre d'enregistrement : la
file du livreur était donc capturée par la route de détail et renvoyait « course
inconnue ». Le routage suit désormais la **spécificité** — une route littérale
l'emporte sur une route paramétrée — comme le fait tout routeur réel. Sans cela,
le comportement dépendait de l'ordre dans lequel les modules s'enregistrent.

**Le simulateur valide les transitions, et c'est délibéré.** S'il acceptait
toutes les transitions, l'application donnerait l'illusion de fonctionner et le
défaut n'apparaîtrait qu'au branchement du vrai serveur. Un test vérifie qu'une
étape sautée est refusée avec l'état courant (EXI-B02).

**Ce qui est reporté, et pourquoi.** La capture des pièces KYC rejoint le bloc
photo du module 5 — même pipeline que les constats. L'émission de position en
arrière-plan (EXI-L09, EXI-L10) demande un service de premier plan Android avec
notification permanente et une file de positions par lots : elle appartient au
module 6, avec la file de synchronisation dont elle est le principal client. La
règle de cadence d'EXI-L11 est déjà posée et testée ; il ne lui manque que la
source de position.

### Module 5 — Chaîne de responsabilité et preuve

Coeur différenciant du produit (D2, D11). Le principe : à chaque transfert de
responsabilité, l'application produit un constat contradictoire, horodaté,
géolocalisé, photographié et signé par les deux parties.

**État : module livré.** Noyau de preuve, écrans de capture, issues de remise,
chiffrement au repos et export PDF. 61 tests portent sur ce seul module.

| Élément | Exigences | État |
|---|---|---|
| Entité constat : photos, grille, scellé, poids, signatures, position | EXI-CC02 | Fait |
| Règle de complétude bloquant la progression du statut | EXI-CC03 | Fait |
| Scellement rendant le constat immuable | EXI-CC04 | Fait |
| Empreinte SHA-256 sur corps canonique déterministe | EXI-CC43 | Fait |
| Chaînage : la remise intègre l'empreinte de la prise en charge | EXI-CC44 | Fait |
| Grille d'état fermée à six critères, anomalie exigeant photo et commentaire | EXI-CC12, EXI-CC13 | Fait |
| Vérification du scellé, incident automatique si rompu ou absent | EXI-CC22 | Fait |
| Double preuve à la remise : signature et code OTP | EXI-CC24 | Fait |
| Signature vectorielle : points, pression, horodatage relatif | EXI-CC40 | Fait |
| Pipeline photo : 1280 px, 200 Ko, compression itérative, empreinte | EXI-CC41 | Fait |
| Budget de 1,2 Mo par constat | EXI-CC42 | Fait |
| Comparateur avant/après, angle par angle, écarts surlignés | EXI-CC30, EXI-CC31 | Fait |
| Transmission, écriture locale avant envoi | EXI-CC05 | Fait |
| Serveur recalculant l'empreinte et refusant toute incohérence | EXI-B05 | Fait |
| Serveur refusant une remise qui ne chaîne pas | EXI-CC44 | Fait |
| Serveur refusant de rejouer un constat déjà scellé | EXI-CC04 | Fait |
| Horodatage serveur faisant foi, écart d'horloge journalisé | EXI-CC45 | Fait |
| Constat conservé et relisible hors ligne, jamais abandonné | EXI-CC05, EXI-S05 | Fait |
| Prise de vue guidée par gabarit, dans l'application uniquement | EXI-CC10, EXI-CC11 | Fait |
| Écrans de saisie des deux constats | EXI-CC02 | Fait |
| Constat exigé avant la progression du statut du livreur | EXI-CC03 | Fait |
| Réception avec réserves, litige ouvert automatiquement | EXI-CC26 | Fait |
| Refus de réception, retour expéditeur | EXI-CC27 | Fait |
| Remise à un tiers : identité, lien, pièce photographiée | EXI-CC28 | Fait |
| Remise sans signature : motif et photo du colis remis | EXI-CC29 | Fait |
| Chiffrement AES-256 au repos des constats non transmis | EXI-CC46, EXI-SEC04 | Fait |
| Export PDF du constat, avec photos, signatures et empreinte | EXI-CC32 | Fait |
| Accès au comparateur depuis l'expéditeur et depuis le livreur | EXI-CC31 | Fait |
| Scan du code de scellé | EXI-CC14 | Module 10 |

**Le corps canonique mérite une explication.** L'empreinte porte sur une
sérialisation déterministe : photos triées par angle, grille triée, signatures
dans l'ordre d'apposition. Sans cette normalisation, deux sérialisations du même
constat donneraient deux empreintes différentes, et le serveur rejetterait un
constat pourtant intact — le §12.3 lui impose de recalculer et de vérifier
(EXI-B05).

**Les chemins de fichiers sont rangés hors du corps canonique.** Ils sont propres
à l'appareil ; les inclure ferait varier l'empreinte d'un téléphone à l'autre,
et le serveur — qui la recalcule — rejetterait un constat pourtant intact. Un
test le verrouille.

**Le contrôle décisif est côté serveur.** Le simulateur recalcule l'empreinte et
refuse toute incohérence, refuse une remise qui ne chaîne pas sur une prise en
charge enregistrée, et refuse de rejouer une étape déjà scellée avec un contenu
différent. Sans ces trois refus, la chaîne de preuve serait déclarative : un
client qui casserait la sérialisation canonique ne s'en apercevrait que le jour
d'un litige.

**Toutes les remises ne se ressemblent pas, et la spécification refuse de les
ramener à « livré / pas livré ».** Cinq issues sont proposées, chacune avec ses
propres pièces justificatives et sa propre conséquence sur la course :

| Issue | Motif écrit | Photo en plus | Code OTP | Signature du destinataire | Conséquence |
|---|---|---|---|---|---|
| Remis au destinataire | — | — | oui | oui | livrée |
| Remis sous réserves | oui | — | oui | oui | livrée **et** litige ouvert |
| Refusé | oui | oui | — | oui | retour expéditeur |
| Remis à un tiers | — | pièce d'identité | — | oui | livrée |
| Remis sans signature | oui | colis remis | — | — | livrée, exploitation alertée |

Deux choix méritent d'être défendus. Le code OTP disparaît au refus et à la
remise à un tiers : un destinataire qui refuse le colis ne confirmera pas la
remise par un code, et l'exiger rendrait le refus impossible à consigner. Et
**aucune issue n'est pré-cochée** — « remis au destinataire » doit être affirmé,
jamais supposé. Une case pré-cochée ferait signer au livreur un récit qu'il n'a
pas choisi ; c'est la différence entre un constat et un formulaire.

Dans le mode sans signature, le cadre de signature du destinataire **disparaît**
au lieu de rester vide. Un cadre vide invite à le faire remplir par n'importe
qui.

**Le chiffrement au repos n'est pas une précaution de principe.** Un constat qui
attend le réseau contient des photos de colis, des positions GPS, des numéros de
téléphone et deux signatures manuscrites. Sur le téléphone personnel d'un
livreur — appareil souvent partagé, parfois volé (§4.4, EXI-L13) — le laisser en
clair reviendrait à publier la preuve avant qu'elle ne soit protégée. La clé
AES-256 est tirée une fois et rangée dans le Keystore Android (EXI-SEC03) ; le
vecteur d'initialisation est tiré à chaque écriture, sans quoi deux constats
identiques produiraient deux cryptogrammes identiques et leur comparaison
révélerait qu'ils le sont. Effacer les données locales (EXI-SEC10) détruit la
clé, donc rend illisible ce qui resterait sur disque — et la lecture retourne
alors `null` plutôt que de faire tomber l'écran des preuves.

**Le PDF n'est pas la preuve, il en est la restitution lisible.** La preuve est
l'empreinte que le serveur recalcule (EXI-B05). Le PDF est ce qu'on imprime,
qu'on joint à un courrier ou qu'on tend à une assurance : il porte donc
l'empreinte en clair, celle du constat précédent, et l'empreinte de chaque photo
— de quoi vérifier qu'une image jointe au dossier est bien celle qui a été
scellée. Il se génère hors ligne, à partir des fichiers locaux, avant même
l'accusé de réception du serveur : un PDF qui n'existerait qu'une fois le réseau
revenu ne servirait jamais au moment où l'on en a besoin. Les signatures y sont
**rejouées** depuis leur vecteur, pas collées en image : le tracé reste net à
toute échelle, et les points, la pression et les temps restent disponibles pour
une expertise (EXI-CC40).

**Soixante et un tests portent sur ce module**, dont ceux qui comptent vraiment :
qu'une altération après scellement soit détectable, qu'altérer la prise en
charge rompe la chaîne, qu'une remise référençant une autre prise en charge soit
rejetée, qu'une anomalie apparue en transport soit isolée par le comparateur,
qu'aucun contenu de constat ne soit lisible en clair sur disque, et que chaque
issue de remise fasse apparaître à l'écran exactement les champs qu'elle exige —
ni plus, ni moins.

**Une limite du banc de test subsiste.** Le parcours de constat n'a pas pu être
déroulé de bout en bout sur l'émulateur : l'état du simulateur vit en mémoire, si
bien qu'après un redémarrage de l'application la course active n'existe plus
côté serveur et la transition de statut n'aboutit pas. C'est une limite du banc,
pas du code — les écrans sont couverts par des tests de widgets qui vérifient
directement ce que l'œil aurait vérifié. Elle disparaîtra quand le simulateur se
réhydratera depuis le cache local, ou au module 6 avec la file de
synchronisation.

**Seule exigence du module encore ouverte : le scan du code de scellé**
(EXI-CC14). La saisie manuelle du numéro est en place et suffit ; le scan par
code-barres arrive au module 10, avec les autres optimisations de saisie.

### Module 6 — Mode hors ligne intégral

**État : module livré.** 42 tests portent sur ce module. Le principe tient en
une phrase : **rien n'est tenté sur le réseau avant d'avoir été écrit
localement**. L'utilisateur voit son action aboutir tout de suite ; la file se
charge du reste, y compris trois jours plus tard, y compris après un
redémarrage.

| Élément | Exigences | État |
|---|---|---|
| File de synchronisation persistante, écriture locale avant tout envoi | §10.2 | Fait |
| Ordre de priorité : constats, transitions, positions, notations | EXI-S02 | Fait |
| Clé d'idempotence posée au dépôt et conservée entre les reprises | EXI-S01 | Fait |
| Reprise exponentielle plafonnée, 15 essais puis signalement | §10.2 | Fait |
| Conflit : le serveur fait foi, l'utilisateur est informé | EXI-S04 | Fait |
| Un constat n'est jamais abandonné automatiquement | EXI-S05 | Fait |
| Écran « éléments en attente » : liste, âge, cause, relance | EXI-S06 | Fait |
| Reprise des envois interrompus par une fermeture brutale | EXI-S01 | Fait |
| Tampon local de positions, lots de 50 points | EXI-L10, EXI-S03 | Fait |
| Purge des photos transmises et accusées | EXI-S07 | Fait |
| Transition de statut exécutable hors ligne | EXI-L15, EXI-P07 | Fait |
| Émission de position en arrière-plan, écran verrouillé | EXI-L09 | Module 10 |

**La file est une table, pas une liste en mémoire.** Un livreur qui tue
l'application dans un tunnel doit retrouver ses constats au redémarrage. C'est
la seule lecture compatible avec EXI-S05, et c'est ce qui a été vérifié à
l'écran : une transition faite hors ligne a survécu à une réinstallation, puis
est repartie seule au retour du réseau, sans que personne n'appuie sur rien.

**EXI-S05 contredit délibérément « 15 essais puis abandon ».** Les deux règles
coexistent, et la contradiction est assumée. Après quinze échecs, une transition
de statut est signalée et cesse d'être retentée ; un constat, lui, reste dans la
file indéfiniment — même refusé par le serveur. Il change seulement d'état
visible, pour qu'un humain tranche. Abandonner une preuve parce que le réseau a
été mauvais quinze fois serait exactement le défaut que le module 5 s'est
employé à rendre impossible.

**La clé d'idempotence est posée au dépôt, jamais régénérée à la reprise.**
C'est toute la différence entre une reprise et un doublon : un envoi parti puis
coupé avant la réponse, rejoué sous une nouvelle clé, créerait deux courses ou
deux constats. Trois sources, trois façons de la dériver — la course la tire au
hasard et la conserve, le constat utilise son empreinte (recalculable), la
transition la dérive de la course et de l'étape visée, si bien que deux appuis
sur le même bouton produisent la même clé.

**L'ordonnanceur se déclenche au retour du réseau, pas à intervalle fixe.** Un
réveil toutes les trente secondes en zone blanche viderait la batterie sans rien
transmettre. Un battement lent de deux minutes couvre le cas où le réseau n'a
pas varié mais où un délai de reprise vient d'échoir. Le délai de reprise porte
un bruit aléatoire de ±20 % : si tous les téléphones d'Antananarivo rejouaient
leur file à la seconde exacte où le réseau revient, ils reconstruiraient la
panne qu'ils viennent de subir.

**Une coupure interrompt la vidange au lieu de la poursuivre.** Insister élément
par élément sur un réseau tombé n'ajouterait que des tentatives inutiles au
compteur de chacun — et rapprocherait d'autant le plafond de quinze.

**« Le serveur fait foi » ne suffit pas : encore faut-il que l'utilisateur
l'apprenne.** Le conflit remonte jusqu'à un bandeau posé au-dessus du Navigator,
visible quel que soit l'écran affiché au moment où le serveur tranche. Un
livreur qui a marqué une course livrée hors ligne, et dont le serveur dit
qu'elle a été annulée entre-temps, doit le découvrir maintenant — pas devant la
porte du destinataire.

**Les positions partent par cinquante.** À quinze secondes d'intervalle sur une
journée de huit heures, une par requête ferait près de deux mille appels : autant
d'en-têtes, de poignées de main TLS et de réveils radio pour quelques octets
chacun. Sur un forfait malgache (§4.4), le coût du transport dépasserait
largement celui de la donnée transportée. Le plafond de cinquante n'est pas un
choix d'implémentation : le serveur refuse au-delà (EXI-B06). Le tampon est
persistant, pas en mémoire — une application tuée par le système pendant une
tournée ne doit pas laisser un trou dans la trace.

**La purge des photos n'intervient qu'après l'accusé de réception.** Effacer
avant reviendrait à détruire la seule copie d'une preuve sur la foi d'un envoi
qui peut encore échouer. Les métadonnées survivent — empreinte, horodatage,
position, taille — ce qui permet de vérifier plus tard qu'une image servie par
le serveur est bien celle qui a été scellée. Un test vérifie qu'un constat
refusé par le serveur garde ses photos.

**Ce qui reste ouvert : l'émission de position en arrière-plan** (EXI-L09), qui
demande un service Android au premier plan et une notification permanente. Le
tampon, le lot de cinquante et le transport sont en place et testés ; il ne
manque que la source qui alimente le tampon quand l'écran est éteint. C'est un
travail de plateforme plutôt que de logique métier, reporté au module 10 avec
les autres réglages de performance et de batterie.

### Module 7 — Paiement adossé aux soldes MajiPay

**État : module livré.** 29 tests. **Écart assumé avec le cahier des charges,
sur décision produit** : le §11.2 prévoyait un aller-retour app-to-app vers
MajiPay (EXI-MP03) avec écran d'attente et consigne USSD (EXI-MP04). Le
processus a été ramené **dans MajiChrono** : MajiPay ne fournit plus que les
soldes, et les deux téléphones s'apparient par un code QR. Les exigences
MP03/MP04 sont donc sans objet dans cette forme ; toutes les autres sont
tenues, et deux d'entre elles — MP02 et MP06 — pèsent plus lourd qu'avant,
puisque c'est désormais MajiChrono qui conduit la transaction.

| Élément | Exigences | État |
|---|---|---|
| Simulateur MajiPay : soldes, jetons, capture, refus | EXI-MP12 | Fait |
| Intention créée côté serveur, aucun secret durable sur le mobile | EXI-MP02 | Fait |
| Appariement par code QR, dans les deux sens | — | Fait |
| Confirmation du payeur par code, sur son propre appareil | EXI-MP02 | Fait |
| Idempotence stricte, jamais deux débits pour une intention | EXI-MP06 | Fait |
| Sondage d'état plafonné à 120 s, cadence suivant le réseau | EXI-MP05 | Fait |
| Repli espèces, offert avant l'échec et après | EXI-MP08, EXI-C43 | Fait |
| Reçu affiché avec sa référence | EXI-MP10 | Fait |
| Aucun montant, solde, jeton ni numéro dans les journaux | EXI-MP11 | Fait |
| Ouverture app-to-app et consigne USSD | EXI-MP03, EXI-MP04 | Sans objet |
| Partage du reçu depuis l'historique | EXI-MP10 | Module 9 |

**Une règle domine le module, et elle est portée par le code : scanner
n'autorise jamais un débit.** Le scan ne fait qu'apparier deux appareils. Celui
qui paie confirme toujours sur le sien, avec son code. Sans cette règle,
quiconque scanne un code affiché par un tiers pourrait se servir sur son compte.
Le simulateur refuse d'ailleurs toute confirmation qui ne vient pas du payeur :
un bénéficiaire ne peut pas se payer lui-même, même si le mobile le lui
demandait.

**Les deux sens existent parce que les deux situations existent.**

| Sens | Qui présente | Qui scanne | Quand l'argent bouge |
|---|---|---|---|
| Demande d'encaissement | Le livreur | Le client | À la confirmation du client, chez lui |
| Offre de paiement | Le client | Le livreur | Au scan — le client a déjà confirmé en créant le code |

Dans les deux cas l'argent va du client au livreur, et dans les deux cas le
payeur a donné son accord sur son propre téléphone. Pour l'offre, cet accord est
simplement **antérieur** au scan : le client saisit son code avant d'afficher le
sien. L'invariant tient donc dans les deux sens.

**Le code QR ne porte que l'identifiant et un jeton à usage unique.** Ni
montant, ni nom, ni numéro de compte : un code photographié à distance ne révèle
rien, et ne vaut rien sans la confirmation du payeur. Le scanneur interroge le
serveur pour connaître le reste. Le jeton n'est servi qu'une fois, à la
création, et seulement à celui qui présente le code — une lecture d'intention ne
le rend jamais. Sa durée de vie est de cinq minutes : assez pour tendre un
téléphone, trop court pour qu'un code oublié sur un comptoir serve à quoi que ce
soit.

**Un défaut réel trouvé par les tests.** La création d'intention ignorait la clé
d'idempotence : deux appuis sur « encaisser » produisaient **deux codes
encaissables** pour la même course. Le premier scanné débitait, le second restait
en circulation, prêt à débiter une seconde fois. C'est exactement ce qu'EXI-MP06
existe pour empêcher.

**Le solde est lu, jamais recopié.** MajiPay en est la source de vérité ; un
solde mis en cache dans MajiChrono divergerait au premier mouvement fait
ailleurs et afficherait un montant faux au moment précis où il compte. Le
provider est `autoDispose` pour cette raison.

**Le repli espèces est offert avant l'échec, pas seulement après.** Un client
sans solde ne doit pas avoir à échouer d'abord pour découvrir qu'il peut payer
autrement. Il reste disponible après un refus MajiPay, et devient impossible
après un encaissement réussi — sinon la course serait réglée deux fois, une en
monnaie et une en solde.

**Le paiement n'apparaît qu'une fois le colis remis.** Proposer l'encaissement
avant la livraison inverserait l'ordre des choses et exposerait le client. Les
deux entrées — bouton d'encaissement chez le livreur, bouton de scan chez le
client — n'existent que sur une course livrée et réglée par MajiPay.

**Ce qui reste ouvert : le partage du reçu** (EXI-MP10, seconde moitié). Le reçu
est affiché avec sa référence ; l'export partageable réutilisera le générateur
PDF du module 5 et arrive au module 9 avec l'historique.

**Effet de bord utile :** l'arrivée de `mobile_scanner` pour le paiement rend le
scan du code de scellé (EXI-CC14) accessible au module 10 sans dépendance
supplémentaire.

### Module 8 — Supervision depuis mobile

**État : module livré.** 32 tests. Vérifié à l'écran de bout en bout, compte
d'exploitation `+261 32 00 000 03`.

| Élément | Exigences | État |
|---|---|---|
| Tableau de bord : dossiers, litiges, incidents, courses, flotte, chiffre du jour | EXI-A01 | Fait |
| Carte de flotte, filtrable par statut, position ancienne signalée | EXI-A02 | Fait |
| File KYC ordonnée, état de complétude, refus motivé | EXI-A03 | Fait |
| Liste des courses, filtres multicritères, accès aux deux constats | EXI-A04 | Fait |
| Litiges : comparateur, échange, décision motivée, clôture | EXI-A05 | Fait |
| Suspension et réintégration d'un compte, motif obligatoire | EXI-A06 | Fait |
| Réaffectation manuelle d'une course | EXI-A07 | Fait |
| Visionneuse d'images des pièces KYC | EXI-A03 | Module 10 |

**Aucune action d'exploitation n'est anonyme ni muette, et c'est le *type* qui
le garantit.** `ModerationDecision` a un constructeur privé : on n'en obtient un
que par `ModerationDecision.taken(...)`, qui rend `null` si le motif fait moins
de dix caractères. Toutes les méthodes qui décident en exigent un. Il n'existe
donc **aucun chemin de code** menant à une suspension, un refus de dossier ou
une clôture de litige sans motif — la règle n'est pas rappelée par un
commentaire qu'on peut oublier de lire, elle est tenue par le compilateur.

Le seuil de dix caractères ne garantit pas la pertinence ; il écarte le réflexe.
Un champ obligatoire se remplit avec « ok » ou « ras » quand rien ne s'y oppose.
Et le motif est exigé **même pour les décisions favorables** : savoir pourquoi
un compte a été réintégré importe autant que de savoir pourquoi il avait été
suspendu.

**La feuille de motif dit ce qui manque plutôt que de rester muette.** Le compte
à rebours descend en direct — « Encore 5 caractères » — puis bascule sur « Ce
motif sera relu tel quel en cas de contestation ». Un bouton grisé sans
explication pousse à taper n'importe quoi jusqu'à ce qu'il s'allume.

**Le comparateur des constats est celui du module 5, tel quel.** EXI-CC31 impose
que les trois profils voient la même chose. Une vue d'exploitation enrichie
casserait le caractère contradictoire de la preuve : ce ne serait plus un
comparateur, ce serait un dossier à charge. La liste des courses et l'écran de
litige réutilisent donc le même widget que l'expéditeur et le livreur.

**Trois refus portent la valeur du simulateur** — ce sont eux qui rendent le
contrat vérifiable avant que le vrai back-office n'existe :

| Refus | Pourquoi |
|---|---|
| Réaffecter vers un livreur hors service ou suspendu | Confier le colis à personne, tout en affichant qu'il est pris en charge |
| Suspendre un livreur en course | Le colis serait orphelin, entre deux mains — la course doit être réaffectée d'abord |
| Rouvrir un litige déjà tranché | Une décision qu'on peut défaire silencieusement n'engage personne |

**La réaffectation a sa propre route, pas celle du livreur.** Le graphe de
transitions `DriverAllowed` ne prévoit aucun mouvement vers `disputed` ni aucune
réaffectation ; faire passer une action d'exploitation par
`/deliveries/{id}/status` aurait donné au mobile un pouvoir qu'il ne doit pas
avoir. `/admin/deliveries/{id}/reassign` est une porte distincte, avec ses
propres contrôles.

**Un livreur suspendu reste visible sur la carte.** Le retirer donnerait
l'illusion d'une flotte plus saine qu'elle ne l'est, et ferait oublier qu'une
décision attend d'être levée. Son motif de suspension reste affiché tant qu'elle
dure — une décision qu'on ne peut plus relire ne peut plus être levée en
connaissance de cause.

**Une position ancienne se dit.** Au-delà de dix minutes, le repère passe en
creux : il annonce « il était là » plutôt que « il est là ». Afficher un point
plein au mauvais endroit enverrait un exploitant chercher quelqu'un qui n'y est
plus.

**Deux défauts trouvés à l'écran, invisibles aux tests.**

Le premier : « Dossier incomplet · 2 pièce(s) manquante(s) » débordait de quinze
pixels sur un écran de 320 dp — et davantage en malgache. Le texte ne pouvait
pas passer à la ligne.

Le second, plus subtil : la carte et la liste calculaient chacune leur propre
`DateTime.now()` pour juger de l'ancienneté d'une position. Deux appels à
quelques millisecondes d'écart peuvent tomber de part et d'autre du seuil, et
afficher un repère plein sous une ligne qui annonce « position ancienne ».
L'instant de référence est désormais calculé une seule fois par écran.

**Un choix de navigation.** La file KYC et la liste des courses sont atteintes
depuis le tableau de bord, pas par un onglet : la barre inférieure en compte
déjà quatre, et au-delà les libellés ne tiennent plus sur un écran de 320 dp
(§15.1). Chaque compteur du tableau de bord est cliquable et mène à l'écran qui
permet d'agir — afficher « 3 dossiers à valider » sans y conduire oblige à
chercher, et on ne cherche pas quand on est pressé.

**Ce qui reste ouvert : la visionneuse d'images des pièces KYC.** L'écran montre
aujourd'hui quelles pièces sont fournies et lesquelles manquent, ce qui suffit à
décider d'un refus pour dossier incomplet. L'affichage des images elles-mêmes
attend la capture KYC côté livreur, reportée au module 10 avec les autres
travaux de plateforme.

### Module 9 — Différenciants concurrentiels

**État : module livré.** 45 tests. Le bouton d'urgence est vérifié à l'écran ;
le pas « Options » de la création est verrouillé par onze tests de widgets.

| Élément | Exigences | État |
|---|---|---|
| Option assurance sur valeur déclarée | EXI-C12 | Fait (module 2) |
| Bouton d'urgence en deux appuis | EXI-L13, D10 | Fait, vérifié à l'écran |
| Mode économie : photos différées, tuiles bloquées | EXI-T08 | Fait |
| Achat pour compte : articles, plafond, ticket, remboursement | EXI-C07, D5 | Fait |
| Payeur désignable, port dû | EXI-C42 | Fait |
| Réseau de points relais | D6 | Fait |
| Groupage de 2 à 3 courses sur un même axe | EXI-L06, D7 | Fait |

**L'assurance était déjà livrée.** `insuredValueAriary` sur le brouillon, la
ligne `PriceLineKind.insurance` dans la ventilation, le taux dans la grille
tarifaire : EXI-C12 était traité au module 2 avec l'estimation. Elle est retirée
du reste à faire plutôt que réécrite.

**L'urgence n'est pas un incident, et le code le tient séparé.** Un incident se
signale, se motive, rejoint la file de synchronisation et attend son tour. Une
urgence part tout de suite : pas de menu, pas de champ, pas de dialogue de
confirmation. « Accessible en deux appuis » se lit littéralement — un appui pour
ouvrir, un appui pour envoyer, **rien entre les deux**.

Le second appui n'est pas une politesse : il existe parce qu'un bouton
d'urgence à un seul appui se déclenche dans une poche.

La qualification — accident, agression, panne, malaise — est posée **sous** le
bouton d'envoi, jamais avant. Une alerte sans nature part quand même, et c'est
déjà l'essentiel. La position est facultative pour la même raison : attendre un
point GPS coûterait les secondes qui comptent, et sous un pont il ne viendra
jamais.

Hors ligne, l'alerte rejoint la file en **priorité `custody`**, au rang des
preuves, avec le drapeau « jamais abandonner ». Un appel à l'aide qui partirait
derrière des positions GPS n'aurait aucun sens. Le niveau de batterie voyage
avec elle : une alerte partie à 3 % dit à l'exploitation qu'il ne faut pas
compter rappeler.

**Le mode économie ne dégrade jamais une preuve.** Il diffère les photos hors
constat jusqu'à une connexion non facturée et cesse d'ouvrir de nouvelles
tuiles de carte. Mais `allowsUpload` prend un paramètre `isProof` **requis** —
non optionnel, pour qu'aucun appelant ne puisse différer une preuve par
inadvertance. Un constat part avec ses quatre photos en pleine définition, mode
économie ou non : une preuve amoindrie pour économiser deux cents kilo-octets ne
serait plus une preuve.

**Le plafond de l'achat pour compte est une protection, pas un réglage.** Le
livreur avance **son propre argent**. Trois conséquences, toutes dans le code :
le remboursement est plafonné — ce qui a été dépensé au-delà n'engage pas
l'expéditeur, et c'est précisément ce que le plafond signifie ; un plafond
inférieur à l'estimation de l'expéditeur est signalé avant l'envoi plutôt que
découvert devant la caisse ; et la substitution se décide **article par
article**, parce qu'accepter un autre riz n'engage pas à accepter un autre
médicament.

**Le groupage est une règle géométrique, pas un compteur.** Deux courses qui
partent dans des directions opposées ne se groupent pas — elles s'additionnent,
et le livreur perd sur les deux. Le domaine calcule le détour imposé et les
kilomètres économisés, et refuse un groupe qui ne fait rien gagner. Le plafond
de trois n'est pas arbitraire : au-delà, l'ordre des arrêts devient un problème
que personne ne résout de tête, et le risque d'intervertir deux colis grimpe.
Les retraits précèdent toujours toutes les remises — un livreur qui livre avant
d'avoir tout pris devra revenir.

**Un quatrième pas est apparu dans la création de course.** Adresses · Colis ·
**Options** · Récapitulatif. Les différenciants n'ont pas été entassés dans le
pas « Colis » : ils ne décrivent pas le colis, ils décrivent la façon dont la
course se déroule et se règle.

Deux sections y sont **conditionnelles**. La liste de courses n'apparaît que si
le type est « achat pour compte » ; un relais trop petit pour le colis reste
visible mais inerte, avec sa raison. Masquer une option laisserait croire
qu'elle n'existe pas ; l'afficher active laisserait découvrir le refus à la
remise.

**Le plafond suit le livreur pendant toute la course.** Côté expéditeur, il est
saisi avec la phrase qui l'explique — « le livreur avance son propre argent ».
Côté livreur, la carte le rappelle **en rouge et en permanence** : c'est sa
seule protection, il ne doit jamais avoir à le chercher. S'il saisit un montant
supérieur, l'écran annonce immédiatement ce qu'il récupérera réellement, plutôt
que de le laisser le découvrir au remboursement.

Le ticket de caisse passe par le **pipeline photo du module 5** — 1280 px,
200 Ko, empreinte SHA-256. Une seconde chaîne photo aurait divergé de la
première au premier ajustement.

**Lever l'hypothèse « une seule course » était la vraie difficulté du
groupage.** Jusqu'ici, `activeDriverDeliveryProvider` renvoyait une course et
une seule. Le socle en expose maintenant trois lectures :
`activeDriverDeliveriesProvider` (la liste), `activeDriverDeliveryProvider` (la
première, conservée pour les écrans qui n'en traitent qu'une — bouton d'action
suivante, itinéraire, constat) et `activeGroupProvider` (le groupe, quand il y
en a un). L'écran de parcours groupé ne propose **aucun choix d'ordre** : les
retraits d'abord, les remises ensuite, affiché comme une consigne.

**Ce qui reste ouvert.** L'écran de parcours groupé s'affiche dès qu'un livreur
porte deux courses actives, mais **l'acceptation multiple** elle-même n'est pas
encore proposée dans la file d'offres : le simulateur libère une course dès
qu'une autre est acceptée. Le domaine sait déjà décider (`DeliveryGroup.accepts`
refuse une course hors axe), il manque le bouton « grouper avec celle-ci » dans
la carte d'offre et la levée de l'exclusivité côté simulateur. C'est du travail
de banc d'essai plus que de produit.

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
