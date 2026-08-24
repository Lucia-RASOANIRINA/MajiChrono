"""Point d'entree du serveur MajiChrono."""

from __future__ import annotations

import logging

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.requests import Request

from app.config import get_settings
from app.core.errors import ApiError, api_error_handler, error_body
from app.routers import admin, auth, chat, deliveries, driver, me, payment, reviews

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

settings = get_settings()

app = FastAPI(
    title="MajiChrono",
    version="0.1.0",
    # La documentation interactive n'est ouverte qu'en dehors de la production :
    # elle expose la forme exacte de chaque route, ce qui rend le travail d'un
    # attaquant plus court sans rien apporter aux utilisateurs.
    docs_url="/docs" if settings.environment != "prod" else None,
    redoc_url=None,
)

app.add_exception_handler(ApiError, api_error_handler)


@app.exception_handler(RequestValidationError)
async def validation_handler(_: Request, exc: RequestValidationError) -> JSONResponse:
    """Traduit les erreurs de Pydantic dans le format que le mobile sait lire.

    Sans cela, FastAPI rend un corps `{"detail": [...]}` que `ErrorMapper`
    ignore : l'utilisateur verrait « erreur inconnue » sur une simple faute de
    saisie.
    """
    fields = {}
    for error in exc.errors():
        location = [str(part) for part in error["loc"] if part != "body"]
        fields[".".join(location) or "body"] = error["type"]

    return JSONResponse(
        status_code=422,
        content=error_body("validation_failed", "Requete invalide", {"fields": fields}),
    )


@app.get("/health", tags=["socle"])
async def health() -> dict:
    """Sonde applicative.

    Elle repond sans toucher la base : c'est une sonde de **vivacite**, pas de
    disponibilite complete. Un equilibreur de charge qui redemarre le serveur
    parce que PostgreSQL est lent aggraverait la panne au lieu de la reduire.
    """
    return {"status": "ok", "environment": settings.environment}


app.include_router(auth.router)
app.include_router(me.router)
app.include_router(deliveries.router)
app.include_router(driver.router)
app.include_router(admin.router)
app.include_router(chat.router)
app.include_router(payment.router)
app.include_router(reviews.router)
