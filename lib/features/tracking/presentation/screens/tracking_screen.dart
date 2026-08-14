import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:majichrono/features/delivery/presentation/screens/deliveries_screen.dart';
import 'package:majichrono/features/tracking/domain/entities/tracking.dart';
import 'package:majichrono/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:majichrono/features/tracking/presentation/widgets/delivery_map.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';
import 'package:majichrono/shared/widgets/mc_skeleton.dart';

/// Suivi d'une course pour l'expediteur (EXI-C20 a EXI-C24).
class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({required this.deliveryId, super.key});

  final String deliveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deliveriesAsync = ref.watch(deliveriesProvider);
    final deliveries = deliveriesAsync.valueOrNull;
    final delivery = deliveries?.where((d) => d.id == deliveryId).firstOrNull;
    final tracking = ref.watch(trackingProvider(deliveryId));

    // Trois cas distincts, et non deux : la base locale peut encore etre en
    // train de repondre. Les confondre affichait un ecran vide, sans rien dire
    // a l'utilisateur — exactement ce que le §15.2.3 interdit.
    if (deliveries == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.trackingTitle)),
        body: const McSkeletonList(itemCount: 3),
      );
    }

    if (delivery == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.trackingTitle)),
        body: McEmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.emptyDeliveries,
          message: l10n.trackingPublicExpired,
        ),
      );
    }

    final snapshot = tracking.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Le statut d'abord : c'est la reponse a « ou en est mon colis ? ».
          // La carte le precise, elle ne le remplace pas.
          Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Row(
                children: [
                  Expanded(
                    child: StatusBadge(status: snapshot?.status ?? delivery.status),
                  ),
                  if (snapshot?.etaMinutes != null)
                    Text(
                      l10n.trackingEta(snapshot!.etaMinutes!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DeliveryMap(
            pickup: delivery.pickup.point,
            dropoff: delivery.dropoff.point,
            driverPosition: snapshot?.driverPosition,
            trace: snapshot?.trace ?? const [],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (snapshot?.driver != null) ...[
            _DriverCard(driver: snapshot!.driver!),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (delivery.trackingToken != null) ...[
            _ShareTrackingCard(token: delivery.trackingToken!),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(l10n.trackingTimeline,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (snapshot == null)
            // `nested` : ce squelette vit dans la liste de l'ecran.
            const McSkeletonList(itemCount: 2, nested: true)
          else
            _Timeline(entries: snapshot.timeline),
        ],
      ),
    );
  }
}

/// Fiche livreur (EXI-C22, EXI-C23).
class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver});

  final DriverInfo driver;

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
            Text(l10n.trackingDriver, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: AppSizes.avatarMd / 2,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.displayName, style: theme.textTheme.titleMedium),
                      if (driver.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: AppColors.accent),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              l10n.trackingRating(
                                driver.rating!.toStringAsFixed(1),
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      if (driver.plate != null || driver.vehicleModel != null)
                        Text(
                          [driver.vehicleModel, driver.plate]
                              .whereType<String>()
                              .join(' · '),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined),
                    label: Text('${l10n.trackingCall} ${driver.maskedPhone}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    // EXI-C23 : les numeros sont masques des deux cotes. On le
                    // dit a l'utilisateur, sinon un numero masque passe pour un
                    // defaut d'affichage.
                    l10n.trackingCallMasked,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Partage du lien de suivi public (EXI-C24, differenciant D9).
class _ShareTrackingCard extends StatelessWidget {
  const _ShareTrackingCard({required this.token});

  final String token;

  static const String publicHost = 'https://suivi.majichrono.mg';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final url = '$publicHost/$token';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.share_outlined),
        title: Text(l10n.trackingShare),
        subtitle: Text(
          url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.copy_outlined),
        // Le destinataire n'installe rien : il recoit un lien par SMS et suit
        // le colis dans son navigateur (D9).
        onTap: () async {
          await Clipboard.setData(
            ClipboardData(text: l10n.trackingShareMessage(url)),
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.linkCopied)),
          );
        },
      ),
    );
  }
}

/// Frise chronologique horodatee (EXI-C21).
class _Timeline extends StatelessWidget {
  const _Timeline({required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return Text(
        AppLocalizations.of(context).trackingNoDriverYet,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          children: [
            for (var i = 0; i < entries.length; i++)
              _TimelineRow(
                entry: entries[i],
                isFirst: i == 0,
                isLast: i == entries.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time =
        '${entry.at.hour.toString().padLeft(2, '0')}:${entry.at.minute.toString().padLeft(2, '0')}';

    // Hauteurs fixes plutot qu'`IntrinsicHeight` avec un `Expanded` : mesurer
    // la hauteur intrinseque d'une colonne qui contient un enfant flexible est
    // un piege de mise en page, du meme genre que celui qui a vide cet ecran.
    // Une frise n'a pas besoin de s'etirer : ses etapes ont toutes la meme
    // hauteur.
    const rowHeight = 56.0;

    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 14,
                  color:
                      isFirst ? Colors.transparent : theme.colorScheme.outlineVariant,
                ),
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color:
                        isLast ? theme.colorScheme.primary : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  height: rowHeight - 26,
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(status: entry.status),
                Text(
                  time,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
