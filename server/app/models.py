"""Schema de la base.

Le numero de telephone est la **cle d'identite** : une adresse e-mail, un mot de
passe, un compte Google ne sont que des portes vers un compte qui, lui, possede
toujours un numero. Cette regle vient du terrain — a Antananarivo, un livreur
appelle son client et un client appelle son livreur ; un compte sans numero
serait un compte avec lequel on ne peut pas livrer. Le schema l'impose : la
colonne `phone` est obligatoire et unique.
"""

from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import (
    Boolean,
    DateTime,
    Enum,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


def _now() -> datetime:
    return datetime.now(timezone.utc)


def as_utc(value: datetime) -> datetime:
    """Ramene une date lue en base au fuseau UTC.

    PostgreSQL rend des dates **avec** fuseau, SQLite les rend sans — il ne
    stocke pas cette information. Comparer les deux leve
    `can't compare offset-naive and offset-aware datetimes`, et le fait au
    moment le plus penible : a la verification d'un code, en production comme en
    developpement selon la base. On normalise donc a la lecture, une fois, ici.
    """
    return value if value.tzinfo else value.replace(tzinfo=timezone.utc)


def _uid(prefix: str) -> str:
    return f"{prefix}_{uuid.uuid4().hex[:16]}"


class Base(DeclarativeBase):
    pass


class UserRole(str, enum.Enum):
    client = "client"
    driver = "driver"
    admin = "admin"


class KycStatus(str, enum.Enum):
    draft = "draft"
    submitted = "submitted"
    under_review = "under_review"
    approved = "approved"
    rejected = "rejected"


class Account(Base):
    __tablename__ = "accounts"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("usr"))

    # Cle d'identite. Format canonique `+261XXXXXXXXX`, valide en amont.
    phone: Mapped[str] = mapped_column(String(20), unique=True, index=True)

    # Seconde porte, facultative et unique. Deux comptes ne peuvent pas partager
    # une adresse : le prochain code recu ne dirait plus laquelle ouvrir.
    email: Mapped[str | None] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str | None] = mapped_column(String(255))

    role: Mapped[UserRole | None] = mapped_column(Enum(UserRole, name="user_role"))
    display_name: Mapped[str] = mapped_column(String(120), default="")
    avatar_url: Mapped[str | None] = mapped_column(String(500))
    rating: Mapped[float | None] = mapped_column()
    kyc_status: Mapped[KycStatus | None] = mapped_column(Enum(KycStatus, name="kyc_status"))

    suspended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    def to_json(self) -> dict:
        return {
            "id": self.id,
            "phone": self.phone,
            "email": self.email,
            "role": self.role.value if self.role else None,
            "displayName": self.display_name,
            "avatarUrl": self.avatar_url,
            "rating": self.rating,
            "kycStatus": self.kyc_status.value if self.kyc_status else None,
            "createdAt": self.created_at.isoformat(),
        }


class ChallengeChannel(str, enum.Enum):
    sms = "sms"
    email = "email"


class Challenge(Base):
    """Code a usage unique, par SMS ou par e-mail.

    Le code n'est **jamais** stocke en clair : seule son empreinte l'est. Une
    fuite de la base ne donne donc pas les codes en vol. C'est la meme exigence
    que pour les mots de passe, et elle vaut ici aussi : cinq minutes suffisent
    a ouvrir une session.
    """

    __tablename__ = "challenges"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("chg"))
    channel: Mapped[ChallengeChannel] = mapped_column(Enum(ChallengeChannel, name="challenge_channel"))

    # Numero ou adresse, selon le canal.
    destination: Mapped[str] = mapped_column(String(255), index=True)
    code_hash: Mapped[str] = mapped_column(String(255))

    attempts_left: Mapped[int] = mapped_column(Integer)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    consumed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    __table_args__ = (Index("ix_challenges_destination_created", "destination", "created_at"),)

    @property
    def is_expired(self) -> bool:
        return _now() > as_utc(self.expires_at)

    @property
    def is_usable(self) -> bool:
        return self.consumed_at is None and not self.is_expired


class RefreshToken(Base):
    """Jeton de rafraichissement, tracable et revocable.

    Il est stocke par empreinte, et **tourne a chaque usage** (EXI-T03). Un
    jeton presente apres rotation signale un vol : la famille entiere est alors
    revoquee, ce qui deconnecte l'attaquant comme le porteur legitime — c'est le
    comportement voulu.
    """

    __tablename__ = "refresh_tokens"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("rt"))
    account_id: Mapped[str] = mapped_column(ForeignKey("accounts.id", ondelete="CASCADE"), index=True)
    token_hash: Mapped[str] = mapped_column(String(255), unique=True)

    # Toutes les rotations issues d'une meme connexion partagent cette famille.
    family: Mapped[str] = mapped_column(String(40), index=True)

    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    account: Mapped[Account] = relationship()


