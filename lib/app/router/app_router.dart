import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/features/onboarding/presentation/welcome_screen.dart';
import 'package:majichrono/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:majichrono/features/admin/presentation/screens/admin_deliveries_screen.dart';
import 'package:majichrono/features/admin/presentation/screens/disputes_screen.dart';
import 'package:majichrono/features/admin/presentation/screens/fleet_screen.dart';
import 'package:majichrono/features/admin/presentation/screens/kyc_queue_screen.dart';
import 'package:majichrono/app/shell/role_shell.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
import 'package:majichrono/features/auth/domain/entities/google_entities.dart';
import 'package:majichrono/features/auth/presentation/controllers/auth_state.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/features/auth/presentation/screens/lock_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/auth_choice_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/email_auth_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/email_code_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/otp_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/phone_input_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/profile_choice_screen.dart';
import 'package:majichrono/features/delivery/presentation/screens/create_delivery_screen.dart';
import 'package:majichrono/features/delivery/presentation/screens/deliveries_screen.dart';
import 'package:majichrono/features/driver/presentation/screens/active_delivery_screen.dart';
import 'package:majichrono/features/driver/presentation/screens/driver_home_screen.dart';
import 'package:majichrono/features/driver/presentation/screens/driver_deliveries_screen.dart';
import 'package:majichrono/features/driver/presentation/screens/earnings_screen.dart';
import 'package:majichrono/features/profile/presentation/profile_screen.dart';
import 'package:majichrono/features/driver/presentation/screens/kyc_screen.dart';
import 'package:majichrono/features/home/presentation/socle_home_screen.dart';
import 'package:majichrono/features/tracking/presentation/screens/public_tracking_screen.dart';
import 'package:majichrono/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:majichrono/features/settings/presentation/data_usage_screen.dart';
import 'package:majichrono/features/settings/presentation/pending_sync_screen.dart';
import 'package:majichrono/features/settings/presentation/dev_panel_screen.dart';
import 'package:majichrono/features/settings/presentation/settings_screen.dart';
import 'package:majichrono/l10n/app_localizations.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Duree minimale d'affichage de l'ecran d'attente.
///
/// Elle est **nulle** : le logo est desormais porte par l'ecran de demarrage du
/// systeme, qui s'affiche des la premiere milliseconde. Retenir l'utilisateur
/// ici ajouterait une attente derriere une attente, sans rien montrer de plus.
///
/// Le point d'extension est conserve — et non supprime — parce qu'un ecran
/// d'attente sans plancher devient invisible le jour ou on y met quoi que ce
/// soit a regarder. La valeur se change ici, en un seul endroit.
final splashHoldProvider = FutureProvider<void>((ref) async {});

