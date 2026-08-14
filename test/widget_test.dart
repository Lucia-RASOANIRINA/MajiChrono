// Tests de la coquille et des redirections pilotees par la session.
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
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
import 'package:majichrono/features/auth/domain/value_objects/malagasy_phone.dart';
import 'package:majichrono/features/auth/presentation/controllers/auth_controller.dart';
import 'package:majichrono/features/auth/presentation/controllers/auth_state.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:majichrono/shared/widgets/mc_network_banner.dart';

import 'helpers/in_memory_database.dart';

/// Contrôleur fige : la coquille est testee pour un etat de session donne,
/// sans rejouer le parcours d'authentification, qui a ses propres tests.
class _FixedAuthController extends AuthController {
  _FixedAuthController(this._fixed);

  final AuthState _fixed;

  @override
  Future<AuthState> build() async => _fixed;
}

UserAccount _account(UserRole role) => UserAccount(
      id: 'usr_test',
      phone: MalagasyPhone.tryParse('0341234567')!,
      role: role,
      displayName: 'Naina',
      createdAt: DateTime(2026, 8, 1),
    );

void main() {
  Override _network({required bool online}) => networkStatusProvider.overrideWith(
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
    required AuthState auth,
    bool online = true,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = openInMemoryDatabase();
    addTearDown(db.close);

    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.fromEnvironment()),
        sharedPreferencesProvider.overrideWithValue(prefs),
        dataMeterProvider.overrideWithValue(DataMeter(prefs)),
        appDatabaseProvider.overrideWithValue(db),
        _network(online: online),
        // La base locale n'est pas ouverte dans un test de widget : `flutter
        // test` s'execute sur le poste, ou la bibliotheque native SQLite livree
        // pour Android n'est pas chargee.
        pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
        // Idem pour les courses : sans valeur immediate, l'accueil expediteur
        // affiche un squelette qui s'anime en boucle, et `pumpAndSettle`
        // n'atteint jamais l'etat stable qu'il attend.
        deliveriesProvider.overrideWith((ref) => Stream.value(const [])),
        authControllerProvider.overrideWith(() => _FixedAuthController(auth)),
      ],
      child: const MajiChronoApp(),
    );
  }

  testWidgets('sans session, l application demande le numero de telephone',
      (tester) async {
    await tester.pumpWidget(
      await buildApp(tester: tester, auth: const AuthUnauthenticated()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Votre numero'), findsOneWidget);
    expect(find.text('Numero de telephone'), findsOneWidget);
  });

  testWidgets('la bascule de langue est immediate, sans redemarrage (EXI-T05)',
      (tester) async {
    await tester.pumpWidget(
      await buildApp(tester: tester, auth: const AuthUnauthenticated()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Votre numero'), findsOneWidget);

    await tester.tap(find.text('Malagasy'));
    await tester.pumpAndSettle();

    expect(find.text('Ny laharanao'), findsOneWidget);
    expect(find.text('Votre numero'), findsNothing);
  });

  testWidgets('une session sans profil mene au choix de profil (EXI-T02)',
      (tester) async {
    await tester.pumpWidget(
      await buildApp(
        tester: tester,
        auth: AuthProfilePending(MalagasyPhone.tryParse('0341234567')!),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Votre profil'), findsOneWidget);
    expect(find.text('Expediteur'), findsOneWidget);
    expect(find.text('Livreur'), findsOneWidget);
    // Le profil exploitation ne se choisit pas ici (EXI-T02).
    expect(find.text('Exploitation'), findsNothing);
  });

  testWidgets('une session verrouillee ne laisse passer que le code (EXI-T04)',
      (tester) async {
    await tester.pumpWidget(
      await buildApp(tester: tester, auth: AuthLocked(_account(UserRole.driver))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Naina'), findsOneWidget);
    expect(find.text('Accueil livreur'), findsNothing);
  });

  testWidgets('une session livreur ouvre la coquille livreur', (tester) async {
    await tester.pumpWidget(
      await buildApp(
        tester: tester,
        auth: AuthAuthenticated(_account(UserRole.driver)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accueil livreur'), findsOneWidget);
    expect(find.text('Gains'), findsOneWidget);
  });

  testWidgets('le bandeau reseau annonce le hors ligne (EXI-T06)', (tester) async {
    await tester.pumpWidget(
      await buildApp(
        tester: tester,
        auth: const AuthUnauthenticated(),
        online: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(McNetworkBanner), findsOneWidget);
    expect(find.text('Hors ligne'), findsOneWidget);
  });

  testWidgets(
    'le bandeau reseau survit a un ecran empile — il est permanent (EXI-T06)',
    (tester) async {
      // Regression : place dans la coquille de role, le bandeau disparaissait au
      // premier `push`. Or c'est pendant un constat ou un paiement empile que
      // savoir que le reseau est tombe change le comportement (§15.2.5).
      await tester.pumpWidget(
        await buildApp(
          tester: tester,
          auth: AuthAuthenticated(_account(UserRole.client)),
          online: false,
        ),
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
