import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/domain/entities/price_estimate.dart';
import 'package:majichrono/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';
import 'package:majichrono/shared/widgets/mc_skeleton.dart';

/// Historique des courses (EXI-C33).
///
/// Alimente par la base locale, donc consultable hors ligne. Le rafraichissement
/// serveur est un complement, jamais une condition d'affichage.
class DeliveriesScreen extends ConsumerWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deliveries = ref.watch(deliveriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deliveriesTitle)),
      body: deliveries.when(
        loading: () => const McSkeletonList(),
        error: (_, __) => McEmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.emptyDeliveries,
          message: l10n.errorUnknown,
        ),
        data: (items) => items.isEmpty
            ? McEmptyState(
                icon: Icons.inventory_2_outlined,
                title: l10n.emptyDeliveries,
                message: l10n.addrBookEmptyHelp,
                actionLabel: l10n.emptyDeliveriesAction,
                onAction: () => context.push(AppRoutes.clientNewDelivery),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(deliveryRepositoryProvider).refreshDeliveries(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      DeliveryCard(delivery: items[index]),
                ),
              ),
      ),
    );
  }
}

/// Carte resumant une course.
class DeliveryCard extends StatelessWidget {
  const DeliveryCard({required this.delivery, super.key});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: StatusBadge(status: delivery.status)),
                if (delivery.priceAriary != null)
                  Text(
                    formatAriary(delivery.priceAriary!),
                    style: theme.textTheme.titleMedium,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _AddressLine(
              icon: Icons.trip_origin,
              text: delivery.pickup.summary,
            ),
            const SizedBox(height: AppSpacing.xs),
            _AddressLine(
              icon: Icons.place_outlined,
              text: delivery.dropoff.summary,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.straighten,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.deliveryDistance(delivery.distanceKm.toStringAsFixed(1)),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                if (delivery.pendingSync)
                  // Une course non transmise est signalee explicitement : elle
                  // existe pour l'utilisateur, mais aucun livreur ne l'a encore
                  // vue (EXI-C13).
                  Row(
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 16,
                        color: AppColors.offline,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.deliveryPendingSync,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.offline),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  const _AddressLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}

/// Pastille de statut.
///
/// Couleur **et** libelle : la couleur seule serait illisible en plein soleil et
/// pour un daltonisme (EXI-T09).
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final (color, label) = switch (status) {
      DeliveryStatus.draft => (AppColors.neutral, l10n.statusDraft),
      DeliveryStatus.pending => (AppColors.warning, l10n.statusPending),
      DeliveryStatus.accepted => (AppColors.info, l10n.statusAccepted),
      DeliveryStatus.atPickup => (AppColors.info, l10n.statusAtPickup),
      DeliveryStatus.pickedUp => (AppColors.info, l10n.statusPickedUp),
      DeliveryStatus.inTransit => (AppColors.info, l10n.statusInTransit),
      DeliveryStatus.atDestination => (AppColors.info, l10n.statusAtDestination),
      DeliveryStatus.delivered => (AppColors.success, l10n.statusDelivered),
      DeliveryStatus.deliveredWithReserves => (
          AppColors.warning,
          l10n.statusDeliveredWithReserves
        ),
      DeliveryStatus.refused => (AppColors.danger, l10n.statusRefused),
      DeliveryStatus.returning => (AppColors.warning, l10n.statusReturning),
      DeliveryStatus.paid => (AppColors.success, l10n.statusPaid),
      DeliveryStatus.disputed => (AppColors.danger, l10n.statusDisputed),
      DeliveryStatus.cancelled => (AppColors.neutral, l10n.statusCancelled),
      DeliveryStatus.closed => (AppColors.neutral, l10n.statusClosed),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