/// Routeur applicatif.
///
/// `go_router` est impose par le §9.1 : les liens profonds sont la seule facon
/// d'ouvrir l'ecran concerne depuis une notification (EXI-N04) et d'honorer le
/// lien de suivi public envoye par SMS (EXI-C24).
final routerProvider = Provider<GoRouter>((ref) {
  // Pont Riverpod -> Listenable : le routeur reevalue ses redirections quand la
  // session change, sans etre reconstruit (ce qui perdrait la pile de navigation).
  final refresh = ValueNotifier<Object?>(null);
  ref.listen(authControllerProvider, (_, next) => refresh.value = next);
  // Le plancher d'affichage compte aussi comme un changement d'etat : sans cette
  // seconde ecoute, le routeur ne reevaluerait rien a son echeance et l'ecran
  // resterait sur la marque.
  ref.listen(splashHoldProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider).valueOrNull;
      final location = state.matchedLocation;

      // Le suivi public est accessible sans compte : le destinataire
      // n'installe rien et n'a pas de session (EXI-C24).
      if (location.startsWith('/track/')) return null;

      // Plancher d'affichage de l'ecran d'attente. Nul aujourd'hui : le logo
      // est porte par l'ecran de demarrage du systeme, en amont.
      if (!ref.watch(splashHoldProvider).hasValue) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // Toute la navigation decoule de l'etat de session, et de lui seul. Le
      // filtrage exhaustif garantit qu'un etat ajoute plus tard ne pourra pas
      // etre oublie ici.
      return switch (auth) {
        // Session en cours de relecture : on reste sur l'ecran d'attente.
        null ||
        AuthUnknown() => location == AppRoutes.splash ? null : AppRoutes.splash,

        AuthUnauthenticated() =>
          AppRoutes.isAuthRoute(location) ? null : AppRoutes.welcome,

        // Session ouverte, profil pas encore pose (EXI-T02).
        AuthProfilePending() =>
          location == AppRoutes.authProfile ? null : AppRoutes.authProfile,

        // Verrou local : rien d'autre n'est atteignable (EXI-T04, EXI-SEC07).
        AuthLocked() =>
          location == AppRoutes.authLock ? null : AppRoutes.authLock,

        AuthAuthenticated(:final account) => _redirectForRole(
          account.role,
          location,
        ),
      };
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const _SplashScreen()),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.authChoice,
        builder: (_, _) => const AuthChoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.authSignIn,
        builder: (_, _) => const EmailAuthScreen(mode: EmailAuthMode.signIn),
      ),
      GoRoute(
        path: AppRoutes.authSignUp,
        builder: (_, _) => const EmailAuthScreen(mode: EmailAuthMode.signUp),
      ),
      GoRoute(
        path: AppRoutes.authPhone,
        builder: (_, _) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: AppRoutes.authOtp,
        builder: (context, state) =>
            OtpScreen(challenge: state.extra! as OtpChallenge),
      ),
      GoRoute(
        path: AppRoutes.authEmailCode,
        builder: (context, state) =>
            EmailCodeScreen(challenge: state.extra! as EmailChallenge),
      ),
      GoRoute(
        path: AppRoutes.authProfile,
        builder: (_, _) => const ProfileChoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.authLock,
        builder: (context, state) {
          final auth = ProviderScope.containerOf(
            context,
          ).read(authControllerProvider).valueOrNull;
          return auth is AuthLocked
              ? LockScreen(state: auth)
              : const _SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.authPin,
        builder: (context, _) => PinSetupScreen(onDone: () => context.pop()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.dataUsage,
        builder: (_, _) => const DataUsageScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingSync,
        builder: (_, _) => const PendingSyncScreen(),
      ),
      // Ecrans de supervision atteints depuis le tableau de bord (EXI-A03,
      // EXI-A04) : la barre inferieure compte deja quatre onglets.
      GoRoute(
        path: AppRoutes.adminKyc,
        builder: (_, _) => const KycQueueScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDeliveries,
        builder: (_, _) => const AdminDeliveriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.devPanel,
        builder: (_, _) => const DevPanelScreen(),
      ),
      GoRoute(
        path: AppRoutes.publicTrack,
        builder: (context, state) =>
            PublicTrackingScreen(token: state.pathParameters['token'] ?? ''),
      ),
      _clientShell(),
      _driverShell(),
      _adminShell(),
    ],
  );
});

