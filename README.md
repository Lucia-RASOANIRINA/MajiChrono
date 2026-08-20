# MajiChrono

Application mobile Flutter de livraison à la demande à Madagascar.

MajiChrono permet aux clients de créer et suivre leurs livraisons, aux livreurs de gérer leurs courses et aux équipes d'exploitation de superviser l'activité depuis une seule application.

L'application est conçue pour fonctionner dans des conditions réseau difficiles, notamment en 2G, 3G et 4G, ainsi qu'en mode hors connexion.

> Projet mobile Flutter — Backend actuellement simulé

---

## Sommaire

- Présentation
- Fonctionnalités
- Profils utilisateurs
- Technologies
- Architecture
- Structure du projet
- Installation
- Lancement
- Comptes de démonstration
- Mode hors ligne
- Backend simulé
- Sécurité
- État du projet
- Tests
- Environnement de développement
- Points restant à finaliser
- Décisions produit
- Roadmap
- Documentation
- Développement

---

## Présentation

MajiChrono est une application mobile destinée à gérer une plateforme de livraison à Madagascar.

L'application regroupe trois profils principaux :

- **Client** : Créer une course, suivre un colis, payer et noter le livreur
- **Livreur** : Accepter des courses, effectuer les livraisons et gérer les preuves
- **Administrateur** : Superviser les courses, les livreurs, les KYC et les litiges

Le destinataire n'a pas besoin d'installer l'application. Il peut recevoir un lien de suivi et participer à la confirmation de livraison depuis le téléphone du livreur.

Le profil administrateur est attribué côté serveur et ne peut pas être sélectionné librement depuis l'application.

---

## Fonctionnalités

### Client

- Création d'une course
- Gestion des adresses
- Carnet d'adresses et favoris
- Choix du type de livraison
- Déclaration du colis
- Estimation du prix
- Livraison immédiate ou programmée
- Création de course hors ligne
- Historique des courses
- Annulation avant prise en charge
- Suivi du livreur
- Carte et position GPS
- Paiement MajiPay
- Paiement en espèces
- Assurance sur la valeur déclarée
- Achat pour compte
- Points relais
- Notifications
- Évaluation du livreur

---

### Livreur

- Activation et désactivation du statut en ligne
- Liste des courses disponibles
- Estimation des gains
- Acceptation d'une course
- Navigation vers le client
- Progression de la livraison
- Gestion des incidents
- Gestion du dossier KYC
- Tableau de bord des revenus
- Preuves de livraison
- Photos
- Signatures
- Code OTP
- Gestion des réserves
- Paiement MajiPay
- Bouton d'urgence
- Mode économie de données
- Fonctionnement hors ligne

---

### Administrateur

- Tableau de bord
- Supervision de la flotte
- Carte des livreurs
- Gestion des dossiers KYC
- Gestion des courses
- Gestion des litiges
- Comparaison des preuves
- Suspension et réintégration de comptes
- Réaffectation des courses
- Gestion des incidents
- Suivi de l'activité

Les actions d'administration importantes nécessitent un motif obligatoire, notamment pour les suspensions, les refus KYC et les décisions concernant les litiges.

---

## Système de preuve

La chaîne de responsabilité constitue l'un des éléments principaux de MajiChrono.

Lors d'un transfert de responsabilité, l'application peut produire un constat comprenant notamment :

- Photos
- Position GPS
- Horodatage
- Grille d'état
- Scellé
- Signatures
- Code OTP
- Empreinte SHA-256

Les constats sont scellés afin de détecter toute modification ultérieure.

L'application prend également en charge plusieurs situations de remise :

- **Remis au destinataire** : Livraison terminée
- **Remis sous réserves** : Livraison et litige
- **Refusé** : Retour vers l'expéditeur
- **Remis à un tiers** : Livraison avec justificatif
- **Remis sans signature** : Livraison et alerte exploitation

Le module de preuve est actuellement livré et dispose de tests dédiés.

---

## Technologies

- **Flutter** : Application mobile
- **Dart** : Langage
- **Riverpod 2** : Gestion d'état et injection
- **GoRouter** : Navigation
- **Dio** : Communication HTTP
- **Drift** : Base de données locale
- **SQLite** : Stockage local
- **flutter_secure_storage** : Stockage sécurisé
- **ARB / Flutter l10n** : Internationalisation
- **Android SDK** : Compilation Android

### Versions principales

- Flutter 3.44+
- Dart 3.12
- JDK 21
- Android SDK API 35
- Android minimum API 26

---

## Architecture

MajiChrono utilise une architecture en quatre couches :

