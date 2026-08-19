"""Authentification : telephone, e-mail, mot de passe.

Une regle gouverne tout ce fichier, et elle vient du terrain : **le numero est
la cle du compte**. Une adresse e-mail, un mot de passe, un compte Google sont
des portes vers un compte qui possede deja un numero. C'est pourquoi
`/auth/email/verify` et `/auth/password/signin` peuvent repondre « adresse
prouvee, aucun compte » : ce n'est pas un echec, c'est le parcours normal d'un
nouvel utilisateur, que l'application enchaine sur la confirmation du numero.
"""

from __future__ import annotations

import re
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Response
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.core.errors import ApiError, conflict, unauthorized, unprocessable
from app.core.deps import current_account
from app.core.mail import send_login_code
from app.core.sms import send_login_code as send_sms_code
from app.core.security import (
    hash_secret,
    issue_access_token,
    new_numeric_code,
    new_opaque_token,
    verify_secret,
)
from app.db import get_db
from app.models import Account, Challenge, ChallengeChannel, RefreshToken

router = APIRouter(prefix="/auth", tags=["auth"])

# Plages reellement exploitees a Madagascar : Orange, Airtel, Telma mobile, et
# le fixe Telma. Refuser les autres tot evite qu'un numero mal recopie parte en
# inscription et attende un SMS qui n'arrivera jamais.
PHONE_PATTERN = re.compile(r"^\+261(32|33|34|38|20)\d{7}$")
EMAIL_PATTERN = re.compile(r"^[^@\s]+@[^@\s.]+\.[^@\s]+$")
MIN_PASSWORD_LENGTH = 8


# --- Corps de requete -------------------------------------------------------


class PhoneRequest(BaseModel):
    phone: str


class VerifyRequest(BaseModel):
    challengeId: str
    code: str


class EmailRequest(BaseModel):
    email: str


class PasswordRequest(BaseModel):
    email: str
    password: str = Field(min_length=1)


class RefreshRequest(BaseModel):
    refreshToken: str


# --- Fabrique de session ----------------------------------------------------


def _issue_session(db: Session, account: Account, family: str | None = None) -> dict:
    settings = get_settings()
    access, access_expires = issue_access_token(
        account.id, account.role.value if account.role else None
    )

    refresh = new_opaque_token()
    refresh_expires = datetime.now(timezone.utc) + timedelta(days=settings.refresh_ttl_days)
    db.add(
        RefreshToken(
            account_id=account.id,
            token_hash=hash_secret(refresh),
            family=family or new_opaque_token()[:32],
            expires_at=refresh_expires,
        )
    )
    db.commit()

    return {
        "accessToken": access,
        "refreshToken": refresh,
        "accessExpiresAt": access_expires.isoformat(),
        "refreshExpiresAt": refresh_expires.isoformat(),
    }


def _open_challenge(
    db: Session, channel: ChallengeChannel, destination: str
) -> tuple[Challenge, str]:
    settings = get_settings()
    code = new_numeric_code()
    challenge = Challenge(
        channel=channel,
        destination=destination,
        code_hash=hash_secret(code),
        attempts_left=settings.otp_max_attempts,
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=settings.otp_ttl_minutes),
    )
    db.add(challenge)
    db.commit()
    return challenge, code


def _consume(db: Session, challenge_id: str, code: str) -> Challenge:
    """Verifie un code et brule le defi. Leve en cas d'echec."""
    challenge = db.get(Challenge, challenge_id)
    if challenge is None or not challenge.is_usable:
        raise unprocessable("unknown_challenge", "Defi inconnu ou deja utilise")

    if not verify_secret(challenge.code_hash, code):
        challenge.attempts_left -= 1
        if challenge.attempts_left <= 0:
            challenge.consumed_at = datetime.now(timezone.utc)
            db.commit()
            raise unprocessable("otp_locked", "Trop de tentatives")
        db.commit()
        raise unprocessable(
            "otp_invalid", "Code incorrect", {"attemptsLeft": challenge.attempts_left}
        )

    challenge.consumed_at = datetime.now(timezone.utc)
    db.commit()
    return challenge


# --- Telephone --------------------------------------------------------------


