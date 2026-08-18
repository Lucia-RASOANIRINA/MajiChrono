import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
import 'package:majichrono/features/auth/domain/entities/google_entities.dart';
import 'package:majichrono/features/auth/domain/value_objects/malagasy_phone.dart';

/// Contrat d'authentification vu par le domaine.
///
/// Aucune mention de HTTP, de jeton stocke ou de Keystore : le domaine sait
/// qu'il existe une session, pas ou elle est rangee (§8.1).
abstract interface class AuthRepository {
  /// Demande l'envoi d'un code OTP (EXI-T01).
  Future<OtpChallenge> requestOtp(MalagasyPhone phone);

  /// Verifie un code. Leve une [ValidationFailure] si le code est faux, en
  /// indiquant le nombre de tentatives restantes.
  Future<OtpVerification> verifyOtp({
    required String challengeId,
    required String code,
  });

  /// Envoie un code a six chiffres dans une boite mail.
  ///
  /// La reponse ne dit **pas** si l'adresse est connue : le savoir avant d'avoir
  /// prouve la possession de la boite permettrait d'enumerer les comptes.
  Future<EmailChallenge> requestEmailCode(String email);

  /// Verifie un code recu par e-mail. Ouvre la session si l'adresse est
  /// rattachee a un compte, sinon renvoie [EmailUnlinked].
  Future<EmailVerification> verifyEmailCode({
    required String challengeId,
    required String code,
  });

  /// Rattache une adresse deja verifiee au compte de la session en cours, pour
  /// que la prochaine entree se fasse par Google sans repasser par le SMS.
  Future<void> linkEmail(String email);

  /// Connexion par couple e-mail / mot de passe.
  ///
  /// Meme issue que le code par e-mail : session ouverte si l'adresse porte un
  /// compte, renvoi vers le numero sinon.
  Future<EmailVerification> signInWithPassword({
    required String email,
    required String password,
  });

  /// Inscription par couple e-mail / mot de passe.
  ///
  /// Ne rend **jamais** [EmailLinked] : un compte neuf n'a pas encore de
  /// numero, et sans numero il n'y a pas de compte. Le mot de passe est
  /// enregistre, puis le parcours enchaine sur la confirmation du numero.
  Future<EmailVerification> signUpWithPassword({
    required String email,
    required String password,
  });

  /// Pose le profil d'un compte tout juste cree (EXI-T02).
  ///
  /// Le role administrateur est refuse par le serveur : il n'est attribue que
  /// cote serveur, jamais revendique par le mobile.
  Future<UserAccount> chooseProfile({
    required UserRole role,
    required String displayName,
  });

  /// Session persistee, ou `null` si l'utilisateur n'est pas connecte.
  Future<AuthSession?> currentSession();

  /// Compte en cache, disponible hors ligne — le profil ne change pas souvent,
  /// et l'application doit s'ouvrir sans reseau (EXI-P07).
  Future<UserAccount?> cachedAccount();

  /// Recharge le compte depuis le serveur.
  Future<AccountResult> fetchAccount();

  /// Echange le jeton de rafraichissement contre un nouveau couple (EXI-T03).
  Future<AuthSession> refresh();

  /// Deconnexion : revoque cote serveur si possible, puis efface tout (EXI-SEC10).
  Future<void> signOut();

  // --- Verrouillage local (EXI-T04) ------------------------------------

  Future<bool> hasPin();

  /// Enregistre l'empreinte salee du code PIN. Le code lui-meme n'est jamais
  /// ecrit nulle part.
  Future<void> setPin(String pin);

  Future<bool> verifyPin(String pin);

  Future<void> clearPin();
}
