import 'dart:convert';
import 'dart:math';

import 'package:majichrono/core/network/api_endpoints.dart';
import 'package:majichrono/core/network/mock/mock_backend.dart';

/// Routes simulees de l'authentification (§12.2).
///
/// Deux partis pris rendent ce simulateur utilisable en recette :
///
///  - **Il est sans etat persistant.** Le jeton porte lui-meme l'identite du
///    compte, encodee en base64. Une session survit donc au redemarrage de
///    l'application sans qu'aucune base ne soit tenue cote simulateur — ce qui
///    permet de recetter la reconnexion par PIN (EXI-T04) juste apres un
///    « kill » de l'application. Ce n'est evidemment pas un JWT : rien n'est
///    signe, et cela n'a pas a l'etre, puisque ce code n'existe qu'en mode
///    `mock` et ne sera jamais compile face a un vrai serveur.
///
///  - **Le code OTP est renvoye en clair** dans la reponse, sous `debugCode`.
///    Sans passerelle SMS, c'est le seul moyen de derouler le parcours. Le
///    champ est ignore en mode `live`, et l'interface ne l'affiche que si le
///    panneau developpeur est actif.
class AuthMockModule extends MockModule {
  AuthMockModule({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Defis en cours, par identifiant. Volontairement en memoire : un defi OTP
  /// vit cinq minutes, il n'a pas a survivre au processus.
  final Map<String, _Challenge> _challenges = {};

  /// Defis envoyes par e-mail, memes regles de duree et de tentatives.
  final Map<String, _EmailChallenge> _emailChallenges = {};

  /// Rattachements adresse -> numero.
  ///
  /// Le numero reste la cle du compte : l'adresse n'est qu'une seconde porte
  /// vers la meme identite. Une adresse absente de cette table designe donc un
  /// visiteur, pas un compte a creer.
  final Map<String, String> _emailLinks = {...seededEmails};

  static const Duration otpValidity = Duration(minutes: 5);
  static const int maxAttempts = 3;
  static const Duration accessTtl = Duration(minutes: 15);
  static const Duration refreshTtl = Duration(days: 30);

  /// Numeros reserves a la recette, pre-inscrits avec un profil.
  ///
  /// Ils evitent de rejouer le choix de profil a chaque test et donnent un
  /// compte administrateur, que l'inscription mobile ne peut pas produire
  /// (EXI-T02).
  static const Map<String, ({String role, String name})> seededAccounts = {
    '+261340000001': (role: 'client', name: 'Hery Rakoto'),
    '+261330000002': (role: 'driver', name: 'Naina Andria'),
    '+261320000003': (role: 'admin', name: 'Miora Rasoa'),
  };

  /// Adresses deja rattachees a un compte pre-inscrit.
  ///
  /// La troisieme adresse proposee par la detection simulee est volontairement
  /// absente : c'est elle qui deroule le cas « adresse verifiee, compte
  /// inconnu », ou le parcours bascule sur le numero de telephone.
  static const Map<String, String> seededEmails = {
    'hery.rakoto@gmail.com': '+261340000001',
    'naina.andria@gmail.com': '+261330000002',
  };

  @override
  void register(MockBackend backend) {
    backend.post(ApiEndpoints.emailRequest, _requestEmailCode);
    backend.post(ApiEndpoints.emailVerify, _verifyEmailCode);
    backend.post(ApiEndpoints.emailLink, _linkEmail);
    backend.post(ApiEndpoints.otpRequest, _requestOtp);
    backend.post(ApiEndpoints.otpVerify, _verifyOtp);
    backend.post(ApiEndpoints.refresh, _refresh);
    backend.post(ApiEndpoints.logout, _logout);
    backend.get(ApiEndpoints.me, _me);
    backend.patch(ApiEndpoints.me, _patchMe);
  }

  @override
  Future<void> reset() async {
    _challenges.clear();
    _emailChallenges.clear();
    _emailLinks
      ..clear()
      ..addAll(seededEmails);
  }

  // --- POST /auth/email/request -----------------------------------------

  Future<MockResponse> _requestEmailCode(
    MockRequest req,
    Map<String, String> _,
  ) async {
    final email = (req.json['email'] as String?)?.trim().toLowerCase();
    if (email == null || !_looksLikeEmail(email)) {
      return MockResponse.error(
        422,
        'invalid_email',
        'Adresse e-mail invalide',
        details: {
          'fields': {'email': 'format_invalide'},
        },
      );
    }

    final challengeId = 'eml_${_random.nextInt(1 << 32)}';
    final code = (_random.nextInt(900000) + 100000).toString();
    final expiresAt = DateTime.now().add(otpValidity);

    _emailChallenges[challengeId] = _EmailChallenge(
      email: email,
      code: code,
      expiresAt: expiresAt,
      attemptsLeft: maxAttempts,
    );

    // Le serveur ne dit pas si l'adresse est connue : repondre « compte
    // inconnu » avant meme la saisie du code transformerait ce point d'entree en
    // oracle permettant d'enumerer les comptes. La distinction n'apparait qu'a
    // la verification, une fois la possession de la boite prouvee.
    return MockResponse.ok({
      'challengeId': challengeId,
      'email': email,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'attemptsLeft': maxAttempts,
      'debugCode': code,
    });
  }

  // --- POST /auth/email/verify ------------------------------------------

  Future<MockResponse> _verifyEmailCode(
    MockRequest req,
    Map<String, String> _,
  ) async {
    final challengeId = req.json['challengeId'] as String?;
    final code = req.json['code'] as String?;
    final challenge = _emailChallenges[challengeId];

    if (challenge == null) {
      return MockResponse.error(
        422,
        'unknown_challenge',
        'Defi inconnu ou deja utilise',
      );
    }
    if (DateTime.now().isAfter(challenge.expiresAt)) {
      _emailChallenges.remove(challengeId);
      return MockResponse.error(422, 'otp_expired', 'Code expire');
    }
    if (code != challenge.code) {
      final left = challenge.attemptsLeft - 1;
      if (left <= 0) {
        _emailChallenges.remove(challengeId);
        return MockResponse.error(422, 'otp_locked', 'Trop de tentatives');
      }
      _emailChallenges[challengeId!] = challenge.copyWith(attemptsLeft: left);
      return MockResponse.error(
        422,
        'otp_invalid',
        'Code incorrect',
        details: {'attemptsLeft': left},
      );
    }

    _emailChallenges.remove(challengeId);

    final phone = _emailLinks[challenge.email];
    if (phone == null) {
      // Adresse prouvee, compte inconnu. Aucune session n'est ouverte : un
      // compte sans numero ne pourrait ni etre appele par un livreur, ni
      // recevoir le SMS de suivi (EXI-C24).
      return MockResponse.ok({'linked': false, 'email': challenge.email});
    }

    final seeded = seededAccounts[phone];
    final account = _Account(
      id: 'usr_${phone.substring(4)}',
      phone: phone,
      role: seeded?.role,
      name: seeded?.name ?? '',
      createdAt: DateTime.now(),
    );

    return MockResponse.ok({
      'linked': true,
      'session': _issueSession(account),
      'account': account.toJson(),
    });
  }

  // --- POST /auth/email/link --------------------------------------------

  Future<MockResponse> _linkEmail(MockRequest req, Map<String, String> _) async {
    final account = _authenticate(req);
    if (account == null) {
      return MockResponse.error(401, 'unauthorized', 'Jeton absent ou invalide');
    }

    final email = (req.json['email'] as String?)?.trim().toLowerCase();
    if (email == null || !_looksLikeEmail(email)) {
      return MockResponse.error(422, 'invalid_email', 'Adresse e-mail invalide');
    }

    // Une adresse ne vaut que pour un compte : la rattacher a un second en
    // ferait une porte vers deux identites, et le prochain code recu ne dirait
    // plus laquelle ouvrir.
    final existing = _emailLinks[email];
    if (existing != null && existing != account.phone) {
      return MockResponse.error(
        409,
        'email_already_linked',
        'Cette adresse est deja rattachee a un autre compte',
      );
    }

    _emailLinks[email] = account.phone;
    return MockResponse.noContent();
  }

  static bool _looksLikeEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$').hasMatch(value);

  // --- POST /auth/otp/request ------------------------------------------

  Future<MockResponse> _requestOtp(
    MockRequest req,
    Map<String, String> _,
  ) async {
    final phone = req.json['phone'] as String?;
    if (phone == null || !RegExp(r'^\+2613\d{8}$').hasMatch(phone)) {
      return MockResponse.error(
        422,
        'invalid_phone',
        'Numero de telephone malgache invalide',
        details: {
          'fields': {'phone': 'format_invalide'},
        },
      );
    }

    final challengeId = 'chg_${_random.nextInt(1 << 32)}';
    final code = (_random.nextInt(900000) + 100000).toString();
    final expiresAt = DateTime.now().add(otpValidity);

    _challenges[challengeId] = _Challenge(
      phone: phone,
      code: code,
      expiresAt: expiresAt,
      attemptsLeft: maxAttempts,
    );

    return MockResponse.ok({
      'challengeId': challengeId,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'attemptsLeft': maxAttempts,
      'debugCode': code,
    });
  }

  // --- POST /auth/otp/verify -------------------------------------------

  Future<MockResponse> _verifyOtp(
    MockRequest req,
    Map<String, String> _,
  ) async {
    final challengeId = req.json['challengeId'] as String?;
    final code = req.json['code'] as String?;
    final challenge = _challenges[challengeId];

    if (challenge == null) {
      return MockResponse.error(
        422,
        'unknown_challenge',
        'Defi inconnu ou deja utilise',
      );
    }
    if (DateTime.now().isAfter(challenge.expiresAt)) {
      _challenges.remove(challengeId);
      return MockResponse.error(422, 'otp_expired', 'Code expire');
    }
    if (code != challenge.code) {
      final left = challenge.attemptsLeft - 1;
      if (left <= 0) {
        _challenges.remove(challengeId);
        return MockResponse.error(422, 'otp_locked', 'Trop de tentatives');
      }
      _challenges[challengeId!] = challenge.copyWith(attemptsLeft: left);
      return MockResponse.error(
        422,
        'otp_invalid',
        'Code incorrect',
        details: {'attemptsLeft': left},
      );
    }

    // Le defi est brule des qu'il a servi : un code ne vaut qu'une fois.
    _challenges.remove(challengeId);

    final seeded = seededAccounts[challenge.phone];
    final account = _Account(
      id: 'usr_${challenge.phone.substring(4)}',
      phone: challenge.phone,
      role: seeded?.role,
      name: seeded?.name ?? '',
      createdAt: DateTime.now(),
    );

    return MockResponse.ok({
      'session': _issueSession(account),
      'account': account.toJson(),
    });
  }

  // --- POST /auth/refresh ----------------------------------------------

  Future<MockResponse> _refresh(MockRequest req, Map<String, String> _) async {
    final token = req.json['refreshToken'] as String?;
    final claims = _decode(token);
    if (claims == null || claims['typ'] != 'refresh') {
      return MockResponse.error(
        401,
        'invalid_refresh',
        'Jeton de rafraichissement invalide',
      );
    }
    if (_isExpired(claims)) {
      return MockResponse.error(401, 'refresh_expired', 'Session expiree');
    }
    // Rotation : le couple precedent n'est plus valable (EXI-T03).
    return MockResponse.ok({
      'session': _issueSession(_Account.fromClaims(claims)),
    });
  }

  // --- POST /auth/logout -----------------------------------------------

  Future<MockResponse> _logout(MockRequest req, Map<String, String> _) async =>
      MockResponse.noContent();

  // --- GET /me ----------------------------------------------------------

  Future<MockResponse> _me(MockRequest req, Map<String, String> _) async {
    final account = _authenticate(req);
    if (account == null) {
      return MockResponse.error(
        401,
        'unauthorized',
        'Jeton absent ou invalide',
      );
    }
    return MockResponse.ok(account.toJson());
  }

  // --- PATCH /me : pose du profil (EXI-T02) -----------------------------

  Future<MockResponse> _patchMe(MockRequest req, Map<String, String> _) async {
    final account = _authenticate(req);
    if (account == null) {
      return MockResponse.error(
        401,
        'unauthorized',
        'Jeton absent ou invalide',
      );
    }

    final role = req.json['role'] as String?;
    final name = req.json['displayName'] as String?;

    // EXI-T02 : le role administrateur est attribue cote serveur uniquement.
    // Une application qui le reclamerait doit etre refusee, pas ignoree.
    if (role == 'admin') {
      return MockResponse.error(
        403,
        'role_not_assignable',
        'Le role administrateur est attribue cote serveur',
      );
    }
    if (role != null && role != 'client' && role != 'driver') {
      return MockResponse.error(422, 'invalid_role', 'Role inconnu');
    }
    // Le profil ne se choisit qu'une fois : changer de role changerait la nature
    // du compte et l'historique qui y est rattache.
    if (role != null && account.role != null && account.role != role) {
      return MockResponse.error(409, 'role_already_set', 'Profil deja defini');
    }

    final updated = account.copyWith(
      role: role ?? account.role,
      name: name ?? account.name,
      kycStatus: (role ?? account.role) == 'driver' ? 'draft' : null,
    );

    // Le profil fait partie des informations portees par le jeton. Le modifier
    // sans reemettre la session laisserait circuler un jeton qui contredit le
    // compte : le serveur croirait le profil pose, le jeton dirait le contraire,
    // et une seconde tentative de choix passerait au travers du controle
    // ci-dessus. Toute donnee d'identite qui change entraine donc une rotation.
    final reissue = role != null && role != account.role;

    return MockResponse.ok({
      ...updated.toJson(),
      if (reissue) 'session': _issueSession(updated),
    });
  }

  // --- Jetons -----------------------------------------------------------

  Map<String, dynamic> _issueSession(_Account account) {
    final now = DateTime.now();
    return {
      'accessToken': _encode(account.claims('access', now.add(accessTtl))),
      'refreshToken': _encode(account.claims('refresh', now.add(refreshTtl))),
      'accessExpiresAt': now.add(accessTtl).toUtc().toIso8601String(),
      'refreshExpiresAt': now.add(refreshTtl).toUtc().toIso8601String(),
    };
  }

  _Account? _authenticate(MockRequest req) {
    final claims = _decode(req.bearer);
    if (claims == null || claims['typ'] != 'access' || _isExpired(claims)) {
      return null;
    }
    return _Account.fromClaims(claims);
  }

  bool _isExpired(Map<String, dynamic> claims) {
    final exp = DateTime.tryParse('${claims['exp']}');
    return exp == null || DateTime.now().isAfter(exp);
  }

  String _encode(Map<String, dynamic> claims) =>
      base64Url.encode(utf8.encode(jsonEncode(claims)));

  Map<String, dynamic>? _decode(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(base64Url.decode(token)))
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

class _Challenge {
  const _Challenge({
    required this.phone,
    required this.code,
    required this.expiresAt,
    required this.attemptsLeft,
  });

  final String phone;
  final String code;
  final DateTime expiresAt;
  final int attemptsLeft;

  _Challenge copyWith({int? attemptsLeft}) => _Challenge(
    phone: phone,
    code: code,
    expiresAt: expiresAt,
    attemptsLeft: attemptsLeft ?? this.attemptsLeft,
  );
}

class _EmailChallenge {
  const _EmailChallenge({
    required this.email,
    required this.code,
    required this.expiresAt,
    required this.attemptsLeft,
  });

  final String email;
  final String code;
  final DateTime expiresAt;
  final int attemptsLeft;

  _EmailChallenge copyWith({int? attemptsLeft}) => _EmailChallenge(
    email: email,
    code: code,
    expiresAt: expiresAt,
    attemptsLeft: attemptsLeft ?? this.attemptsLeft,
  );
}

class _Account {
  const _Account({
    required this.id,
    required this.phone,
    required this.role,
    required this.name,
    required this.createdAt,
    this.kycStatus,
  });

  factory _Account.fromClaims(Map<String, dynamic> claims) => _Account(
    id: '${claims['sub']}',
    phone: '${claims['phone']}',
    role: claims['role'] as String?,
    name: '${claims['name'] ?? ''}',
    createdAt: DateTime.tryParse('${claims['iat']}') ?? DateTime.now(),
    kycStatus: claims['kyc'] as String?,
  );

  final String id;
  final String phone;
  final String? role;
  final String name;
  final DateTime createdAt;
  final String? kycStatus;

  _Account copyWith({String? role, String? name, String? kycStatus}) =>
      _Account(
        id: id,
        phone: phone,
        role: role ?? this.role,
        name: name ?? this.name,
        createdAt: createdAt,
        kycStatus: kycStatus ?? this.kycStatus,
      );

  Map<String, dynamic> claims(String type, DateTime expiresAt) => {
    'typ': type,
    'sub': id,
    'phone': phone,
    'role': role,
    'name': name,
    'kyc': kycStatus,
    'iat': createdAt.toUtc().toIso8601String(),
    'exp': expiresAt.toUtc().toIso8601String(),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'role': role,
    'displayName': name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'kycStatus': kycStatus,
    'rating': role == 'driver' ? 4.6 : null,
  };
}
