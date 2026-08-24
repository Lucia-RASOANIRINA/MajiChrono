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

Le projet a deux moitiés : le **serveur** (`server/`, FastAPI + PostgreSQL) et
l'**application** (Flutter). On peut lancer l'application seule contre son
backend simulé, ou lancer les deux ensemble.

### Option A — Application seule (backend simulé)

Aucun serveur, aucune base : le simulateur embarqué répond à la place du
serveur. C'est le mode le plus rapide pour parcourir l'interface.

```bash
flutter run --dart-define=API_MODE=mock
```

En mode simulé, le code OTP est affiché dans l'application (`debugCode`) : le
parcours de connexion se teste sans passerelle SMS ni e-mail.

### Option B — Projet complet (serveur réel + application)

#### 1. Démarrer le serveur

Prérequis : **Python 3.12** (les dépendances sont épinglées à des versions qui
ont des paquets précompilés pour 3.12 ; 3.13/3.14 obligeraient à compiler
psycopg et pydantic-core à la main).

```bash
cd server

# Environnement isolé
py -3.12 -m venv .venv          # ou : python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt

# Configuration : copier l'exemple, puis générer un secret
copy .env.example .env
python -c "import secrets;print(secrets.token_urlsafe(48))"   # -> coller dans JWT_SECRET

# Créer le schéma (développement)
python -c "from app.db import create_all; create_all()"

# Lancer
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Le serveur écoute alors sur `http://localhost:8000`. Vérifier :

```bash
curl http://localhost:8000/health
```

La documentation interactive de l'API est sur `http://localhost:8000/docs`.

#### 2. Lancer l'application, connectée au serveur

```bash
# Émulateur Android : la machine hôte est vue comme 10.0.2.2
flutter run --dart-define=API_MODE=live --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Appareil physique sur le même Wi-Fi : mettre l'IP locale de la machine
flutter run --dart-define=API_MODE=live --dart-define=API_BASE_URL=http://192.168.x.x:8000
```

Le passage de `mock` à `live` ne change que la configuration du transport, jamais
la logique métier.

> Si le port `8000` est déjà pris par un autre service (un serveur PHP local, par
> exemple), lancez le serveur sur un autre port — `uvicorn app.main:app --port 8010`
> — et pointez l'application vers `http://10.0.2.2:8010`.

#### 3. Créer des données de test

Deux scripts peuplent une base neuve sans passer par l'interface. Ils sont
**idempotents** : les relancer ne crée pas de doublon.

```bash
cd server

# Compte administrateur (connexion e-mail -> mot de passe)
.venv\Scripts\python -m app.tools.seed_admin

# Jeu de démonstration : 1 expéditeur, 1 livreur, 5 courses réparties sur
# les états (en attente / assignée / en transit / livrée), avec leur journal
.venv\Scripts\python -m app.tools.seed_test_data
```

Comptes créés :

| Rôle | Identifiant | Détails |
|---|---|---|
| Administrateur | `majitech@gmail.com` / `majichrono` | connexion e-mail → mot de passe ; numéro réservé `+261340000000` |
| Expéditeur | `+261340000001` | Rina Rakoto — 5 courses de démonstration |
| Livreur | `+261330000002` | Tovo Livreur — en ligne, KYC validé, position à Ankorondrano |

En développement, le code OTP est renvoyé dans la réponse (`debugCode`) et écrit
dans le journal du serveur : la connexion par téléphone se teste sans passerelle
SMS. Pour se connecter, saisir l'un des numéros ci-dessus sur l'écran téléphone,
puis lire le code dans la réponse ou le journal.

> Ces identifiants sont réservés au développement. Ne jamais les committer tels
> quels pour un déploiement réel.

---

## Base de données

Le code des routes ne change pas d'une ligne entre les trois bases : SQLAlchemy
les sert toutes. On choisit avec la variable `DATABASE_URL` de `server/.env`.

### SQLite — par défaut, pour démarrer sans rien installer