@router.post("/otp/request")
async def request_otp(body: PhoneRequest, db: Session = Depends(get_db)) -> dict:
    if not PHONE_PATTERN.match(body.phone):
        raise unprocessable(
            "invalid_phone",
            "Numero de telephone malgache invalide",
            {"fields": {"phone": "format_invalide"}},
        )

    challenge, code = _open_challenge(db, ChallengeChannel.sms, body.phone)

    # Meme regle que pour l'e-mail : un echec d'envoi brule le defi et se dit
    # franchement, plutot que de laisser attendre un SMS qui ne viendra pas.
    try:
        await send_sms_code(body.phone, code)
    except Exception:  # noqa: BLE001 — la cause est deja journalisee
        challenge.consumed_at = datetime.now(timezone.utc)
        db.commit()
        raise ApiError(
            502, "sms_delivery_failed", "Impossible d'envoyer le SMS pour le moment"
        ) from None

    # Le code est aussi renvoye dans `debugCode` hors production, ce que
    # l'application n'affiche que si le panneau developpeur est actif. C'est ce
    # qui permet de recetter le parcours sans consommer le quota d'essai SMS.
    settings = get_settings()
    body_out = {
        "challengeId": challenge.id,
        "expiresAt": challenge.expires_at.isoformat(),
        "attemptsLeft": challenge.attempts_left,
    }
    if settings.environment != "prod":
        body_out["debugCode"] = code
    return body_out


@router.post("/otp/verify")
async def verify_otp(body: VerifyRequest, db: Session = Depends(get_db)) -> dict:
    challenge = _consume(db, body.challengeId, body.code)

    account = db.scalar(select(Account).where(Account.phone == challenge.destination))
    if account is None:
        # Premiere venue : le compte nait ici, sans profil. Le profil se pose
        # ensuite par PATCH /me (EXI-T02).
        account = Account(phone=challenge.destination)
        db.add(account)
        db.commit()

    return {"session": _issue_session(db, account), "account": account.to_json()}


# --- Adresse e-mail ---------------------------------------------------------


@router.post("/email/request")
async def request_email_code(body: EmailRequest, db: Session = Depends(get_db)) -> dict:
    email = body.email.strip().lower()
    if not EMAIL_PATTERN.match(email):
        raise unprocessable(
            "invalid_email",
            "Adresse e-mail invalide",
            {"fields": {"email": "format_invalide"}},
        )

    challenge, code = _open_challenge(db, ChallengeChannel.email, email)

    # Un echec d'envoi ne doit ni remonter en 500, ni laisser croire au mobile
    # que le code est parti. Le defi est brule au passage : personne ne l'a
    # recu, il ne doit pas rester ouvert cinq minutes a etre devine.
    try:
        await send_login_code(email, code)
    except Exception:  # noqa: BLE001 — la cause est deja journalisee
        challenge.consumed_at = datetime.now(timezone.utc)
        db.commit()
        raise ApiError(
            502,
            "mail_delivery_failed",
            "Impossible d'envoyer le code pour le moment",
        ) from None

    # La reponse ne dit **pas** si l'adresse est connue. Le savoir avant d'avoir
    # prouve la possession de la boite permettrait d'enumerer les comptes.
    settings = get_settings()
    body_out = {
        "challengeId": challenge.id,
        "email": email,
        "expiresAt": challenge.expires_at.isoformat(),
        "attemptsLeft": challenge.attempts_left,
    }
    if settings.environment != "prod":
        body_out["debugCode"] = code
    return body_out


@router.post("/email/verify")
async def verify_email_code(body: VerifyRequest, db: Session = Depends(get_db)) -> dict:
    challenge = _consume(db, body.challengeId, body.code)
    return _session_for_email(db, challenge.destination)


def _session_for_email(db: Session, email: str) -> dict:
    account = db.scalar(select(Account).where(Account.email == email))
    if account is None:
        # Adresse prouvee, compte inconnu. Aucune session : un compte sans
        # numero ne pourrait ni etre appele par un livreur, ni recevoir le SMS
        # de suivi (EXI-C24).
        return {"linked": False, "email": email}

    return {
        "linked": True,
        "session": _issue_session(db, account),
        "account": account.to_json(),
    }


