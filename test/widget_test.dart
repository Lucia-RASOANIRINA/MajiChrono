// Tests de la coquille du socle (module 0).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:majichrono/app/app.dart';
import 'package:majichrono/core/config/app_config.dart';
import 'package:majichrono/core/network/data_meter.dart';
import 'package:majichrono/core/network/network_profile.dart';
import 'package:majichrono/core/network/network_status.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/shared/widgets/mc_network_banner.dart';

import 'helpers/in_memory_database.dart';

void main() {
  /// Etat reseau fige.
  ///
  /// Le service reel arme un `Timer.periodic` de sonde ; le laisser tourner
  /// ferait echouer tout test de widget sur un minuteur en attente. On injecte
  /// donc l'etat plutot que le service, ce qui teste le rendu du bandeau sans
  /// tester le reseau — celui-ci ayant ses propres tests unitaires.
  Override networkOverride({required bool online}) =>
      networkStatusProvider.overrideWith(
        (ref) => Stream.value(
          NetworkStatus(
            reachable: online,
            profile: online ? NetworkProfile.fourG : NetworkProfile.offline,
            transport: online ? NetworkTransport.wifi : NetworkTransport.none,
            rttMs: online ? 90 : null,
            lastProbeAt: DateTime(2026, 8, 13),
          ),
        ),
      );

  Future<Widget> buildApp({
    required WidgetTester tester,
    bool online = true,
    UserRole? role,
  }) async {
    SharedPreferences.setMockInitialValues({
      if (role != null) 'session.active_role': role.wireName,
    });
    final prefs = await SharedPreferences.getInstance();
    final db = openInMemoryDatabase();
    addTearDown(db.close);

    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.fromEnvironment()),
        sharedPreferencesProvider.overrideWithValue(prefs),
        dataMeterProvider.overrideWithValue(DataMeter(prefs)),
        appDatabaseProvider.overrideWithValue(db),
        networkOverride(online: online),
        // La base locale n'est pas ouverte dans un test de widget : `flutter
        // test` s'execute sur le poste, ou la bibliotheque native SQLite livree
        // par `sqlite3_flutter_libs` n'est pas chargee. La file de
        // synchronisation aura ses propres tests d'integration au module 6 ;
        // ici seul le rendu du bandeau est en cause.
        pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      ],
      child: const MajiChronoApp(),
    );
  }

  testWidgets('sans role, le socle demarre sur le choix de profil', (tester) async {
    await tester.pumpWidget(await buildApp(tester: tester));
    await tester.pump();

    expect(find.text('Je suis'), findsOneWidget);
    expect(find.text('Expediteur'), findsOneWidget);
    expect(find.text('Livreur'), findsOneWidget);
    expect(find.text('Exploitation'), findsOneWidget);
  });

  testWidgets('la bascule de langue est immediate, sans redemarrage (EXI-T05)',
      (tester) async {
    await tester.pumpWidget(await buildApp(tester: tester));
    await tester.pump();

    expect(find.text('Je suis'), findsOneWidget);

    await tester.tap(find.text('Malagasy'));
    await tester.pumpAndSettle();

    expect(find.text('Izaho dia'), findsOneWidget);
    expect(find.text('Mpandefa'), findsOneWidget);
    expect(find.text('Je suis'), findsNothing);
  });

  testWidgets('avec un role, la coquille du profil est affichee', (tester) async {
    await tester.pumpWidget(await buildApp(tester: tester, role: UserRole.driver));
    await tester.pumpAndSettle();

    expect(find.text('Accueil livreur'), findsOneWidget);
    // Barre de navigation du profil livreur : 4 destinations.
    expect(find.text('Gains'), findsOneWidget);
  });

  testWidgets('le bandeau reseau annonce le hors ligne (EXI-T06)', (tester) async {
    await tester.pumpWidget(await buildApp(tester: tester, online: false));
    await tester.pump();

    expect(find.byType(McNetworkBanner), findsOneWidget);
    expect(find.text('Hors ligne'), findsOneWidget);
  });

  testWidgets(
    'le bandeau reseau survit a un ecran empile — il est permanent (EXI-T06)',
    (tester) async {
      // Regression : place dans la coquille de role, le bandeau disparaissait
      // au premier `push`. Or c'est pendant un constat ou un paiement empile
      // que savoir que le reseau est tombe change le comportement (§15.2.5).
      await tester.pumpWidget(
        await buildApp(tester: tester, online: false, role: UserRole.client),
      );
      await tester.pumpAndSettle();

      expect(find.byType(McNetworkBanner), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Apparence'), findsOneWidget, reason: 'ecran empile ouvert');
      expect(
        find.byType(McNetworkBanner),
        findsOneWidget,
        reason: 'le bandeau doit rester visible au-dessus de l ecran empile',
      );
    },
  );
}
