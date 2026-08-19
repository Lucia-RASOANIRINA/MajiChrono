"""Banc de test : une base neuve par test, aucun etat partage.

Chaque test recoit sa propre base SQLite en memoire. C'est ce qui permet de les
lancer dans n'importe quel ordre, et en parallele, sans qu'un compte cree par
l'un ne fasse echouer l'unicite chez l'autre.
"""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.db import get_db
from app.main import app
from app.models import Base


@pytest.fixture
def client() -> TestClient:
    # `StaticPool` : toutes les connexions partagent la meme base en memoire.
    # Sans lui, chaque connexion en ouvrirait une vide, et les donnees ecrites
    # par une requete seraient invisibles a la suivante.
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    TestingSession = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)

    def override_get_db():
        db = TestingSession()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


def sign_in(client: TestClient, phone: str, role: str | None = None) -> dict[str, str]:
    """Ouvre une session complete et rend l'en-tete d'autorisation.

    Le code est lu dans `debugCode`, que le serveur ne renvoie qu'en dehors de
    la production. Un test qui devrait lire la base pour connaitre le code
    testerait la base, pas le parcours.
    """
    opened = client.post("/auth/otp/request", json={"phone": phone}).json()
    verified = client.post(
        "/auth/otp/verify",
        json={"challengeId": opened["challengeId"], "code": opened["debugCode"]},
    ).json()

    headers = {"Authorization": f"Bearer {verified['session']['accessToken']}"}
    if role:
        client.patch("/me", json={"role": role, "displayName": role}, headers=headers)
    return headers
