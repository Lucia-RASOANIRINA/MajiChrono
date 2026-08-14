import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/domain/value_objects/malagasy_phone.dart';

/// Compte authentifie.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.phone,
    required this.role,
    required this.displayName,
    required this.createdAt,
    this.avatarUrl,
    this.rating,
    this.kycStatus,
  });

  final String id;
  final MalagasyPhone phone;
  final UserRole role;
  final String displayName;
  final DateTime createdAt;
  final String? avatarUrl;
  final double? rating;

  /// Etat du dossier livreur (EXI-L02). Nul pour un client ou un administrateur.
  final KycStatus? kycStatus;

  /// Un livreur ne peut executer aucune course tant que son dossier n'est pas
  /// valide (EXI-L01). La regle est portee par le domaine, pas par un ecran.
  bool get canWork => role != UserRole.driver || kycStatus == KycStatus.approved;

  UserAccount copyWith({String? displayName, String? avatarUrl, KycStatus? kycStatus}) =>
      UserAccount(
        id: id,
        phone: phone,
        role: role,
        displayName: displayName ?? this.displayName,
        createdAt: createdAt,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        rating: rating,
        kycStatus: kycStatus ?? this.kycStatus,
      );
}

/// Cycle de vie du dossier KYC (EXI-L02).
enum KycStatus {
  draft('draft'),
  submitted('submitted'),
  underReview('under_review'),
  approved('approved'),
  rejected('rejected');

  const KycStatus(this.wireName);

  final String wireName;

  static KycStatus? fromWire(String? value) {
    if (value == null) return null;
    for (final status in KycStatus.values) {
      if (status.wireName == value) return status;
    }
    return null;
  }
}

/// Session : couple de jetons et leurs echeances (EXI-T03).
///
/// Le jeton d'acces est volontairement court — quinze minutes — et le jeton de
/// rafraichissement tourne a chaque usage. Un jeton intercepte a donc une duree
/// d'exploitation tres breve, et sa reutilisation apres rotation est detectable
/// cote serveur.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;

  /// Marge de securite : on rafraichit avant l'expiration reelle, sinon une
  /// requete partie juste avant l'echeance arrive apres et echoue pour rien.
  static const Duration renewalMargin = Duration(seconds: 60);

  bool get isAccessExpired =>
      DateTime.now().isAfter(accessExpiresAt.subtract(renewalMargin));

  bool get isRefreshExpired => DateTime.now().isAfter(refreshExpiresAt);
}

/// Defi OTP en cours (EXI-T01).
class OtpChallenge {
  const OtpChallenge({
    required this.challengeId,
    required this.phone,
    required this.expiresAt,
    required this.attemptsLeft,
    this.debugCode,
  });

  final String challengeId;
  final MalagasyPhone phone;
  final DateTime expiresAt;

  /// Trois tentatives, puis le defi est brule (EXI-T01).
  final int attemptsLeft;

  /// Code en clair, **renseigne uniquement par le backend simule**. Il permet de
  /// developper et de recetter sans passerelle SMS. En mode `live` il est
  /// toujours nul, et l'interface ne l'affiche que si le mode developpeur est
  /// actif.
  final String? debugCode;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining {
    final left = expiresAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  OtpChallenge copyWith({int? attemptsLeft}) => OtpChallenge(
        challengeId: challengeId,
        phone: phone,
        expiresAt: expiresAt,
        attemptsLeft: attemptsLeft ?? this.attemptsLeft,
        debugCode: debugCode,
      );
}

/// Etat d'un compte tel que le serveur le renvoie.
///
/// Le §12.2 ne prevoit **aucun** point d'entree d'inscription : le cycle de
/// session s'arrete a `otp/request`, `otp/verify`, `refresh` et `logout`. Plutot
/// que d'ajouter une route hors contrat, l'inscription se fait en deux temps sur
/// les routes existantes : la verification OTP ouvre une session, et le profil
/// est pose ensuite par `PATCH /me` (EXI-T02). Un compte tout juste cree existe
/// donc reellement, mais sans profil — d'ou cette union plutot qu'un
/// `UserAccount` dont le role serait nullable et qu'il faudrait tester partout.
sealed class AccountResult {
  const AccountResult();
}

class AccountReady extends AccountResult {
  const AccountReady(this.account);

  final UserAccount account;
}

/// Session valide, profil pas encore choisi.
class AccountProfilePending extends AccountResult {
  const AccountProfilePending(this.phone);

  final MalagasyPhone phone;
}

/// Resultat d'une verification OTP : une session, et l'etat du compte associe.
class OtpVerification {
  const OtpVerification({required this.session, required this.account});

  final AuthSession session;
  final AccountResult account;
}
