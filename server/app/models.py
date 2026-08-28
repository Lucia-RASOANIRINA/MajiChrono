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
    LargeBinary,
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

    # Prenom et nom, separes. `display_name` reste le nom d'usage, recompose a
    # partir des deux : les ecrans (en-tete, salutation, cartes) n'ont ainsi
    # qu'un seul champ a lire, et l'ancien contrat continue de fonctionner pour
    # les comptes anterieurs qui n'ont pas encore rempli le detail.
    first_name: Mapped[str | None] = mapped_column(String(80))
    last_name: Mapped[str | None] = mapped_column(String(80))
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
            "firstName": self.first_name,
            "lastName": self.last_name,
            "displayName": self.display_name,
            "avatarUrl": self.avatar_url,
            "rating": self.rating,
            "kycStatus": self.kyc_status.value if self.kyc_status else None,
            "createdAt": self.created_at.isoformat(),
        }


class Avatar(Base):
    """Photo de profil, rangee en base plutot que sur le disque.

    Le disque d'un plan gratuit (Render) est ephemere : une photo posee la
    disparaitrait au premier redeploiement. En base, elle survit et suit le
    compte. On la garde dans une **table a part** : une colonne binaire sur
    `accounts` grossirait chaque lecture de compte pour rien, alors que l'avatar
    n'est lu que par la balise `<img>`. Une ligne par compte au plus.
    """

    __tablename__ = "avatars"

    account_id: Mapped[str] = mapped_column(
        String(40), ForeignKey("accounts.id", ondelete="CASCADE"), primary_key=True
    )
    data: Mapped[bytes] = mapped_column(LargeBinary)
    content_type: Mapped[str] = mapped_column(String(80))
    # Sert de version dans l'URL (`?v=...`) pour casser le cache quand la photo
    # change, sans changer le chemin.
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


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

    # Toutes les rotations issues d'une meme connexion partagent cette famille :
    # c'est elle qui identifie une **session** (un appareil connecte) dans la
    # liste que l'utilisateur peut consulter et revoquer.
    family: Mapped[str] = mapped_column(String(40), index=True)

    # Libelle lisible de l'appareil a l'origine de la session (« Android 14 »,
    # etc.), pose a la connexion et conserve a travers les rotations.
    device_label: Mapped[str | None] = mapped_column(String(120))

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

    # La **valeur** de chaque etat est le mot que porte le fil (wire), et c'est
    # celui qu'attend l'application : `en_attente`, `acceptee`, ... — pas un
    # equivalent anglais. Emettre autre chose forcerait le mobile a retomber sur
    # un etat par defaut, et toutes les courses s'afficheraient « en attente ».
    # Le nom du membre reste en anglais pour le code ; seul le wire est en
    # francais, cote reseau.
    pending = "en_attente"
    assigned = "acceptee"          # course acceptee par un livreur
    at_pickup = "au_depart"        # livreur arrive chez l'expediteur
    picked_up = "prise_en_charge"  # colis en main
    in_transit = "en_transit"
    at_destination = "a_destination"  # livreur arrive chez le destinataire
    delivered = "livree"
    delivered_with_reserves = "livree_avec_reserves"
    cancelled = "annulee"
    failed = "refusee"             # remise refusee / echec de livraison


# Transitions permises, par etat de depart (§8.3). Toute transition absente d'ici
# est refusee par un 409 qui rappelle l'etat courant (EXI-B02) : l'application
# peut alors reafficher la verite plutot que de laisser reessayer dans le vide.
#
# Le graphe suit celui du mobile : l'arrivee chez l'expediteur puis chez le
# destinataire sont des etapes a part entiere, parce que ce sont elles qui
# horodatent un constat de prise en charge et un constat de remise.
# Les etats « arrive chez l'expediteur » (at_pickup) et « arrive chez le
# destinataire » (at_destination) sont **facultatifs** : ils horodatent une
# arrivee quand l'application les traverse, mais un client plus sobre peut passer
# directement a l'enlevement ou a la remise. Le graphe autorise donc les deux
# chemins, sans jamais laisser sauter par-dessus une prise en charge.
ALLOWED_TRANSITIONS: dict[DeliveryStatus, set[DeliveryStatus]] = {
    DeliveryStatus.pending: {DeliveryStatus.assigned, DeliveryStatus.cancelled},
    DeliveryStatus.assigned: {
        DeliveryStatus.at_pickup,
        DeliveryStatus.picked_up,
        DeliveryStatus.cancelled,
        DeliveryStatus.failed,
    },
    DeliveryStatus.at_pickup: {
        DeliveryStatus.picked_up,
        DeliveryStatus.cancelled,
        DeliveryStatus.failed,
    },
    DeliveryStatus.picked_up: {
        DeliveryStatus.in_transit,
        DeliveryStatus.at_destination,
        DeliveryStatus.delivered,
        DeliveryStatus.delivered_with_reserves,
        DeliveryStatus.failed,
    },
    DeliveryStatus.in_transit: {
        DeliveryStatus.at_destination,
        DeliveryStatus.delivered,
        DeliveryStatus.delivered_with_reserves,
        DeliveryStatus.failed,
    },
    DeliveryStatus.at_destination: {
        DeliveryStatus.delivered,
        DeliveryStatus.delivered_with_reserves,
        DeliveryStatus.failed,
    },
    DeliveryStatus.delivered: set(),
    DeliveryStatus.delivered_with_reserves: set(),
    DeliveryStatus.cancelled: set(),
    DeliveryStatus.failed: set(),
}