class IdempotencyRecord(Base):
    """Cle d'idempotence deja traitee, avec la reponse qui avait ete rendue.

    Sans ce registre, une reprise apres coupure creerait une seconde course, un
    second debit, un second constat. Le mobile envoie la cle a l'enregistrement
    et ne la regenere jamais ; le serveur rejoue la meme reponse.
    """

    __tablename__ = "idempotency_records"

    key: Mapped[str] = mapped_column(String(120), primary_key=True)
    account_id: Mapped[str | None] = mapped_column(String(40), index=True)
    endpoint: Mapped[str] = mapped_column(String(120))
    status_code: Mapped[int] = mapped_column(Integer)
    response_json: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    __table_args__ = (UniqueConstraint("key", name="uq_idempotency_key"),)


class DeliveryStatus(str, enum.Enum):
    """Cycle de vie d'une course.

    L'ordre de declaration est celui du parcours reel. Les transitions
    autorisees sont declarees explicitement plus bas : une course ne peut pas
    sauter une etape, et surtout pas revenir en arriere — un colis remis ne
    redevient pas un colis en attente.
    """

    pending = "pending"
    assigned = "assigned"
    picked_up = "picked_up"
    in_transit = "in_transit"
    delivered = "delivered"
    cancelled = "cancelled"
    failed = "failed"


# Transitions permises, par etat de depart. Toute transition absente d'ici est
# refusee par un 409 qui rappelle l'etat courant (EXI-B02) : l'application peut
# alors reafficher la verite plutot que de laisser reessayer dans le vide.
ALLOWED_TRANSITIONS: dict[DeliveryStatus, set[DeliveryStatus]] = {
    DeliveryStatus.pending: {DeliveryStatus.assigned, DeliveryStatus.cancelled},
    DeliveryStatus.assigned: {
        DeliveryStatus.picked_up,
        DeliveryStatus.cancelled,
        DeliveryStatus.failed,
    },
    DeliveryStatus.picked_up: {DeliveryStatus.in_transit, DeliveryStatus.failed},
    DeliveryStatus.in_transit: {DeliveryStatus.delivered, DeliveryStatus.failed},
    DeliveryStatus.delivered: set(),
    DeliveryStatus.cancelled: set(),
    DeliveryStatus.failed: set(),
}

# Etats ou l'expediteur peut encore annuler seul. Au-dela, le colis est chez le
# livreur : l'annulation devient un litige, pas un bouton.
CLIENT_CANCELLABLE = {DeliveryStatus.pending, DeliveryStatus.assigned}


class Delivery(Base):
    __tablename__ = "deliveries"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("dlv"))
    client_id: Mapped[str] = mapped_column(ForeignKey("accounts.id"), index=True)
    driver_id: Mapped[str | None] = mapped_column(ForeignKey("accounts.id"), index=True)

    status: Mapped[DeliveryStatus] = mapped_column(
        Enum(DeliveryStatus, name="delivery_status"), default=DeliveryStatus.pending, index=True
    )
    kind: Mapped[str] = mapped_column(String(30), default="standard")

    pickup_json: Mapped[str] = mapped_column(Text)
    dropoff_json: Mapped[str] = mapped_column(Text)
    package_json: Mapped[str] = mapped_column(Text, default="{}")

    price_ariary: Mapped[int | None] = mapped_column(Integer)
    distance_km: Mapped[float | None] = mapped_column()

    # Jeton du lien de suivi public, partage par SMS (EXI-C24). Il est distinct
    # de l'identifiant : un lien devine ne doit pas ouvrir une autre course.
    tracking_token: Mapped[str] = mapped_column(String(64), unique=True, index=True)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    def to_json(self) -> dict:
        import json as _json

        return {
            "id": self.id,
            "clientId": self.client_id,
            "driverId": self.driver_id,
            "status": self.status.value,
            "kind": self.kind,
            "pickup": _json.loads(self.pickup_json),
            "dropoff": _json.loads(self.dropoff_json),
            "package": _json.loads(self.package_json),
            "price": self.price_ariary,
            "distanceKm": self.distance_km,
            "trackingToken": self.tracking_token,
            "createdAt": as_utc(self.created_at).isoformat(),
            "updatedAt": as_utc(self.updated_at).isoformat(),
        }


