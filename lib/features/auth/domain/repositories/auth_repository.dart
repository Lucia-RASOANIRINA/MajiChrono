import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
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
