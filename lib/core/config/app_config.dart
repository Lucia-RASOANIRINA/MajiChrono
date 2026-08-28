/// Configuration injectee a la compilation (EXI-SEC08 : aucun secret en dur).
///
/// Usage :
///   flutter run --dart-define=API_MODE=mock
///   flutter run --dart-define=API_MODE=live --dart-define=API_BASE_URL=https://api.majichrono.mg/v2
library;

import 'package:flutter/foundation.dart' show kReleaseMode;

enum ApiMode { mock, live }

enum BuildFlavor { dev, staging, prod }

class AppConfig {
  const AppConfig({
    required this.apiMode,
    required this.apiBaseUrl,
    required this.flavor,
    required this.apiVersion,
    required this.enableDevPanel,
    required this.sentryDsn,
  });

  factory AppConfig.fromEnvironment() {
    const modeRaw = String.fromEnvironment('API_MODE', defaultValue: 'mock');
    const flavorRaw = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.majichrono.mg/v2',
    );
    const dsn = String.fromEnvironment('SENTRY_DSN');

    final mode = modeRaw == 'live' ? ApiMode.live : ApiMode.mock;
    final flavor = switch (flavorRaw) {
      'prod' => BuildFlavor.prod,
      'staging' => BuildFlavor.staging,
      _ => BuildFlavor.dev,
    };

    return AppConfig(
      apiMode: mode,
      apiBaseUrl: baseUrl,
      flavor: flavor,
      apiVersion: 2,
      // Les outils de developpement — panneau dev, code affiche a l'ecran —
      // n'apparaissent qu'en build **debug** et hors flavor prod. Un APK release,
      // meme construit par megarde avec le flavor dev, ne les montre jamais : on
      // ne laisse pas fuiter un code de connexion sur le telephone d'un vrai
      // utilisateur (EXI-SEC08).
      enableDevPanel: flavor != BuildFlavor.prod && !kReleaseMode,
      sentryDsn: dsn.isEmpty ? null : dsn,
    );
  }

  final ApiMode apiMode;
  final String apiBaseUrl;
  final BuildFlavor flavor;
  final int apiVersion;
  final bool enableDevPanel;
  final String? sentryDsn;

  bool get isMock => apiMode == ApiMode.mock;
  bool get isProd => flavor == BuildFlavor.prod;

  /// Duree de vie du jeton d'acces (EXI-T03).
  Duration get accessTokenTtl => const Duration(minutes: 15);

  /// Duree de vie du jeton de rafraichissement (EXI-T03).
  Duration get refreshTokenTtl => const Duration(days: 30);

  /// Verrouillage automatique livreur / admin (EXI-SEC07).
  Duration get autoLockDelay => const Duration(minutes: 5);
}