# Etats ou l'expediteur peut encore annuler seul. Au-dela, le colis est chez le
# livreur : l'annulation devient un litige, pas un bouton.
CLIENT_CANCELLABLE = {DeliveryStatus.pending, DeliveryStatus.assigned}

# Etats consideres comme une remise reussie (pour les gains, la notation).
DELIVERED_STATES = {
    DeliveryStatus.delivered,
    DeliveryStatus.delivered_with_reserves,
}


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


class Message(Base):
    """Message de la discussion entre l'expediteur et le livreur d'une course.

    La discussion n'existe qu'a partir de l'acceptation : avant, il n'y a pas de
    livreur a qui parler. Elle est rattachee a la course, pas a une paire de
    comptes — c'est la course qui donne le contexte (« ou en est mon colis ? »),
    et elle se ferme avec elle. Seuls l'expediteur et le livreur assigne y ont
    acces ; le controle est porte par la route, pas par cette table.
    """

    __tablename__ = "messages"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("msg"))
    delivery_id: Mapped[str] = mapped_column(
        ForeignKey("deliveries.id", ondelete="CASCADE"), index=True
    )
    sender_id: Mapped[str] = mapped_column(ForeignKey("accounts.id"), index=True)
    body: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    # Horodatage de lecture par l'autre partie. Nul tant que le destinataire n'a
    # pas ouvert la discussion : c'est ce que l'accuse de lecture affiche —
    # « envoye » (nul) puis « lu » (pose). On garde un seul instant plutot qu'un
    # drapeau : il porte le « lu a telle heure », et suffit a deux interlocuteurs.
    read_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), default=None
    )

    __table_args__ = (
        Index("ix_messages_delivery_created", "delivery_id", "created_at"),
    )

    def to_json(self) -> dict:
        return {
            "id": self.id,
            "deliveryId": self.delivery_id,
            "senderId": self.sender_id,
            "body": self.body,
            "createdAt": as_utc(self.created_at).isoformat(),
            "readAt": as_utc(self.read_at).isoformat() if self.read_at else None,
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


class PaymentDirection(str, enum.Enum):
    """Sens de l'appariement d'un paiement par code QR.

    L'argent va toujours de l'expediteur (client) au livreur ; ce qui change,
    c'est qui presente le code et qui le scanne.
    """

    # Le livreur presente le code, le client le scanne puis confirme : demande
    # d'encaissement, rien n'est debite avant confirmation du payeur.
    collect = "collect"
    # Le client presente le code, deja pre-autorise ; le livreur le scanne pour
    # encaisser, et le mouvement suit immediatement.
    offer = "offer"


class PaymentStatus(str, enum.Enum):
    pending = "pending"     # creee, en attente d'appariement
    claimed = "claimed"     # code scanne, les deux appareils se connaissent
    captured = "captured"   # confirmee par le payeur, mouvement MajiPay effectue
    failed = "failed"       # refusee, expiree, ou solde insuffisant
    cash = "cash"           # bascule en especes


class PaymentIntent(Base):
    """Intention de paiement adossee a un solde MajiPay (§11.2).

    Le partage des roles gouverne toute la table : **MajiPay tient les soldes et
    execute le mouvement**, MajiChrono ne fait qu'arbitrer. On ne stocke donc ni
    solde ni numero de compte ici — ils vivent chez le prestataire et sont lus a
    chaque fois. Ce qui vit ici, c'est l'etat de la transaction et son garde-fou
    d'unicite : une intention capturee ne se debite jamais deux fois (EXI-MP06).

    Le jeton du code QR n'est **jamais** conserve en clair : seule son empreinte
    l'est, comme pour un mot de passe ou un code SMS. Un code photographie a
    distance ne revele rien, et une fuite de la base ne rend aucun code
    encaissable.
    """

    __tablename__ = "payment_intents"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("pay"))
    delivery_id: Mapped[str] = mapped_column(ForeignKey("deliveries.id", ondelete="CASCADE"), index=True)

    # Payeur et beneficiaire sont **derives de la course**, jamais du mobile : le
    # payeur est l'expediteur, le beneficiaire le livreur assigne. C'est ce qui
    # empeche un beneficiaire de se payer lui-meme en falsifiant un champ.
    payer_id: Mapped[str] = mapped_column(String(40), index=True)
    payee_id: Mapped[str] = mapped_column(String(40), index=True)

    amount_ariary: Mapped[int] = mapped_column(Integer)
    direction: Mapped[PaymentDirection] = mapped_column(Enum(PaymentDirection, name="payment_direction"))
    status: Mapped[PaymentStatus] = mapped_column(
        Enum(PaymentStatus, name="payment_status"), default=PaymentStatus.pending, index=True
    )

    # Empreinte du jeton a usage unique. Le jeton en clair ne sort qu'une fois, a
    # la creation, et uniquement a celui qui presente le code.
    token_hash: Mapped[str] = mapped_column(String(255))

    failure: Mapped[str] = mapped_column(String(30), default="none")
    receipt_ref: Mapped[str | None] = mapped_column(String(60))

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    captured_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    @property
    def is_expired(self) -> bool:
        return _now() > as_utc(self.expires_at)

    @property
    def is_final(self) -> bool:
        return self.status in (PaymentStatus.captured, PaymentStatus.failed, PaymentStatus.cash)

    def to_json(self) -> dict:
        return {
            "id": self.id,
            "deliveryId": self.delivery_id,
            "amount": self.amount_ariary,
            "direction": self.direction.value,
            "status": self.status.value,
            "payerLabel": "Client",
            "payeeLabel": "Livreur",
            "failure": self.failure,
            "receiptRef": self.receipt_ref,
            "createdAt": as_utc(self.created_at).isoformat(),
            "expiresAt": as_utc(self.expires_at).isoformat(),
            "capturedAt": as_utc(self.captured_at).isoformat() if self.captured_at else None,
        }


