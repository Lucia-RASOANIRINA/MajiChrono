import 'dart:async';

import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:majichrono/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
import 'package:majichrono/features/auth/domain/repositories/auth_repository.dart';
import 'package:majichrono/features/auth/domain/value_objects/malagasy_phone.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required void Function(String? token) onAccessTokenChanged,
  })  : _remote = remote,
        _local = local,
        _onAccessTokenChanged = onAccessTokenChanged;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  /// Pousse le jeton courant vers le client HTTP, qui le pose en en-tete.
  final void Function(String? token) _onAccessTokenChanged;

  /// Rafraichissement en vol, partage.
  ///
  /// Sans ce verrou, deux requetes qui expirent en meme temps declencheraient
  /// deux rotations concurrentes : la seconde presenterait un jeton que la
  /// premiere vient d'invalider, et l'utilisateur serait deconnecte sans raison.
  /// Le cas est frequent sur reseau lent (§4.1), ou plusieurs requetes restent
  /// en vol longtemps.
  Future<AuthSession>? _refreshInFlight;

  @override
  Future<OtpChallenge> requestOtp(MalagasyPhone phone) async {
    final json = await _remote.requestOtp(phone.e164);
    return OtpChallenge(
      challengeId: json['challengeId'] as String,
      phone: phone,
      expiresAt: DateTime.parse(json['expiresAt'] as String).toLocal(),
      attemptsLeft: (json['attemptsLeft'] as num?)?.toInt() ?? 3,
      debugCode: json['debugCode'] as String?,
    );
  }

  @override
  Future<OtpVerification> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    final json = await _remote.verifyOtp(challengeId: challengeId, code: code);

    final session = _sessionFrom(json['session'] as Map<String, dynamic>);
    await _persist(session);

    final accountJson = json['account'] as Map<String, dynamic>;
    await _local.saveAccount(accountJson);

    return OtpVerification(session: session, account: _accountFrom(accountJson));
  }

  @override
  Future<UserAccount> chooseProfile({
    required UserRole role,
    required String displayName,
  }) async {
    final json = await _remote.patchMe(
      role: role.wireName,
      displayName: displayName,
    );

    // Le serveur reemet la session quand une information d'identite portee par
    // le jeton change (ici le profil). Adopter immediatement le nouveau couple
    // evite de continuer a presenter un jeton devenu incoherent.
    final reissued = json['session'] as Map<String, dynamic>?;
    if (reissued != null) {
      await _persist(_sessionFrom(reissued));
    }

    await _local.saveAccount(json);

    final result = _accountFrom(json);
    if (result is! AccountReady) {
      // Le serveur a accepte la requete sans poser le role : incoherence de
      // contrat, on la signale plutot que de laisser l'interface tourner en rond.
      throw const ServerFailure(statusCode: 500, code: 'role_not_applied');
    }
    return result.account;
  }

  @override
  Future<AuthSession?> currentSession() async {
    final access = await _local.readAccessToken();
    final refreshToken = await _local.readRefreshToken();
    final expiries = await _local.readExpiries();
    if (access == null || refreshToken == null || expiries == null) return null;

    final session = AuthSession(
      accessToken: access,
      refreshToken: refreshToken,
      accessExpiresAt: expiries.access,
      refreshExpiresAt: expiries.refresh,
    );
    _onAccessTokenChanged(access);
    return session;
  }

  @override
  Future<UserAccount?> cachedAccount() async {
    final json = await _local.readAccount();
    if (json == null) return null;
    final result = _accountFrom(json);
    return result is AccountReady ? result.account : null;
  }

  @override
  Future<AccountResult> fetchAccount() async {
    final json = await _remote.me();
    await _local.saveAccount(json);
    return _accountFrom(json);
  }

  @override
  Future<AuthSession> refresh() {
    // Un seul rafraichissement a la fois ; les appelants suivants attendent le
    // meme resultat.
    return _refreshInFlight ??= _doRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<AuthSession> _doRefresh() async {
    final refreshToken = await _local.readRefreshToken();
    if (refreshToken == null) {
      throw const UnauthorizedFailure(details: {'reason': 'no_refresh_token'});
    }
    final json = await _remote.refresh(refreshToken);
    final session = _sessionFrom(json['session'] as Map<String, dynamic>);
    await _persist(session);
    return session;
  }

  @override
  Future<void> signOut() async {
    // La revocation serveur est souhaitable, pas bloquante : hors ligne, on
    // efface quand meme l'appareil (EXI-SEC10). L'inverse laisserait des jetons
    // sur un telephone que l'utilisateur croit deconnecte.
    try {
      await _remote.logout();
    } on Failure {
      // Ignoree volontairement.
    }
    await _local.wipe();
    _onAccessTokenChanged(null);
  }

  @override
  Future<bool> hasPin() => _local.hasPin();

  @override
  Future<void> setPin(String pin) => _local.setPin(pin);

  @override
  Future<bool> verifyPin(String pin) async => await _local.verifyPin(pin) == null;

  @override
  Future<void> clearPin() => _local.clearPin();

  // --- Mapping ----------------------------------------------------------

  Future<void> _persist(AuthSession session) async {
    await _local.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      accessExpiresAt: session.accessExpiresAt,
      refreshExpiresAt: session.refreshExpiresAt,
    );
    _onAccessTokenChanged(session.accessToken);
  }

  AuthSession _sessionFrom(Map<String, dynamic> json) => AuthSession(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        accessExpiresAt:
            DateTime.parse(json['accessExpiresAt'] as String).toLocal(),
        refreshExpiresAt:
            DateTime.parse(json['refreshExpiresAt'] as String).toLocal(),
      );

  AccountResult _accountFrom(Map<String, dynamic> json) {
    final phone = MalagasyPhone.tryParse(json['phone'] as String? ?? '');
    if (phone == null) {
      throw const ServerFailure(statusCode: 500, code: 'invalid_phone_in_account');
    }

    final role = UserRole.fromWire(json['role'] as String?);
    if (role == null) return AccountProfilePending(phone);

    return AccountReady(
      UserAccount(
        id: json['id'] as String,
        phone: phone,
        role: role,
        displayName: json['displayName'] as String? ?? '',
        createdAt:
            DateTime.tryParse('${json['createdAt']}')?.toLocal() ?? DateTime.now(),
        avatarUrl: json['avatarUrl'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        kycStatus: KycStatus.fromWire(json['kycStatus'] as String?),
      ),
    );
  }
}
