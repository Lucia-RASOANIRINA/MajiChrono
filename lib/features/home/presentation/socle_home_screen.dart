import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/presentation/controllers/auth_state.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:majichrono/features/delivery/presentation/screens/deliveries_screen.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_app_header.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';
import 'package:majichrono/shared/widgets/mc_quick_action.dart';
import 'package:majichrono/shared/widgets/mc_section_header.dart';
import 'package:majichrono/shared/widgets/mc_skeleton.dart';

/// Accueil de l'expediteur.
///
/// Reprend le langage de l'ecran de choix de connexion — bandeau bleu, trame
/// technique — pour que le passage de l'entree a l'accueil se lise comme une
/// meme application. Le bandeau porte la salutation et l'etat du reseau ; en
/// dessous, deux mesures utiles (donnees du mois, file de synchro), puis les
/// courses, la question a laquelle l'accueil doit repondre d'abord : « ou en
/// est mon colis ? ».
///
/// Le socle du module 0 reste derriere l'ecran (sonde reseau reelle, compteur
/// de donnees, langue a chaud, base locale) ; c'est desormais l'accueil metier
/// qui l'expose, au lieu d'une fiche de diagnostic.
class SocleHomeScreen extends ConsumerWidget {
  const SocleHomeScreen({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final status = ref.watch(networkStatusProvider);
    final pending = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;
    final online = status.valueOrNull?.isOnline ?? false;

    final fallbackTitle = switch (role) {
      UserRole.client => l10n.clientHomeTitle,
      UserRole.driver => l10n.driverHomeTitle,
      UserRole.admin => l10n.adminHomeTitle,
    };
    final name = _accountName(ref);
    final greeting = name != null ? l10n.authWelcome(name) : fallbackTitle;

    final statusLabel = online
        ? l10n.networkOnline
        : (pending > 0
              ? l10n.networkOfflinePending(pending)
              : l10n.networkOfflineNoPending);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          McAppHeader(
            greeting: greeting,
            subtitle: l10n.roleClient,
            statusLabel: statusLabel,
            statusIcon: online
                ? Icons.cloud_done_outlined
                : Icons.cloud_off_outlined,
            statusOnline: online,
            actions: [
              if (config.enableDevPanel)
                IconButton(
                  tooltip: l10n.devPanelTitle,
                  icon: const Icon(
                    Icons.bug_report_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () => context.push(AppRoutes.devPanel),
                ),
              IconButton(
                tooltip: l10n.settingsTitle,
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // `IntrinsicHeight` donne aux deux tuiles la meme hauteur (celle
                // de la plus grande) : sans lui, `stretch` reclamerait une
                // hauteur infinie dans la liste, et les deux tuiles pourraient
                // se decaler si un libelle passe sur deux lignes.
                // Acces rapide aux gestes frequents, en grille 2x2 : le premier
                // ecran doit mettre l'action a portee de pouce, pas obliger a
                // chercher dans un menu.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: McQuickAction(
                          icon: Icons.add_box_outlined,
                          label: l10n.clientNewDelivery,
                          onTap: () =>
                              context.push(AppRoutes.clientNewDelivery),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: McQuickAction(
                          icon: Icons.inventory_2_outlined,
                          label: l10n.navDeliveries,
                          tint: AppColors.info,
                          onTap: () => context.go(AppRoutes.clientDeliveries),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: McQuickAction(
                          icon: Icons.data_usage_outlined,
                          label: l10n.dataUsageTitle,
                          tint: AppColors.accent,
                          onTap: () => context.push(AppRoutes.dataUsage),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: McQuickAction(
                          icon: Icons.cloud_sync_outlined,
                          label: l10n.syncPendingTitle,
                          tint: pending > 0
                              ? AppColors.warning
                              : AppColors.neutral,
                          onTap: () => context.push(AppRoutes.pendingSync),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                McSectionHeader(
                  title: l10n.navDeliveries,
                  actionLabel: l10n.commonSeeAll,
                  onAction: () => context.go(AppRoutes.clientDeliveries),
                ),
                const SizedBox(height: AppSpacing.md),
                if (role == UserRole.client)
                  const _ClientDeliveries()
                else
                  SizedBox(
                    height: 240,
                    child: McEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.emptyDeliveries,
                      message: l10n.shellModuleWipDesc('4'),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nom affichable du compte courant, quand la session en porte un.
  String? _accountName(WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).valueOrNull;
    return switch (auth) {
      AuthAuthenticated(:final account) => account.displayName,
      AuthLocked(:final account) => account.displayName,
      _ => null,
    };
  }
}

/// Apercu des courses de l'expediteur, servi par la base locale.
///
/// Les courses en cours d'abord, puis les plus recentes : l'accueil repond a
/// « ou en est mon colis ? », pas a « qu'ai-je envoye l'an dernier ? ».
class _ClientDeliveries extends ConsumerWidget {
  const _ClientDeliveries();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deliveries = ref.watch(deliveriesProvider).valueOrNull;

    if (deliveries == null) {
      return const SizedBox(height: 200, child: McSkeletonList(itemCount: 2));
    }

    if (deliveries.isEmpty) {
      return SizedBox(
        height: 260,
        child: Card(
          child: McEmptyState(
            icon: Icons.inventory_2_outlined,
            title: l10n.emptyDeliveries,
            message: l10n.addrBookEmptyHelp,
            actionLabel: l10n.emptyDeliveriesAction,
            onAction: () => context.push(AppRoutes.clientNewDelivery),
          ),
        ),
      );
    }

    final visible = deliveries.take(3).toList();
    return Column(
      children: [
        for (final delivery in visible) ...[
          DeliveryCard(delivery: delivery),
          const SizedBox(height: AppSpacing.md),
        ],
        FilledButton.tonalIcon(
          onPressed: () => context.push(AppRoutes.clientNewDelivery),
          icon: const Icon(Icons.add),
          label: Text(l10n.clientNewDelivery),
        ),
      ],
    );
  }
}