@router.post("/email/link", status_code=204, response_class=Response)
async def link_email(
    body: EmailRequest,
    db: Session = Depends(get_db),
    account: Account = Depends(current_account),
):
    email = body.email.strip().lower()
    if not EMAIL_PATTERN.match(email):
        raise unprocessable("invalid_email", "Adresse e-mail invalide")

    taken = db.scalar(select(Account).where(Account.email == email))
    if taken is not None and taken.id != account.id:
        raise conflict(
            "email_already_linked", "Cette adresse est deja rattachee a un autre compte"
        )

    account.email = email
    db.commit()


# --- Mot de passe -----------------------------------------------------------


@router.post("/password/signin")
async def sign_in_with_password(body: PasswordRequest, db: Session = Depends(get_db)) -> dict:
    email = body.email.strip().lower()
    account = db.scalar(select(Account).where(Account.email == email))

    # Une seule reponse d'echec pour « adresse inconnue » et « mot de passe
    # faux ». Les distinguer dirait a un attaquant quelles adresses portent un
    # compte, ce que le point d'entree par code refuse deja de dire.
    if account is None or not account.password_hash:
        raise unauthorized("E-mail ou mot de passe incorrect")
    if not verify_secret(account.password_hash, body.password):
        raise unauthorized("E-mail ou mot de passe incorrect")

    return {
        "linked": True,
        "session": _issue_session(db, account),
        "account": account.to_json(),
    }


@router.post("/password/signup")
async def sign_up_with_password(body: PasswordRequest, db: Session = Depends(get_db)) -> dict:
    email = body.email.strip().lower()
    if not EMAIL_PATTERN.match(email):
        raise unprocessable("invalid_email", "Adresse e-mail invalide")
    if len(body.password) < MIN_PASSWORD_LENGTH:
        raise unprocessable(
            "weak_password", "Mot de passe trop court", {"minLength": MIN_PASSWORD_LENGTH}
        )

    existing = db.scalar(select(Account).where(Account.email == email))
    if existing is not None:
        raise conflict("email_taken", "Cette adresse a deja un compte")

    # Le mot de passe est retenu **sans creer de compte** : le compte naitra a
    # la confirmation du numero. On le range dans un defi consomme, qui sert de
    # bloc-notes a duree de vie courte plutot que d'ouvrir une table de plus.
    challenge = Challenge(
        channel=ChallengeChannel.email,
        destination=email,
        code_hash=hash_secret(body.password),
        attempts_left=0,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
        consumed_at=datetime.now(timezone.utc),
    )
    db.add(challenge)
    db.commit()

    return {"linked": False, "email": email}


# --- Cycle de session -------------------------------------------------------


@router.post("/refresh")
async def refresh_session(body: RefreshRequest, db: Session = Depends(get_db)) -> dict:
    now = datetime.now(timezone.utc)
    candidates = db.scalars(
        select(RefreshToken).where(RefreshToken.expires_at > now)
    ).all()

    stored = next(
        (t for t in candidates if verify_secret(t.token_hash, body.refreshToken)), None
    )
    if stored is None:
        raise unauthorized("Jeton de rafraichissement invalide")

    if stored.revoked_at is not None:
        # Jeton deja tourne, presente a nouveau : quelqu'un rejoue un jeton
        # vole. Toute la famille tombe, ce qui deconnecte l'attaquant **et** le
        # porteur legitime — c'est voulu : mieux vaut une reconnexion qu'un
        # acces partage a son insu.
        for token in db.scalars(
            select(RefreshToken).where(RefreshToken.family == stored.family)
        ).all():
            token.revoked_at = now
        db.commit()
        raise unauthorized("Session revoquee")

    stored.revoked_at = now
    db.commit()

    return {"session": _issue_session(db, stored.account, family=stored.family)}


@router.post("/logout", status_code=204, response_class=Response)
async def logout(
    db: Session = Depends(get_db), account: Account = Depends(current_account)
):
    now = datetime.now(timezone.utc)
    for token in db.scalars(
        select(RefreshToken).where(
            RefreshToken.account_id == account.id, RefreshToken.revoked_at.is_(None)
        )
    ).all():
        token.revoked_at = now
    db.commit()
