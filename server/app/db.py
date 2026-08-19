"""Session de base de donnees, injectee par requete."""

from __future__ import annotations

from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.config import get_settings
from app.models import Base

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
    """Cree le schema. Utile en developpement et pour les tests.

    En production, c'est Alembic qui fait foi : `create_all` ne sait pas faire
    evoluer une base existante, et l'employer la reviendrait a perdre des
    donnees au premier changement de colonne.
    """
    Base.metadata.create_all(engine)
