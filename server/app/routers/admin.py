"""Exploitation : tableau de bord, flotte, dossiers, suspensions.

Une regle traverse ce fichier : **une decision qui touche le gagne-pain de
quelqu'un exige un motif ecrit**. Refuser un dossier, suspendre un livreur —
ces gestes se justifient, et le motif est stocke avec la decision. Ce n'est pas
une politesse : c'est ce qui permet de repondre a un livreur qui demande
pourquoi il ne peut plus travailler, six mois plus tard.
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.deps import require_role
from app.core.errors import not_found, unprocessable
from app.db import get_db
from app.models import (
    Account,
    Delivery,
    DeliveryStatus,
    DriverState,
    KycStatus,
    ModerationLog,
    UserRole,
    as_utc,
)

router = APIRouter(prefix="/admin", tags=["admin"])

# Longueur minimale d'un motif. Dix caracteres n'empechent pas d'ecrire « ok »
# suivi de huit espaces, mais ils empechent le champ vide — et c'est le champ
# vide qui rend une decision inexplicable des le lendemain.
MIN_REASON_LENGTH = 10

POSITION_FRESHNESS = timedelta(minutes=3)


class Review(BaseModel):
    approve: bool
    reason: str


class Suspension(BaseModel):
    suspend: bool
    reason: str


def _require_reason(reason: str) -> str:
    cleaned = reason.strip()
    if len(cleaned) < MIN_REASON_LENGTH:
        raise unprocessable(
            "reason_too_short",
            "Un motif d'au moins dix caracteres est exige",
            {"minLength": MIN_REASON_LENGTH},
        )
    return cleaned


@router.get("/dashboard")
async def dashboard(
    db: Session = Depends(get_db), _: Account = Depends(require_role(UserRole.admin))
) -> dict:
    def compter(*conditions) -> int:
        return db.scalar(select(func.count()).select_from(Delivery).where(*conditions)) or 0

    actives = [
        DeliveryStatus.assigned,
        DeliveryStatus.picked_up,
        DeliveryStatus.in_transit,
    ]
    today = datetime.now(timezone.utc).date()

    delivered = db.scalars(
        select(Delivery).where(Delivery.status == DeliveryStatus.delivered)
    ).all()

    return {
        "pendingKyc": db.scalar(
            select(func.count())
            .select_from(Account)
            .where(Account.kyc_status == KycStatus.submitted)
        )
        or 0,
        "activeDeliveries": compter(Delivery.status.in_(actives)),
        "pendingDeliveries": compter(Delivery.status == DeliveryStatus.pending),
        "onlineDrivers": db.scalar(
            select(func.count()).select_from(DriverState).where(DriverState.online.is_(True))
        )
        or 0,
        # Recette du jour : seules les courses **remises**. Compter les courses
        # en cours gonflerait le chiffre d'affaires d'argent pas encore gagne.
        "revenueTodayAriary": sum(
            d.price_ariary or 0
            for d in delivered
            if as_utc(d.updated_at).date() == today
        ),
        "byStatus": {
            status.value: compter(Delivery.status == status) for status in DeliveryStatus
        },
    }


@router.get("/fleet")
async def fleet(
    db: Session = Depends(get_db), _: Account = Depends(require_role(UserRole.admin))
) -> dict:
    """Les livreurs et leur derniere position connue.

    Chaque ligne porte `stale` : vrai quand la position a plus de trois minutes.
    Un point sur une carte qui ne dit pas son age est un mensonge — on croit
    voir ou est quelqu'un alors qu'on voit ou il etait.
    """
    now = datetime.now(timezone.utc)
    rows = db.execute(
        select(Account, DriverState)
        .join(DriverState, DriverState.account_id == Account.id, isouter=True)
        .where(Account.role == UserRole.driver)
    ).all()

    items = []
    for account, state in rows:
        fixed_at = as_utc(state.fixed_at) if state and state.fixed_at else None
        items.append(
            {
                "driverId": account.id,
                "displayName": account.display_name,
                "phone": account.phone,
                "kycStatus": account.kyc_status.value if account.kyc_status else None,
                "suspended": account.suspended_at is not None,
                "online": bool(state and state.online),
                "lat": state.lat if state else None,
                "lng": state.lng if state else None,
                "fixedAt": fixed_at.isoformat() if fixed_at else None,
                "stale": fixed_at is None or (now - fixed_at) > POSITION_FRESHNESS,
            }
        )
    return {"items": items}


@router.get("/kyc")
async def kyc_queue(
    db: Session = Depends(get_db), _: Account = Depends(require_role(UserRole.admin))
) -> dict:
    pending = db.scalars(
        select(Account)
        .where(Account.kyc_status.in_([KycStatus.submitted, KycStatus.under_review]))
        .order_by(Account.created_at)
    ).all()

    return {
        "items": [
            {
                "driverId": a.id,
                "displayName": a.display_name,
                "phone": a.phone,
                "status": a.kyc_status.value,
                "submittedAt": as_utc(a.created_at).isoformat(),
            }
            for a in pending
        ]
    }


@router.post("/kyc/{driver_id}/review")
async def review_kyc(
    driver_id: str,
    body: Review,
    db: Session = Depends(get_db),
    admin: Account = Depends(require_role(UserRole.admin)),
) -> dict:
    reason = _require_reason(body.reason)

    driver = db.get(Account, driver_id)
    if driver is None or driver.role is not UserRole.driver:
        raise not_found("Livreur inconnu")

    driver.kyc_status = KycStatus.approved if body.approve else KycStatus.rejected
    db.add(
        ModerationLog(
            actor_id=admin.id,
            subject_id=driver.id,
            action="kyc_approved" if body.approve else "kyc_rejected",
            reason=reason,
        )
    )
    db.commit()

    return {"driverId": driver.id, "kycStatus": driver.kyc_status.value}


@router.post("/drivers/{driver_id}/suspension")
async def suspend_driver(
    driver_id: str,
    body: Suspension,
    db: Session = Depends(get_db),
    admin: Account = Depends(require_role(UserRole.admin)),
) -> dict:
    reason = _require_reason(body.reason)

    driver = db.get(Account, driver_id)
    if driver is None or driver.role is not UserRole.driver:
        raise not_found("Livreur inconnu")

    driver.suspended_at = datetime.now(timezone.utc) if body.suspend else None

    # Une suspension coupe aussi la disponibilite : laisser un suspendu « en
    # ligne » le ferait apparaitre sur la carte et recevoir des offres qu'il ne
    # peut pas accepter.
    state = db.get(DriverState, driver.id)
    if state is not None and body.suspend:
        state.online = False

    db.add(
        ModerationLog(
            actor_id=admin.id,
            subject_id=driver.id,
            action="suspended" if body.suspend else "unsuspended",
            reason=reason,
        )
    )
    db.commit()

    return {"driverId": driver.id, "suspended": driver.suspended_at is not None}


@router.get("/moderation")
async def moderation_history(
    db: Session = Depends(get_db), _: Account = Depends(require_role(UserRole.admin))
) -> dict:
    """Journal des decisions, en ajout seul.

    Aucune route ne le modifie ni ne l'efface. C'est ce qui permet de repondre a
    « pourquoi ce livreur a-t-il ete suspendu ? » longtemps apres, et de savoir
    qui a decide.
    """
    entries = db.scalars(
        select(ModerationLog).order_by(ModerationLog.decided_at.desc())
    ).all()
    return {"items": [e.to_json() for e in entries]}