```text
┌──────────────────────────────┐
│        Présentation          │
│    Écrans · Widgets · UI     │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│           Domaine            │
│ Entités · Use Cases · API    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│           Données            │
│ DTO · Repositories · Sources │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│            Socle             │
│ Réseau · Stockage · i18n     │
└──────────────────────────────┘
```

### Règle principale

Une couche ne doit dépendre que de la couche située en dessous.

Le domaine reste indépendant des technologies externes.

---

## Structure du projet

```text
lib/
│
├── main.dart
├── bootstrap.dart
│
├── app/
│   ├── router/
│   ├── theme/
│   └── shell/
│
├── core/
│   ├── config/
│   ├── error/
│   ├── i18n/
│   ├── logging/
│   ├── network/
│   ├── providers/
│   ├── session/
│   └── storage/
│
├── features/
│   └── <fonctionnalité>/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/
│
└── l10n/
    └── arb/
        ├── app_fr.arb
        └── app_mg.arb
```

Chaque fonctionnalité est organisée autour de trois niveaux :

- `data/`
- `domain/`
- `presentation/`

Cette organisation permet de maintenir une séparation claire entre la logique métier, les données et l'interface.

---

## Internationalisation

L'application prend actuellement en charge :

- Français
- Malagasy

Le changement de langue peut être effectué sans redémarrer l'application.

Tous les textes visibles doivent provenir des fichiers de traduction ARB.

Des tests vérifient notamment :

- l'absence de traductions manquantes
- l'absence de clés inutilisées
- la cohérence des paramètres de traduction
- l'absence de textes écrits directement dans les widgets

---

## Installation

### Prérequis

Installer :

- Flutter 3.44+
- Android Studio
- JDK 21
- Android SDK API 35

Vérifier l'installation de Flutter :

```bash
flutter doctor
```

### Installer les dépendances

```bash
flutter pub get
```

### Générer les traductions

```bash
flutter gen-l10n
```

### Générer les fichiers nécessaires

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Lancement

### Mode recommandé : backend simulé

Le backend réel n'étant pas encore disponible, l'application peut fonctionner avec le backend simulé intégré.

```bash
flutter run --dart-define=API_MODE=mock
```

Aucun serveur externe n'est nécessaire.

### Mode backend réel

Lorsque le backend sera disponible :

```bash
flutter run --dart-define=API_MODE=live --dart-define=API_BASE_URL=https://api.majichrono.mg/v2
```

Le passage de mock à live est prévu pour modifier uniquement la configuration du transport, sans réécrire les fonctionnalités métier.

### Vérification du projet

Analyser le code :

```bash
flutter analyze
```

Lancer les tests :

```bash
flutter test
```

---

## Comptes de démonstration

Le backend simulé fournit trois comptes permettant de tester les différents profils :

- **034 00 000 01** - Client - Hery Rakoto
- **033 00 000 02** - Livreur - Naina Andria
- **032 00 000 03** - Administrateur - Miora Rasoa

En mode simulé, le code OTP est affiché directement dans l'application afin de permettre de tester le parcours sans passerelle SMS.

Tout autre numéro valide peut créer un nouveau compte et passer par le choix du profil.

---

## Mode hors ligne

Le fonctionnement hors connexion est une caractéristique importante de MajiChrono.

Le principe est le suivant :

Une action est d'abord enregistrée localement avant toute tentative d'envoi réseau.

La file de synchronisation permet notamment :

- d'enregistrer les actions hors ligne
- de conserver les données après fermeture de l'application
- de reprendre automatiquement les transmissions
- de gérer les conflits serveur
- de conserver les preuves même après plusieurs échecs
- de reprendre les positions par lots
- de supprimer les photos uniquement après confirmation du serveur

La file de synchronisation est persistante et stockée dans la base locale.

---

## Backend simulé

Le backend simulé permet de développer et tester l'application avant la disponibilité du serveur réel.

Il reproduit notamment :

- réseau 4G
- réseau 3G
- réseau 2G
- absence de réseau
- latence
- erreurs réseau
- reprise des requêtes
- validation des transitions
- données de démonstration

Un panneau développeur permet de modifier le profil réseau et le taux d'échec.

L'objectif est de tester les comportements de l'application dans des conditions réseau difficiles sans dépendre d'un backend distant.

---

## Sécurité

Le projet intègre plusieurs mécanismes de sécurité :

- Stockage sécurisé des secrets
- Code PIN utilisateur
- Authentification biométrique
- Rotation des tokens
- Suppression des données locales lors de la déconnexion
- Chiffrement AES-256 des preuves locales
- Certificate pinning
- Protection contre les captures d'écran sur les écrans sensibles
- Détection des appareils rootés
- Journalisation sans données sensibles

