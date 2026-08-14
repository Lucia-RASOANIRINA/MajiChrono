import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/shell/module_placeholder.dart';
import 'package:majichrono/app/shell/role_shell.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
import 'package:majichrono/features/auth/presentation/controllers/auth_state.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/features/auth/presentation/screens/lock_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/otp_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/phone_input_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:majichrono/features/auth/presentation/screens/profile_choice_screen.dart';
import 'package:majichrono/features/delivery/presentation/screens/create_delivery_screen.dart';
import 'package:majichrono/features/delivery/presentation/screens/deliveries_screen.dart';
import 'package:majichrono/features/home/presentation/socle_home_screen.dart';
import 'package:majichrono/features/settings/presentation/data_usage_screen.dart';
import 'package:majichrono/features/settings/presentation/dev_panel_screen.dart';
import 'package:majichrono/features/settings/presentation/settings_screen.dart';
import 'package:majichrono/l10n/app_localizations.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

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

      // Toute la navigation decoule de l'etat de session, et de lui seul. Le
      // filtrage exhaustif garantit qu'un etat ajoute plus tard ne pourra pas
      // etre oublie ici.
      return switch (auth) {
        // Session en cours de relecture : on reste sur l'ecran d'attente.
        null || AuthUnknown() =>
          location == AppRoutes.splash ? null : AppRoutes.splash,

        AuthUnauthenticated() =>
          AppRoutes.isAuthRoute(location) ? null : AppRoutes.authPhone,

        // Session ouverte, profil pas encore pose (EXI-T02).
        AuthProfilePending() =>
          location == AppRoutes.authProfile ? null : AppRoutes.authProfile,

        // Verrou local : rien d'autre n'est atteignable (EXI-T04, EXI-SEC07).
        AuthLocked() => location == AppRoutes.authLock ? null : AppRoutes.authLock,

        AuthAuthenticated(:final account) => _redirectForRole(account.role, location),
      };
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const _SplashScreen()),
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
        path: AppRoutes.authProfile,
        builder: (_, _) => const ProfileChoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.authLock,
        builder: (context, state) {
          final auth = ProviderScope.containerOf(context)
              .read(authControllerProvider)
              .valueOrNull;
          return auth is AuthLocked
              ? LockScreen(state: auth)
              : const _SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.authPin,
        builder: (context, _) =>
            PinSetupScreen(onDone: () => context.pop()),
      ),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: AppRoutes.dataUsage, builder: (_, _) => const DataUsageScreen()),
      GoRoute(path: AppRoutes.devPanel, builder: (_, _) => const DevPanelScreen()),
      GoRoute(
        path: AppRoutes.publicTrack,
        builder: (context, state) => ModulePlaceholderScreen(
          title: AppLocalizations.of(context).navTracking,
          module: '3',
          icon: Icons.share_location_outlined,
          requirements: const ['EXI-C24', 'D9'],
        ),
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
          builder: (context, _) => ModulePlaceholderScreen(
            title: AppLocalizations.of(context).navProfile,
            module: '1',
            icon: Icons.person_outline,
            requirements: const ['EXI-T02', 'EXI-T04'],
          ),
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
          builder: (_, _) => const SocleHomeScreen(role: UserRole.driver),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverDeliveries,
          builder: (context, _) => ModulePlaceholderScreen(
            title: AppLocalizations.of(context).navDeliveries,
            module: '4',
            icon: Icons.route_outlined,
            requirements: const ['EXI-L04', 'EXI-L05', 'EXI-L08', 'EXI-L15'],
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverEarnings,
          builder: (context, _) => ModulePlaceholderScreen(
            title: AppLocalizations.of(context).navEarnings,
            module: '4',
            icon: Icons.payments_outlined,
            requirements: const ['EXI-L12'],
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverProfile,
          builder: (context, _) => ModulePlaceholderScreen(
            title: AppLocalizations.of(context).navProfile,
            module: '4',
            icon: Icons.badge_outlined,
            requirements: const ['EXI-L01', 'EXI-L02'],
          ),
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
          builder: (_, _) => const SocleHomeScreen(role: UserRole.admin),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.adminFleet,
          builder: (context, _) => ModulePlaceholderScreen(
            title: AppLocalizations.of(context).navFleet,
            module: '8',
            icon: Icons.map_outlined,
            requirements: const ['EXI-A02'],
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.adminDisputes,
          builder: (context, _) => ModulePlaceholderScreen(
            title: AppLocalizations.of(context).navDisputes,
            module: '8',
            icon: Icons.gavel_outlined,
            requirements: const ['EXI-A05', 'EXI-CC30'],
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.adminProfile,
          builder: (context, _) => ModulePlaceholderScreen(
            title: AppLocalizations.of(context).navProfile,
            module: '1',
            icon: Icons.person_outline,
            requirements: const ['EXI-T02'],
          ),
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

  final isRoleRoute = location.startsWith('/client') ||
      location.startsWith('/driver') ||
      location.startsWith('/admin');
  if (isRoleRoute && !location.startsWith('/${role.wireName}')) return home;

  return null;
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