StatefulShellRoute _clientShell() => StatefulShellRoute.indexedStack(
  builder: (context, state, shell) {
    final l10n = AppLocalizations.of(context);
    return RoleShell(
      navigationShell: shell,
      destinations: [
        ShellDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: l10n.navHome,
        ),
        ShellDestination(
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          label: l10n.navDeliveries,
        ),
        ShellDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: l10n.navProfile,
        ),
      ],
    );
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.clientHome,
          builder: (_, _) => const SocleHomeScreen(role: UserRole.client),
          routes: [
            GoRoute(
              path: 'new',
              builder: (_, _) => const CreateDeliveryScreen(),
            ),
            GoRoute(
              path: 'track/:id',
              builder: (context, state) =>
                  TrackingScreen(deliveryId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.clientDeliveries,
          builder: (_, _) => const DeliveriesScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.clientProfile,
          builder: (context, _) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

StatefulShellRoute _driverShell() => StatefulShellRoute.indexedStack(
  builder: (context, state, shell) {
    final l10n = AppLocalizations.of(context);
    return RoleShell(
      navigationShell: shell,
      destinations: [
        ShellDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: l10n.navHome,
        ),
        ShellDestination(
          icon: Icons.route_outlined,
          selectedIcon: Icons.route,
          label: l10n.navDeliveries,
        ),
        ShellDestination(
          icon: Icons.payments_outlined,
          selectedIcon: Icons.payments,
          label: l10n.navEarnings,
        ),
        ShellDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: l10n.navProfile,
        ),
      ],
    );
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverHome,
          builder: (_, _) => const DriverHomeScreen(),
          routes: [
            GoRoute(
              path: 'active/:id',
              builder: (context, state) =>
                  ActiveDeliveryScreen(deliveryId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverDeliveries,
          builder: (context, _) => const DriverDeliveriesScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverEarnings,
          builder: (_, _) => const EarningsScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverProfile,
          builder: (_, _) => const KycScreen(),
        ),
      ],
    ),
  ],
);

StatefulShellRoute _adminShell() => StatefulShellRoute.indexedStack(
  builder: (context, state, shell) {
    final l10n = AppLocalizations.of(context);
    return RoleShell(
      navigationShell: shell,
      destinations: [
        ShellDestination(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: l10n.navDashboard,
        ),
        ShellDestination(
          icon: Icons.map_outlined,
          selectedIcon: Icons.map,
          label: l10n.navFleet,
        ),
        ShellDestination(
          icon: Icons.gavel_outlined,
          selectedIcon: Icons.gavel,
          label: l10n.navDisputes,
        ),
        ShellDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: l10n.navProfile,
        ),
      ],
    );
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.adminHome,
          builder: (_, _) => const AdminDashboardScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.adminFleet,
          builder: (_, _) => const FleetScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.adminDisputes,
          builder: (_, _) => const DisputesScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.adminProfile,
          builder: (context, _) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

/// Cloisonnement des profils : un client ne peut pas atteindre une route
/// livreur, meme par lien profond depuis une notification.
String? _redirectForRole(UserRole role, String location) {
  final home = switch (role) {
    UserRole.client => AppRoutes.clientHome,
    UserRole.driver => AppRoutes.driverHome,
    UserRole.admin => AppRoutes.adminHome,
  };

  // Le parcours d'authentification est termine : y revenir n'a plus de sens,
  // sauf pour la creation du code PIN, qui se fait session ouverte.
  if (location == AppRoutes.splash ||
      (AppRoutes.isAuthRoute(location) && location != AppRoutes.authPin)) {
    return home;
  }

  final isRoleRoute =
      location.startsWith('/client') ||
      location.startsWith('/driver') ||
      location.startsWith('/admin');
  if (isRoleRoute && !location.startsWith('/${role.wireName}')) return home;

  return null;
}

/// Ecran d'attente pendant la relecture de la session.
///
/// Un aplat du bleu de la marque, sans rien dessus. Il prolonge exactement
/// l'ecran de lancement Android, qui porte deja ce bleu, et se confond ensuite
/// avec l'accueil qui le porte aussi : l'utilisateur ne voit donc **aucune
/// etape** entre le lanceur et l'animation. Un indicateur de chargement place
/// ici ferait apparaitre une attente la ou il n'y a, le plus souvent, que
/// quelques dizaines de millisecondes de lecture locale.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  // `Scaffold` et non un simple `ColoredBox` : la route est posee directement
  // sous le Navigator, sans contrainte de taille. Un `ColoredBox` y reste sans
  // dimension et ne peint rien — l'ecran devient noir, ce qui ne se voit qu'en
  // release, la ou l'erreur de mise en page ne s'affiche pas.
  // Aucun logo : l'accueil est l'ecran d'entree, et son nom y figure deja en
  // grand. Ce qui s'affiche ici n'est qu'un aplat de la meme couleur que lui,
  // le temps que la session se relise — quelques dizaines de millisecondes. Rien
  // ne clignote entre les deux : l'ecran se remplit, il ne se remplace pas.
  Widget build(BuildContext context) =>
      const Scaffold(backgroundColor: AppColors.primary);
}