Ces mécanismes permettent de réduire les risques liés à l'accès aux données sensibles présentes sur l'appareil.

---

## État du projet

- **0** - Socle technique - Livré
- **1** - Authentification - Livré
- **2** - Création de course - Livré
- **3** - Suivi et carte - Livré, notifications restantes
- **4** - Livreur - Livré, captures/arrière-plan restants
- **5** - Preuves et responsabilité - Livré
- **6** - Mode hors ligne - Livré
- **7** - Paiement MajiPay - Livré
- **8** - Supervision - Livré
- **9** - Différenciants - Livré
- **10** - Durcissement et recette - Partiellement livré

Le projet est à un stade avancé. Certaines fonctionnalités nécessitent encore une validation sur appareils réels et sur le terrain.

---

## Points restant à finaliser

Les principaux éléments encore ouverts sont :

- Position en arrière-plan avec écran verrouillé
- Visionneuse des pièces KYC
- Acceptation groupée des courses
- Recette sur appareils physiques
- Tests terrain avec des livreurs
- Publication iOS
- Optimisation supplémentaire de la taille de l'APK
- Finalisation des notifications distantes selon la configuration Firebase

Le budget de taille APK de 25 Mo n'est actuellement pas respecté.

La plus petite variante produite est d'environ 28,3 Mo.

---

## Tests automatisés

Le projet possède plusieurs suites de tests :

- **mock_transport_test.dart** : Tester le réseau simulé
- **idempotency_test.dart** : Vérifier l'idempotence
- **error_mapper_test.dart** : Tester la gestion des erreurs
- **redaction_test.dart** : Vérifier l'absence de données sensibles dans les logs
- **translation_completeness_test.dart** : Vérifier les traductions
- **no_literal_strings_test.dart** : Détecter les textes écrits en dur
- **auth_flow_test.dart** : Tester l'authentification
- **delivery_test.dart** : Tester la création de courses
- **widget_test.dart** : Tester la navigation et l'interface

Les tests d'authentification utilisent la pile réelle du projet avec Dio, les intercepteurs et le transport simulé.

---

## Environnement de développement

Le projet recommande d'utiliser le JDK 21 fourni avec Android Studio.

Sous Windows :

```bash
flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"
```

Cette configuration permet d'utiliser le même environnement JDK que celui fourni avec Android Studio.

---

## Décisions produit à finaliser

Certaines décisions métier doivent encore être arbitrées :

- **Valeur juridique des constats** : Mentions affichées lors des signatures
- **Choix du fournisseur cartographique** : Coût et couverture géographique
- **Commission et grille tarifaire** : Prix client et revenus livreur
- **Cadre réglementaire MajiPay** : Architecture du paiement
- **Réseau de points relais** : Couverture hors Antananarivo
- **Publication iOS** : Planning et coût de développement

Ces décisions peuvent influencer certaines parties du développement mobile.

---

## Roadmap

```text
Socle Flutter
      |
      v
Authentification
      |
      v
Création de course
      |
      v
Suivi et carte
      |
      v
Livreur
      |
      v
Preuves de livraison
      |
      v
Mode hors ligne
      |
      v
Paiement MajiPay
      |
      v
Supervision
      |
      v
Optimisations
      |
      v
Tests terrain
      |
      v
Publication
```

---

## Documentation

Le développement est basé sur le cahier des charges :

`MajiChrono_Cahier_des_Charges_Mobile_Flutter.md`

Les références `§x.y` et `EXI-xx##` présentes dans le code correspondent aux exigences du cahier des charges.

---

## Développement

Pour récupérer et lancer le projet :

```bash
git clone <repository-url>
cd MajiChrono
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run --dart-define=API_MODE=mock
```

---

## Résumé

MajiChrono est une application Flutter de livraison conçue pour les contraintes du contexte malgache.

Les principaux objectifs du projet sont :

- fonctionnement hors ligne
- adaptation aux réseaux 2G, 3G et 4G
- gestion complète du parcours client
- gestion complète du parcours livreur
- suivi GPS
- preuves de livraison sécurisées
- paiement MajiPay
- supervision depuis mobile
- support du français et du malagasy
- architecture maintenable et testable
- backend simulé pour le développement

---

## Statut

Application largement implémentée et fonctionnelle.

Les prochaines étapes principales concernent la finalisation de certaines fonctionnalités, les tests sur appareils réels, la recette terrain et la préparation de la publication.
