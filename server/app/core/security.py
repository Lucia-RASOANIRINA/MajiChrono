"""Empreintes, jetons, et le vocabulaire d'erreur attendu par le mobile."""

from __future__ import annotations

import secrets
from datetime import datetime, timedelta, timezone

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError, VerificationError

from app.config import get_settings

_hasher = PasswordHasher()


def hash_secret(value: str) -> str:
    """Empreinte Argon2 d'un mot de passe ou d'un code (§8.4)."""
    return _hasher.hash(value)


def verify_secret(hashed: str, value: str) -> bool:
    """Verifie une empreinte sans jamais lever pour un simple echec.

    `argon2` distingue « ne correspond pas » de « empreinte illisible ». Les
    deux doivent se lire ici comme un refus : une empreinte corrompue en base ne
    doit pas ouvrir de session, ni faire tomber le serveur.
    """
    try:
        return _hasher.verify(hashed, value)
    except (VerifyMismatchError, VerificationError):
        return False


def new_numeric_code(digits: int = 6) -> str:
    """Code a usage unique, tire d'une source cryptographique.

    `secrets` et non `random` : le second est previsible a partir de quelques
    tirages, ce qui suffirait a deviner le code d'un autre.
    """
    upper = 10**digits
    return str(secrets.randbelow(upper)).zfill(digits)


def new_opaque_token() -> str:
    return secrets.token_urlsafe(48)


def issue_access_token(account_id: str, role: str | None) -> tuple[str, datetime]:
    settings = get_settings()
    expires = datetime.now(timezone.utc) + timedelta(minutes=settings.access_ttl_minutes)
    payload = {
        "sub": account_id,
        "role": role,
        "typ": "access",
        "exp": expires,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256"), expires


def read_access_token(token: str) -> dict | None:
    """Rend les revendications, ou `None` si le jeton ne vaut rien.

    Toute anomalie — signature, expiration, format — donne le meme resultat :
    l'appelant n'a pas a distinguer un jeton expire d'un jeton forge, et le lui
    dire renseignerait un attaquant.
    """
    settings = get_settings()
    try:
        claims = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
    except jwt.PyJWTError:
        return None
    return claims if claims.get("typ") == "access" else None