```env
DATABASE_URL=sqlite:///./majichrono.db
```

Le fichier `server/majichrono.db` est créé automatiquement. C'est aussi la base
**hors-ligne côté serveur** : elle fonctionne sans réseau ni installation.

> À ne pas confondre avec le **hors-ligne de l'application** (voir la section
> « Mode hors ligne ») : celui-ci est une base locale embarquée **dans le
> téléphone**, qui garde les actions tant que le réseau manque puis les
> synchronise avec le serveur.

### PostgreSQL local — pour développer et tester au plus près de la production

C'est la base qui tient la concurrence et les transactions longues. Créer la
base et l'utilisateur une seule fois (adapter le port : une installation
PostgreSQL 17 native écoute souvent sur **5433**, un conteneur sur 5432) :

```sql
-- Connecté en superutilisateur (psql -U postgres -p 5433) :
CREATE USER majichrono WITH PASSWORD 'majichrono';
CREATE DATABASE majichrono OWNER majichrono;
```

Puis dans `server/.env` :

```env
DATABASE_URL=postgresql+psycopg://majichrono:majichrono@localhost:5433/majichrono
```

Recréer le schéma : `python -c "from app.db import create_all; create_all()"`.

Variante par conteneur (si Docker est disponible) :

```bash
docker run -d --name majichrono-db -p 5432:5432 \
  -e POSTGRES_USER=majichrono -e POSTGRES_PASSWORD=majichrono \
  -e POSTGRES_DB=majichrono postgres:16
```

### Neon — PostgreSQL infogéré, pour le déploiement

Neon héberge la base dans le cloud : plusieurs appareils voient les mêmes
données, ce que le local ne permet pas. Offre gratuite, sans carte bancaire.

