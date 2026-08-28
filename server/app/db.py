"""Session de base de donnees, injectee par requete."""

from __future__ import annotations

from collections.abc import Iterator

import logging

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import Session, sessionmaker

from app.config import get_settings
from app.models import Base

logger = logging.getLogger("majichrono.db")

_settings = get_settings()

# `pool_pre_ping` : la connexion est testee avant usage. Sans lui, un serveur
# reveille apres une nuit d'inactivite sert une premiere requete en erreur,
# parce que PostgreSQL a ferme la connexion de son cote entre-temps.
_is_sqlite = _settings.database_url.startswith("sqlite")

# `check_same_thread` : SQLite refuse par defaut qu'une connexion serve deux fils,
# or FastAPI en utilise plusieurs. La contrainte n'a pas lieu d'etre ici, chaque
# requete ouvrant sa propre session.
engine = create_engine(
    _settings.database_url,
    pool_pre_ping=True,
    future=True,
    connect_args={"check_same_thread": False} if _is_sqlite else {},
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


def get_db() -> Iterator[Session]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def create_all() -> None:
    """Cree le schema depuis zero. Utile pour les tests et le premier amorcage."""
    Base.metadata.create_all(engine)


def ensure_schema() -> None:
    """Aligne la base sur les modeles, de facon **idempotente** et sans perte.

    Tient lieu de migration legere, la ou Alembic n'a pas ete monte : appele au
    demarrage, il rattrape ce que `create_all` seul ne sait pas faire.

      - Les **tables manquantes** sont creees (c'est deja le role de
        `create_all`) : une nouvelle table comme `avatars` apparait ainsi toute
        seule au premier deploiement sur Neon.
      - Les **colonnes manquantes** d'une table existante sont ajoutees par un
        `ALTER TABLE ... ADD COLUMN`. On ne traite que le cas sur et reversible :
        une colonne **nullable**, sans contrainte — ce que sont toutes nos
        evolutions de compte (prenom, nom, libelle d'appareil...). Une colonne
        non-nullable exigerait une valeur de remplissage et donc une vraie
        migration ecrite a la main ; on la laisse alors passer sans y toucher,
        en le journalisant, plutot que de casser le demarrage.

    Fonctionne sur PostgreSQL (Neon) comme sur SQLite (local, tests) : on
    n'emet que du DDL commun aux deux, en compilant le type via le dialecte.
    """
    Base.metadata.create_all(engine)

    inspector = inspect(engine)
    tables = set(inspector.get_table_names())

    for table in Base.metadata.sorted_tables:
        if table.name not in tables:
            continue  # tout juste creee, colonnes deja completes
        present = {col["name"] for col in inspector.get_columns(table.name)}
        for column in table.columns:
            if column.name in present:
                continue
            if not column.nullable:
                logger.warning(
                    "Colonne manquante NON nullable %s.%s — migration manuelle "
                    "requise, ignoree au demarrage",
                    table.name,
                    column.name,
                )
                continue
            col_type = column.type.compile(dialect=engine.dialect)
            ddl = f'ALTER TABLE "{table.name}" ADD COLUMN "{column.name}" {col_type}'
            logger.info("Ajout de la colonne manquante : %s", ddl)
            with engine.begin() as conn:
                conn.execute(text(ddl))
