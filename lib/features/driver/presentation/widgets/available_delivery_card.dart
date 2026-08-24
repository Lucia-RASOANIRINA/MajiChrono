import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/features/delivery/domain/entities/price_estimate.dart';
import 'package:majichrono/features/driver/domain/entities/driver_entities.dart';
import 'package:majichrono/features/driver/presentation/providers/driver_providers.dart';
import 'package:majichrono/features/driver/presentation/widgets/package_traits.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';

/// Carte d'une course proposee, avec acceptation en un geste (EXI-L05).
///
/// Le compte a rebours de 30 s est affiche sur le bouton lui-meme, et non dans
/// un coin : c'est l'information qui decide, et le livreur regarde le bouton
/// qu'il s'apprete a toucher. A l'expiration, la proposition disparait — une
/// offre perimee qu'on peut encore toucher produit un refus serveur et une
/// frustration inutile.
class AvailableDeliveryCard extends ConsumerStatefulWidget {
  const AvailableDeliveryCard({required this.offer, super.key});

  final AvailableDelivery offer;

  @override
  ConsumerState<AvailableDeliveryCard> createState() =>
      _AvailableDeliveryCardState();
}

class _AvailableDeliveryCardState extends ConsumerState<AvailableDeliveryCard> {
  static const int windowSeconds = 30;

  Timer? _ticker;
  int _remaining = windowSeconds;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _remaining > 0 ? _remaining - 1 : 0);
      if (_remaining == 0) _ticker?.cancel();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final deliveryId = widget.offer.delivery.id;
    var accepted = false;

    try {
      await ref.read(driverActionsProvider).accept(deliveryId);
      accepted = true;
    } on ConflictFailure {
      // Course prise par un autre : cas normal de la course a l'acceptation.
      messenger.showSnackBar(SnackBar(content: Text(l10n.driverAlreadyTaken)));
    } on Failure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }

    // La discussion avec l'expediteur s'ouvre d'elle-meme des l'acceptation :
    // c'est le moment ou les deux ont besoin de se coordonner (« j'arrive »,
    // « je suis en bas »), sans avoir a chercher un bouton.
    if (accepted && mounted) {
      unawaited(router.push(AppRoutes.chat(deliveryId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final offer = widget.offer;
    final expired = _remaining == 0;

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.driverEarning,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  formatAriary(offer.estimatedEarningAriary),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            // Ce que le livreur doit savoir **avant** d'accepter : fragile,
            // lourd, precieux. L'information existait dans la declaration
            // (EXI-C08) sans etre montree nulle part.
            PackageTraits(delivery: offer.delivery),

            const SizedBox(height: AppSpacing.md),
            _Line(
              icon: Icons.trip_origin,
              text: offer.delivery.pickup.summary,
              // La distance a vide est mise en avant : c'est du carburant que
              // le livreur avance sans etre paye (EXI-L04).
              trailing: l10n.driverPickupDistance(
                offer.pickupDistanceKm.toStringAsFixed(1),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _Line(
              icon: Icons.place_outlined,
              text: offer.delivery.dropoff.summary,
              trailing: l10n.deliveryDistance(
                offer.delivery.distanceKm.toStringAsFixed(1),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: AppSizes.minTouchTarget,
              width: double.infinity,
              child: FilledButton(
                onPressed: expired || _busy ? null : _accept,
                child: Text(
                  expired ? l10n.driverAccept : l10n.driverAcceptIn(_remaining),
                ),
              ),
            ),
            if (!expired) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: _remaining / windowSeconds,
                minHeight: 4,
                borderRadius: AppRadii.componentAll,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, required this.trailing});

  final IconData icon;
  final String text;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          trailing,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
