"""Le compte de la session courante."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.deps import current_account
from app.core.errors import conflict, forbidden, unprocessable
from app.db import get_db
from app.models import Account, KycStatus, UserRole

router = APIRouter(tags=["me"])


class PatchMe(BaseModel):
    role: str | None = None
    displayName: str | None = None


@router.get("/me")
async def read_me(account: Account = Depends(current_account)) -> dict:
    return account.to_json()


@router.patch("/me")
async def patch_me(
    body: PatchMe,
    db: Session = Depends(get_db),
    account: Account = Depends(current_account),
) -> dict:
    if body.role is not None:
        # Le role d'exploitation est attribue **cote serveur uniquement**
        # (EXI-T02). Une application qui le reclame doit etre refusee, pas
        # ignoree : ignorer laisserait croire que la demande a abouti.
        if body.role == UserRole.admin.value:
            raise forbidden(
                "role_not_assignable",
                "Le role administrateur est attribue cote serveur",
            )
        if body.role not in (UserRole.client.value, UserRole.driver.value):
            raise unprocessable("invalid_role", "Role inconnu")

        # Le profil ne se choisit qu'une fois : en changer changerait la nature
        # du compte et l'historique qui s'y rattache.
        if account.role is not None and account.role.value != body.role:
            raise conflict("role_already_set", "Profil deja defini")

        account.role = UserRole(body.role)
        if account.role is UserRole.driver and account.kyc_status is None:
            account.kyc_status = KycStatus.draft

    if body.displayName is not None:
        account.display_name = body.displayName

    db.commit()
    return account.to_json()
