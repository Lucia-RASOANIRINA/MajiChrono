"""Configuration du serveur, lue dans l'environnement.

Aucune valeur secrete n'a de defaut utilisable. Un serveur qui demarre avec une
cle de signature « changez-moi » est un serveur dont personne ne remarque que la
cle n'a pas ete changee — le demarrage echoue donc franchement en production
plutot que de laisser passer.
"""

from functools import lru_cache
from typing import Literal

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", extra="ignore"
    )

    environment: Literal["dev", "staging", "prod"] = "dev"

    # --- Base de donnees ---------------------------------------------------
    # SQLite par defaut : on clone le depot et on lance le serveur sans rien
    # installer d'autre. PostgreSQL reste la base de production — c'est elle qui
    # tient la concurrence et les transactions longues — et il suffit de poser
    # DATABASE_URL pour y passer. SQLAlchemy sert les deux sans que le code des
    # routes ne change d'une ligne.
    database_url: str = "sqlite:///./majichrono.db"

    # --- Jetons ------------------------------------------------------------
    #
    # Quinze minutes d'acces et trente jours de rafraichissement, comme le
    # mobile les attend (EXI-T03). Le jeton court limite la fenetre d'un vol ;
    # le long evite de redemander une identite tous les matins a un livreur.
    jwt_secret: str = Field(default="", min_length=0)
    access_ttl_minutes: int = 15
    refresh_ttl_days: int = 30

    # --- Codes a usage unique ---------------------------------------------
    otp_ttl_minutes: int = 5
    otp_max_attempts: int = 3

    # --- Envoi d'e-mail (SMTP) ---------------------------------------------
    #
    # SMTP est le denominateur commun : Gmail, Resend, Mailgun, SendGrid, un
    # serveur d'entreprise — tous l'exposent. Changer de fournisseur ne coute
    # alors que quatre variables, jamais une reecriture.
    smtp_host: str = ""
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: str = ""
    mail_from_address: str = "no-reply@majichrono.mg"
    mail_from_name: str = "MajiChrono"

    # --- SMS ---------------------------------------------------------------
    #
    # Volontairement vide : l'envoi de SMS est le **dernier** chantier, pour ne
    # pas consommer le quota d'essai en developpement. Tant que cette cle est
    # absente, les codes telephoniques sont journalises au lieu d'etre envoyes.
    sms_api_key: str = ""

    # Nom d'expediteur affiche sur le telephone. Onze caracteres au plus, et
    # il doit etre declare aupres de la passerelle avant usage.
    sms_sender: str = "MajiChrono"

    # --- Paiement (MajiPay) ------------------------------------------------
    #
    # Le prestataire qui tient les soldes et execute les mouvements. Tant que
    # cette cle est vide, un bac a sable en base joue son role : le parcours de
    # paiement par QR se teste de bout en bout sans compte MajiPay, et le mobile
    # ne peut toujours pas debiter seul. Poser la cle bascule vers le vrai
    # prestataire sans changer une ligne du routeur.
    majipay_api_key: str = ""

    @field_validator("jwt_secret")
    @classmethod
    def _secret_must_be_real(cls, value: str, info) -> str:
        environment = info.data.get("environment", "dev")
        if environment != "dev" and len(value) < 32:
            raise ValueError(
                "JWT_SECRET doit faire au moins 32 caracteres hors developpement"
            )
        return value or "developpement-uniquement-jamais-en-production"

    @property
    def emails_are_real(self) -> bool:
        """Vrai quand le serveur peut vraiment poster un e-mail.

        Sans cle, le code est ecrit dans le journal : c'est ce qui permet de
        developper sans compte fournisseur, et ce qui rend visible, en
        production, qu'une cle manque.
        """
        return bool(self.smtp_host and self.smtp_user and self.smtp_password)


@lru_cache
def get_settings() -> Settings:
    return Settings()
