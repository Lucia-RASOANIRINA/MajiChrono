// `hide Column` : drift et Material exposent tous deux un type `Column`.
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:majichrono/core/config/app_config.dart';
import 'package:majichrono/core/logging/app_logger.dart';
import 'package:majichrono/core/network/api_client.dart';
import 'package:majichrono/core/network/data_meter.dart';
import 'package:majichrono/core/network/mock/mock_backend.dart';
import 'package:majichrono/core/network/network_status.dart';
import 'package:majichrono/core/storage/app_database.dart';
import 'package:majichrono/core/storage/prefs_store.dart';
import 'package:majichrono/core/storage/secure_store.dart';
import 'package:majichrono/features/auth/data/mock/auth_mock_module.dart';
import 'package:majichrono/features/delivery/data/mock/delivery_mock_module.dart';

/// Injection de dependances : Riverpod est le seul mecanisme (§9.1).
///
/// Les quatre providers ci-dessous n'ont pas de valeur par defaut : ils sont
/// surcharges au demarrage par `bootstrap()`, apres initialisation asynchrone.
/// Cela evite tout `FutureProvider` a la racine et garantit qu'aucun ecran ne
/// s'affiche avant que le socle ne soit pret.

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('Surcharge par bootstrap()'),
);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Surcharge par bootstrap()'),
);

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Surcharge par bootstrap()'),
);

final dataMeterProvider = Provider<DataMeter>(
  (ref) => throw UnimplementedError('Surcharge par bootstrap()'),
);

final appLoggerProvider = Provider<AppLogger>((ref) => AppLogger.instance);

final prefsStoreProvider = Provider<PrefsStore>(
  (ref) => PrefsStore(ref.watch(sharedPreferencesProvider)),
);

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());

/// Registre des routes simulees. Chaque module y ajoute les siennes.
final mockBackendProvider = Provider<MockBackend>((ref) {
  return MockBackend()
    ..register(CoreMockModule())
    ..register(AuthMockModule())
    ..register(DeliveryMockModule());
});

/// Jeton d'acces courant. Alimente par le module 1 (authentification) ;
/// declare ici parce que le client HTTP en depend des le socle.
final accessTokenProvider = StateProvider<String?>((ref) => null);

/// Langue active, exposee separement du controleur pour eviter un cycle entre
/// le client HTTP (en-tete `Accept-Language`) et la couche presentation.
final activeLanguageCodeProvider = StateProvider<String>((ref) => 'fr');

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    config: ref.watch(appConfigProvider),
    dataMeter: ref.watch(dataMeterProvider),
    mockBackend: ref.watch(mockBackendProvider),
    logger: ref.watch(appLoggerProvider),
    languageProvider: () => ref.read(activeLanguageCodeProvider),
    accessTokenProvider: () => ref.read(accessTokenProvider),
  );
  return client;
});

final networkStatusServiceProvider = Provider<NetworkStatusService>((ref) {
  final service = NetworkStatusService(apiClient: ref.watch(apiClientProvider));
  ref.onDispose(service.dispose);
  return service;
});

/// Etat reseau consomme par le bandeau permanent (EXI-T06).
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(networkStatusServiceProvider);
  // Demarrage differe : la premiere sonde ne doit pas retarder le premier
  // rendu (EXI-P01 : ecran interactif en moins de 2,5 s).
  Future<void>.delayed(const Duration(milliseconds: 300), () => service.start());
  return service.stream;
});

/// Nombre d'elements en attente de synchronisation, affiche dans le bandeau.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.selectOnly(db.syncQueueItems)
    ..addColumns([db.syncQueueItems.id.count()])
    ..where(db.syncQueueItems.status.isNotIn(['abandoned']));
  return query.map((row) => row.read(db.syncQueueItems.id.count()) ?? 0).watchSingle();
});

/// Mode d'apparence, persiste entre deux lancements.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.watch(prefsStoreProvider).getString(PrefsStore.keyThemeMode);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(prefsStoreProvider).setString(PrefsStore.keyThemeMode, mode.name);
  }
}
