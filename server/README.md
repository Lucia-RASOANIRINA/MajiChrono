# Serveur MajiChrono

FastAPI + PostgreSQL. Il sert le contrat d'API que l'application mobile
consomme aujourd'hui contre son simulateur embarque : memes chemins, memes noms
de champs, meme format d'erreur.

## Ce qui est ecrit

| Domaine | Etat |
|---|---|
| Socle : configuration, base, securite, format d'erreur, idempotence | ecrit |
| Authentification telephone (OTP) | ecrit |
| Authentification e-mail (code) **avec envoi reel** | ecrit |
| Authentification mot de passe | ecrit |
| Rotation et revocation de session | ecrit |
| `GET` / `PATCH /me` | ecrit |
| Courses : creation, transitions, annulation, journal | ecrit, teste |
| Suivi public par jeton | ecrit, teste |
| Livreur : disponibilite, offres, positions, gains | ecrit, teste |
| Exploitation : tableau de bord, flotte, dossiers, suspensions | ecrit, teste |
| Chaine de garde, paiement | **a faire** |
| Envoi de SMS | **volontairement en dernier** |

**49 tests** couvrent ces routes. Lancez-les depuis `server/` :

```bash
.venv\Scripts\python -m pytest -q
```

Chaque test recoit sa propre base en memoire : ils sont independants de l'ordre
d'execution, et un compte cree par l'un ne fait pas echouer l'unicite chez
l'autre.

Ces tests ont deja trouve deux defauts qu'une relecture avait laisses passer :
un livreur ne pouvait accepter aucune course — le controle de visibilite le
rejetait avant que la logique d'acceptation ne soit atteinte — et le perdant de
la course a l'acceptation lisait « transition impossible » au lieu de « course
deja prise ».

## Demarrer

```bash
# 1. Python 3.12 (les versions epinglees ont des paquets precompiles pour 3.12 ;
#    3.13/3.14 obligeraient a compiler psycopg et pydantic-core a la main)
py -3.12 -m venv .venv          # ou : python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt

# 2. PostgreSQL, en local ou par conteneur
docker run -d --name majichrono-db -p 5432:5432 \
  -e POSTGRES_USER=majichrono \
  -e POSTGRES_PASSWORD=majichrono \
  -e POSTGRES_DB=majichrono postgres:16

# 3. Configuration
copy .env.example .env
python -c "import secrets;print(secrets.token_urlsafe(48))"   # -> JWT_SECRET

# 4. Schema (developpement)
python -c "from app.db import create_all; create_all()"

# 5. Lancer
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

L'application mobile doit alors pointer sur `http://VOTRE_IP:8000`. Depuis un
emulateur Android, `10.0.2.2` designe la machine hote.

## Recevoir un vrai e-mail

L'envoi passe par **SMTP** — le denominateur commun de tous les fournisseurs.
Changer de fournisseur ne coute que quatre variables d'environnement, jamais une
reecriture. Recommande : **Resend** (3 000 envois/mois, sans carte bancaire).

1. Creez un compte sur [resend.com](https://resend.com).
2. **API Keys → Create API Key** : copiez la cle (`re_...`, affichee une seule
   fois).
3. **Domains → Add Domain** : ajoutez votre domaine et publiez les
   enregistrements **SPF, DKIM et DMARC** affiches par Resend.
4. Renseignez `.env` :

   ```env
   SMTP_HOST=smtp.resend.com
   SMTP_PORT=587
   SMTP_USER=resend
   SMTP_PASSWORD=re_votre_cle
   MAIL_FROM_ADDRESS=no-reply@votre-domaine.mg
   ```

L'etape 3 n'est pas optionnelle. Sans elle, vos codes partent en indesirables —
ce qui est pire qu'une absence d'e-mail, parce que l'utilisateur ne sait pas ou
chercher et conclut que l'application ne marche pas.

Sans configuration SMTP, le serveur ecrit le code dans son journal, precede de
`AUCUN SMTP CONFIGURE`. Le parcours complet se deroule donc sans compte
fournisseur. Le guide detaille (Resend et variante Gmail) est dans le README
racine.

## Deux principes qui gouvernent ce code

**Le numero de telephone est la cle du compte.** Une adresse e-mail, un mot de
passe, un compte Google ne sont que des portes vers un compte qui possede deja
un numero. C'est pourquoi `/auth/email/verify` peut repondre « adresse prouvee,
aucun compte » : ce n'est pas un echec, c'est le parcours normal d'un nouvel
utilisateur. Le schema l'impose — `accounts.phone` est obligatoire et unique.

**Aucun secret n'est stocke en clair.** Mots de passe et codes a usage unique
partagent la meme empreinte Argon2. Une fuite de la base ne donne ni les mots de
passe, ni les codes en vol.

## Ce que le serveur ne dit jamais

- Si une adresse porte un compte, avant que la possession de la boite ne soit
  prouvee. Le dire permettrait d'enumerer les comptes.
- La difference entre « adresse inconnue » et « mot de passe faux ». Meme raison.
- Le detail d'un refus du fournisseur d'e-mail. Il est journalise cote serveur ;
  le mobile n'a rien a apprendre de cette plomberie.
