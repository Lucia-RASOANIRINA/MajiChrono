import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/features/admin/presentation/providers/admin_providers.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/domain/entities/price_estimate.dart';
import 'package:majichrono/features/delivery/presentation/screens/deliveries_screen.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_error_view.dart';
import 'package:majichrono/shared/widgets/mc_skeleton.dart';

/// Tableau de bord de l'exploitation (EXI-A01).
///
/// Il repond a une seule question : **qu'est-ce qui demande une action tout de
/// suite ?** Les compteurs ne sont donc pas ranges par ordre alphabetique ni
/// par elegance visuelle, mais par urgence — ce qui attend une decision humaine
/// en premier, le chiffre d'affaires en dernier.
///
/// Chaque compteur est cliquable et mene a l'ecran qui permet d'agir. Un
/// tableau de bord qui affiche « 3 dossiers a valider » sans y conduire oblige
/// a chercher, et on ne cherche pas quand on est presse.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDashboardTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminDashboardProvider),
        child: summary.when(
          loading: () => const McSkeletonList(itemCount: 5),
          error: (error, _) => McErrorView(
            // Toute erreur remontee par la pile reseau est deja un Failure
            // (voir error_mapper.dart) ; le reste tient de l'imprevu.
            failure: error is Failure ? error : const UnknownFailure(),
            onRetry: () => ref.invalidate(adminDashboardProvider),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Ce qui attend une decision humaine, d'abord.
              _StatTile(
                icon: Icons.badge_outlined,
                label: l10n.adminPendingKyc,
                value: '${data.pendingKyc}',
                tone: data.pendingKyc > 0 ? AppColors.warning : null,
                onTap: () => context.push(AppRoutes.adminKyc),
              ),
              _StatTile(
                icon: Icons.gavel_outlined,
                label: l10n.adminOpenDisputes,
                value: '${data.openDisputes}',
                tone: data.openDisputes > 0 ? AppColors.danger : null,
                onTap: () => context.go(AppRoutes.adminDisputes),
              ),
              _StatTile(
                icon: Icons.report_problem_outlined,
                label: l10n.adminOpenIncidents,
                value: '${data.openIncidents}',
                tone: data.openIncidents > 0 ? AppColors.warning : null,
                onTap: () => context.push(AppRoutes.adminDeliveries),
              ),

              const SizedBox(height: AppSpacing.md),
              _StatTile(
                icon: Icons.local_shipping_outlined,
                label: l10n.adminActiveDeliveries,
                value: '${data.activeDeliveries}',
                onTap: () => context.push(AppRoutes.adminDeliveries),
              ),
              _StatTile(
                icon: Icons.two_wheeler_outlined,
                label: l10n.adminOnlineDrivers,
                value: '${data.onlineDrivers}',
                onTap: () => context.go(AppRoutes.adminFleet),
              ),
              _StatTile(
                icon: Icons.payments_outlined,
                label: l10n.adminRevenueToday,
                value: formatAriary(data.revenueTodayAriary),
              ),

              if (data.byStatus.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.adminByStatus,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatusBreakdown(byStatus: data.byStatus),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.tone,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Couleur d'alerte, posee uniquement quand le compteur reclame une action.
  /// Un tableau de bord entierement colore ne signale plus rien.
  final Color? tone;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: tone),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tone,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Repartition des courses par statut.
///
/// Un total de courses actives ne dit rien : vingt courses en attente
/// d'acceptation et vingt courses en transit decrivent deux journees opposees,
/// l'une ou il manque des livreurs, l'autre ou tout roule.
class _StatusBreakdown extends StatelessWidget {
  const _StatusBreakdown({required this.byStatus});

  final Map<DeliveryStatus, int> byStatus;

  @override
  Widget build(BuildContext context) {
    final entries = byStatus.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          children: [
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Expanded(child: StatusBadge(status: entry.key)),
                    Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