class DeliveryEvent(Base):
    """Journal des transitions d'une course.

    Il est **ajout seul** : aucune route ne le modifie ni ne l'efface. C'est ce
    qui permet, en cas de litige, de dire qui a fait passer la course dans quel
    etat et quand — une colonne `status` seule ne raconte rien du chemin.
    """

    __tablename__ = "delivery_events"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("evt"))
    delivery_id: Mapped[str] = mapped_column(ForeignKey("deliveries.id", ondelete="CASCADE"), index=True)
    status: Mapped[DeliveryStatus] = mapped_column(Enum(DeliveryStatus, name="delivery_status"))
    actor_id: Mapped[str | None] = mapped_column(String(40))
    note: Mapped[str | None] = mapped_column(Text)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    def to_json(self) -> dict:
        return {
            "status": self.status.value,
            "actorId": self.actor_id,
            "note": self.note,
            "occurredAt": as_utc(self.occurred_at).isoformat(),
        }


class DriverState(Base):
    """Etat de travail d'un livreur : en ligne, et derniere position connue.

    La position vit ici plutot que dans une table d'historique interrogee a
    chaque affichage : l'exploitation veut savoir **ou est chacun maintenant**,
    et lire une seule ligne par livreur reste rapide avec mille livreurs. Les
    positions passees, elles, ne servent qu'a reconstituer un trajet apres coup,
    et vont dans `PositionSample`.
    """

    __tablename__ = "driver_states"

    account_id: Mapped[str] = mapped_column(
        ForeignKey("accounts.id", ondelete="CASCADE"), primary_key=True
    )
    online: Mapped[bool] = mapped_column(Boolean, default=False, index=True)

    lat: Mapped[float | None] = mapped_column()
    lng: Mapped[float | None] = mapped_column()

    # Horodatage **de la mesure**, pas de sa reception. Un point remonte apres
    # deux heures de tunnel reseau ne doit pas passer pour frais : c'est cette
    # date que l'exploitation compare a l'heure courante pour decider si un
    # livreur est encore localise (EXI-A02).
    fixed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    def to_json(self) -> dict:
        return {
            "driverId": self.account_id,
            "online": self.online,
            "lat": self.lat,
            "lng": self.lng,
            "fixedAt": as_utc(self.fixed_at).isoformat() if self.fixed_at else None,
        }


class PositionSample(Base):
    """Un point du trajet, tel que le mobile l'a mesure.

    Le livreur travaille souvent sans reseau : son application tamponne les
    points et les envoie par paquets a la reconnexion (EXI-L09). La cle
    d'unicite `(livreur, instant)` rend le renvoi d'un meme paquet inoffensif —
    ce qui arrive des qu'une reponse se perd en chemin.
    """

    __tablename__ = "position_samples"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("pos"))
    driver_id: Mapped[str] = mapped_column(ForeignKey("accounts.id", ondelete="CASCADE"), index=True)
    delivery_id: Mapped[str | None] = mapped_column(String(40), index=True)

    lat: Mapped[float] = mapped_column()
    lng: Mapped[float] = mapped_column()
    accuracy_m: Mapped[float | None] = mapped_column()
    fixed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    __table_args__ = (
        UniqueConstraint("driver_id", "fixed_at", name="uq_position_driver_instant"),
    )


class ModerationLog(Base):
    """Decision d'exploitation, avec son motif et son auteur.

    Table en **ajout seul** : aucune route ne modifie ni n'efface une ligne. Une
    suspension qu'on pourrait effacer ne vaudrait rien le jour ou un livreur
    conteste — et c'est precisement ce jour-la qu'on a besoin de ce journal.

    Le motif est obligatoire, et la longueur minimale est controlee en amont.
    Une decision qui touche le gagne-pain de quelqu'un se justifie.
    """

    __tablename__ = "moderation_logs"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("mod"))
    actor_id: Mapped[str] = mapped_column(String(40), index=True)
    subject_id: Mapped[str] = mapped_column(String(40), index=True)
    action: Mapped[str] = mapped_column(String(40))
    reason: Mapped[str] = mapped_column(Text)
    decided_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    def to_json(self) -> dict:
        return {
            "id": self.id,
            "actorId": self.actor_id,
            "subjectId": self.subject_id,
            "action": self.action,
            "reason": self.reason,
            "decidedAt": as_utc(self.decided_at).isoformat(),
        }
