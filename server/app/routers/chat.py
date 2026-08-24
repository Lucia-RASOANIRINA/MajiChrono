"""Discussion entre l'expediteur et le livreur d'une course.

La discussion s'ouvre a l'acceptation : tant qu'aucun livreur n'est assigne, il
n'y a personne a qui parler, et la route le dit (404). Une fois la course prise,
seuls ses deux protagonistes — l'expediteur et le livreur assigne — peuvent lire
et ecrire ; l'exploitation elle-meme n'y entre pas sans y etre partie.

Il n'y a pas de WebSocket : l'application relit les messages a intervalle court,
avec un curseur `after` pour ne demander que le nouveau. Sur un reseau
d'Antananarivo, un canal permanent tomberait a la premiere zone d'ombre ; une
relecture legere se reprend d'elle-meme a la reconnexion, comme le reste de
l'application.
"""

from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.core.deps import current_account
from app.core.errors import not_found, unprocessable
from app.db import get_db
from app.models import Account, Delivery, Message, as_utc

router = APIRouter(tags=["chat"])

# Un message ne dit rien d'utile au-dela de quelques lignes : le limiter evite
# qu'un collage accidentel ne devienne un pave illisible pour l'autre.
MAX_MESSAGE_LENGTH = 2000


class MessageIn(BaseModel):
    body: str = Field(min_length=1, max_length=MAX_MESSAGE_LENGTH)


def _delivery_for_chat(db: Session, delivery_id: str, account: Account) -> Delivery:
    """Retourne la course si le compte a le droit d'en voir la discussion.

    On repond 404 — et non 403 — a qui n'est pas partie prenante : lui dire
    « interdit » confirmerait l'existence de la course. Et tant que la course
    n'a pas de livreur, la discussion n'existe pas encore.
    """
    delivery = db.get(Delivery, delivery_id)
    if delivery is None:
        raise not_found("Course inconnue")
    if account.id not in (delivery.client_id, delivery.driver_id):
        raise not_found("Course inconnue")
    if delivery.driver_id is None:
        raise not_found("La discussion s'ouvre a l'acceptation de la course")
    return delivery


@router.get("/deliveries/{delivery_id}/messages")
async def list_messages(
    delivery_id: str,
    after: str | None = None,
    db: Session = Depends(get_db),
    account: Account = Depends(current_account),
) -> dict:
    delivery = _delivery_for_chat(db, delivery_id, account)

    query = select(Message).where(Message.delivery_id == delivery.id)
    if after:
        try:
            moment = datetime.fromisoformat(after)
        except ValueError:
            raise unprocessable("invalid_cursor", "Curseur de date invalide")
        query = query.where(Message.created_at > moment)

    messages = db.scalars(query.order_by(Message.created_at)).all()
    return {"items": [m.to_json() for m in messages]}


@router.post("/deliveries/{delivery_id}/messages")
async def send_message(
    delivery_id: str,
    body: MessageIn,
    db: Session = Depends(get_db),
    account: Account = Depends(current_account),
) -> dict:
    delivery = _delivery_for_chat(db, delivery_id, account)

    text = body.body.strip()
    if not text:
        raise unprocessable("empty_message", "Message vide")

    message = Message(delivery_id=delivery.id, sender_id=account.id, body=text)
    db.add(message)
    db.commit()
    return message.to_json()


@router.post("/deliveries/{delivery_id}/messages/read")
async def mark_read(
    delivery_id: str,
    db: Session = Depends(get_db),
    account: Account = Depends(current_account),
) -> dict:
    """Marque comme lus les messages recus, et rend le nombre ainsi mis a jour.

    Le lecteur, c'est l'autre partie : on ne pose l'accuse que sur les messages
    qu'il n'a pas ecrits. L'appel est idempotent — un `read_at` deja pose n'est
    pas retouche — ce qui laisse l'application le rappeler a chaque ouverture
    sans crainte. C'est ce que l'expediteur voit passer de « envoye » a « lu ».
    """
    delivery = _delivery_for_chat(db, delivery_id, account)

    result = db.execute(
        update(Message)
        .where(
            Message.delivery_id == delivery.id,
            Message.sender_id != account.id,
            Message.read_at.is_(None),
        )
        .values(read_at=datetime.now(timezone.utc))
    )
    db.commit()
    return {"marked": result.rowcount or 0}