class Review(Base):
    """Evaluation d'une course, de l'expediteur vers le livreur (EXI-C40).

    Une note sans course n'a pas de sens : on ne juge pas un livreur dans
    l'abstrait, mais la course qu'il vient de faire. L'unicite `(course,
    auteur)` l'impose et interdit du meme coup de noter deux fois la meme
    course — la note se corrige, elle ne s'empile pas.

    Trois axes plutot qu'un seul : la note globale dit la satisfaction, la
    ponctualite et la qualite disent **pourquoi**. Un livreur mal note sur la
    seule ponctualite ne se corrige pas comme un livreur mal note sur le soin —
    et il ne peut se corriger que s'il sait lequel des deux on lui reproche.
    """

    __tablename__ = "reviews"

    id: Mapped[str] = mapped_column(String(40), primary_key=True, default=lambda: _uid("rev"))
    delivery_id: Mapped[str] = mapped_column(ForeignKey("deliveries.id", ondelete="CASCADE"), index=True)
    rater_id: Mapped[str] = mapped_column(String(40), index=True)
    ratee_id: Mapped[str] = mapped_column(String(40), index=True)

    # Note globale, de 1 a 5. Les deux axes fins sont facultatifs : une note
    # rapide reste possible, mais quand ils sont donnes, ils eclairent.
    stars: Mapped[int] = mapped_column(Integer)
    punctuality: Mapped[int | None] = mapped_column(Integer)
    service: Mapped[int | None] = mapped_column(Integer)
    comment: Mapped[str | None] = mapped_column(Text)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    __table_args__ = (
        UniqueConstraint("delivery_id", "rater_id", name="uq_review_delivery_rater"),
    )

    def to_json(self) -> dict:
        return {
            "id": self.id,
            "deliveryId": self.delivery_id,
            "raterId": self.rater_id,
            "rateeId": self.ratee_id,
            "stars": self.stars,
            "punctuality": self.punctuality,
            "service": self.service,
            "comment": self.comment,
            "createdAt": as_utc(self.created_at).isoformat(),
        }


class MajiPaySandboxAccount(Base):
    """Solde fictif d'un compte chez le **prestataire de paiement** MajiPay.

    Cette table n'existe que tant que le vrai MajiPay n'est pas branche : elle
    tient lieu de bac a sable pour developper et tester le parcours de bout en
    bout. En production, ces lignes n'existent pas — les soldes vivent chez
    MajiPay, et la passerelle HTTP les lit par-dessus le reseau. Rien dans le
    routeur de paiement ne lit cette table directement : tout passe par la
    passerelle, exactement comme avec le vrai prestataire.
    """

    __tablename__ = "majipay_sandbox_accounts"

    account_id: Mapped[str] = mapped_column(String(40), primary_key=True)
    balance_ariary: Mapped[int] = mapped_column(Integer, default=0)
    account_ref: Mapped[str] = mapped_column(String(40))


class MajiPaySandboxTxn(Base):
    """Mouvement MajiPay deja honore, retrouve par sa cle d'idempotence.

    Un prestataire de paiement serieux rend la meme reponse a la meme cle sans
    rejouer le debit. Le bac a sable en fait autant : c'est la derniere barriere
    contre un double mouvement, celle qui tient meme si l'appelant s'y reprend.
    """

    __tablename__ = "majipay_sandbox_txns"

    idem_key: Mapped[str] = mapped_column(String(120), primary_key=True)
    receipt_ref: Mapped[str] = mapped_column(String(60))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


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