1. Créer un projet sur [console.neon.tech](https://console.neon.tech). Choisir
   la région la plus proche de Madagascar : **eu-central-1 (Francfort)** ajoute
   deux à trois fois moins de latence qu'une région américaine.
2. Dashboard → **Connection string** → onglet **Pooled connection**.
3. Remplacer le préfixe `postgresql://` par `postgresql+psycopg://`.
4. Garder `?sslmode=require` à la fin : Neon refuse les connexions en clair.

```env
DATABASE_URL=postgresql+psycopg://user:mdp@ep-xxx-pooler.eu-central-1.aws.neon.tech/majichrono?sslmode=require
```

> Neon met les bases inactives en veille ; le premier appel après une pause paie
> le réveil (jusqu'à ~5 s). C'est normal.

Le fichier `server/.env.neon.example` est prêt à copier.

---

## E-mail réel (code de connexion par e-mail)

Sans configuration SMTP, le serveur **écrit le code dans son journal** au lieu de
l'envoyer (et le renvoie dans `debugCode` hors production). C'est voulu : le
parcours complet se teste sans compte fournisseur. Pour envoyer de vrais
e-mails, renseigner quatre variables dans `server/.env`.

### Obtenir une clé Resend (recommandé pour la production)

Resend offre 3 000 e-mails/mois sans carte bancaire.

1. Créer un compte sur [resend.com](https://resend.com) (bouton **Sign up**).
2. Menu **API Keys** → **Create API Key**. Donner un nom (`majichrono`),
   permission **Sending access**. Copier la clé affichée — elle commence par
   `re_` et **ne s'affiche qu'une fois**.
3. Menu **Domains** → **Add Domain** : ajouter votre domaine, puis publier chez
   votre registrar les enregistrements **SPF, DKIM et DMARC** que Resend
   affiche. Cette étape n'est pas optionnelle : sans elle, les codes partent en
   indésirables — pire qu'une absence d'e-mail, car l'utilisateur ne sait pas où
   chercher.
   - Pour un simple essai avant d'avoir un domaine, l'adresse
     `onboarding@resend.dev` fournie par Resend permet d'envoyer vers votre
     propre adresse.
4. Renseigner `server/.env` :

```env
SMTP_HOST=smtp.resend.com
SMTP_PORT=587
SMTP_USER=resend
SMTP_PASSWORD=re_votre_cle
MAIL_FROM_ADDRESS=no-reply@votre-domaine.mg   # doit appartenir au domaine vérifié
MAIL_FROM_NAME=MajiChrono
```

5. Redémarrer le serveur. Un test rapide : `python -m app.tools.check_mail`.

### Variante Gmail (pour la recette, ~500 envois/jour)

Le mot de passe du compte **ne marche pas** : Google exige un « mot de passe
d'application », à créer sur
[myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
après avoir activé la validation en deux étapes.

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre.adresse@gmail.com
SMTP_PASSWORD=xxxx xxxx xxxx xxxx
```

---

## SMS réel (code de connexion par téléphone)

Même principe : tant que `SMS_API_KEY` est vide, le code part dans le journal du
serveur, jamais sur le réseau — pour ne pas consommer le quota d'essai pendant
le développement. Le premier envoi réel doit être un geste décidé.

La passerelle utilisée est **mAPI** (Madagascar) : locale, les codes partent
d'un numéro court malgache et arrivent sur Orange, Airtel et Telma sans passer
par un agrégateur étranger.

1. Ouvrir un compte sur [messaging.mapi.mg/subscriber](https://messaging.mapi.mg/subscriber).
2. Récupérer la clé d'API.
3. Faire déclarer `MajiChrono` comme nom d'expéditeur (11 caractères maximum).
4. Renseigner `server/.env`, puis redémarrer :

```env
SMS_API_KEY=votre_cle_mapi
SMS_SENDER=MajiChrono
```

Une fois la clé posée, l'écran de connexion par téléphone envoie un vrai SMS ;
le code n'apparaît plus dans l'application.

---

## Espace administrateur (accès unique)

Le rôle **administrateur** est attribué **côté serveur** et ne se choisit jamais
depuis l'application : l'écran de profil n'offre que « expéditeur » et
« livreur ». Le seul point d'entrée du rôle admin est un script, ce qui garantit
qu'il n'existe qu'**un seul** administrateur tant qu'on ne le lance qu'une fois.

```bash
cd server
.venv\Scripts\python -m app.tools.seed_admin
```

Cela crée (ou met à jour, sans doublon) le compte :

- **E-mail** : `majitech@gmail.com`
- **Mot de passe** : `majichrono`
- Connexion dans l'app : écran **« Avec une adresse e-mail » → mot de passe**.

Le script signale tout autre compte admin déjà présent, pour que l'accès reste
unique. Changez ces identifiants avant la production.

## Numéros et opérateurs

Seuls les préfixes réellement exploités à Madagascar sont acceptés à la saisie
(côté application **et** côté serveur — la même règle aux deux bouts) :

| Opérateur | Préfixes |
|---|---|
| Telma | 034, 038 |
| Orange | 032, 037, 039 |
| Airtel | 033 |
| Telma fixe (e-mail uniquement, pas de SMS) | 020 |

Un numéro en 030, 031, 035 ou 036 est refusé avec un message qui nomme les
opérateurs attendus.

## Pas de comptes en double

Le **numéro de téléphone est la clé du compte** : la colonne `accounts.phone`
est **unique** en base, tout comme `accounts.email`. Concrètement :

- Se connecter avec un numéro déjà enregistré **rouvre le compte existant** — il
  n'en crée jamais un second.
- Une inscription par mot de passe sur une adresse déjà prise est refusée
  (`email_taken`), et rattacher une adresse déjà liée à un autre compte aussi.

La redondance est donc empêchée par le schéma lui-même, pas par une vérification
qu'on pourrait oublier d'appeler.

## Vérifier le serveur

Depuis `server/`, la suite de tests tourne sur une base en mémoire, sans toucher
à votre base :

```bash
.venv\Scripts\python -m pytest -q
```

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
