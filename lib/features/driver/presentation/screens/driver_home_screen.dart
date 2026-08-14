import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/network/network_profile.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/features/delivery/presentation/screens/deliveries_screen.dart';
import 'package:majichrono/features/driver/presentation/providers/driver_providers.dart';
import 'package:majichrono/features/driver/presentation/widgets/available_delivery_card.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';
import 'package:majichrono/shared/widgets/mc_skeleton.dart';

/// Accueil livreur : interrupteur de service, course en cours, file d'attente.
///
/// L'ordre suit la question que se pose un livreur quand il ouvre l'application :
/// suis-je en service, qu'ai-je a faire maintenant, et sinon qu'y a-t-il a
/// prendre.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  Timer? _refresh;

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  /// Renouvelle la file a l'expiration de la fenetre d'acceptation.
  ///
  /// Sans ce renouvellement, les propositions restaient affichees avec un
  /// bouton mort une fois le compte a rebours ecoule : le livreur se retrouvait
  /// devant un mur d'offres perimees, sans autre issue qu'un tirer-pour-
  /// rafraichir qu'il ne devine pas.
  ///
  /// La cadence suit le **profil reseau mesure**, comme le suivi client
  /// (EXI-C20) : en 2G, rafraichir toutes les 30 s couterait du forfait pour
  /// une file qui n'a pas eu le temps de changer (§4.4).
  void _scheduleRefresh({required bool online}) {
    _refresh?.cancel();
    if (!online) return;

    final profile =
        ref.read(networkStatusProvider).valueOrNull?.profile ?? NetworkProfile.threeG;
    final interval = profile.trackingRefreshInterval > _acceptanceWindow
        ? profile.trackingRefreshInterval
        : _acceptanceWindow;

    _refresh = Timer.periodic(interval, (_) {
      if (!mounted) return;
      setState(() => _cycle++);
      ref.invalidate(availableDeliveriesProvider);
    });
  }

  /// Numero du cycle de rafraichissement.
  ///
  /// Il entre dans la cle de chaque carte, et c'est indispensable : sans cle
  /// distincte, Flutter **recycle l'objet `State`** de la carte occupant la
  /// meme position dans la liste. Le compte a rebours, porte par cet etat, ne
  /// repartait donc jamais de 30 s : la file se renouvelait bien, mais tous les
  /// boutons restaient desactives. Le defaut n'etait visible qu'a l'ecran, une
  /// fois la premiere fenetre ecoulee.
  int _cycle = 0;

  static const Duration _acceptanceWindow = Duration(seconds: 30);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final online = ref.watch(driverOnlineProvider);
    final active = ref.watch(activeDriverDeliveryProvider);
    final offers = ref.watch(availableDeliveriesProvider);

    // Le minuteur suit l'etat de service : arme a la mise en ligne, desarme
    // des le passage hors service, pour ne pas interroger le serveur au repos.
    ref.listen<bool>(
      driverOnlineProvider,
      (_, next) => _scheduleRefresh(online: next),
    );
    if (online && _refresh == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scheduleRefresh(online: true),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driverHomeTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(availableDeliveriesProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const _OnlineSwitch(),
            const SizedBox(height: AppSpacing.lg),
            if (active != null) ...[
              Text(l10n.driverActiveDelivery,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: InkWell(
                  onTap: () => context.push(AppRoutes.driverActive(active.id)),
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusBadge(status: active.status),
                        const SizedBox(height: AppSpacing.sm),
                        Text(active.dropoff.summary,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(l10n.driverAvailable,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (!online)
              SizedBox(
                height: 220,
                child: Card(
                  child: McEmptyState(
                    icon: Icons.toggle_off_outlined,
                    title: l10n.driverOfflineEmpty,
                    message: l10n.driverOfflineHelp,
                  ),
                ),
              )
            else
              offers.when(
                loading: () => const McSkeletonList(itemCount: 2, nested: true),
                error: (_, _) => SizedBox(
                  height: 200,
                  child: Card(
                    child: McEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: l10n.driverNoOffers,
                      message: l10n.errorNetwork,
                    ),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? SizedBox(
                        height: 220,
                        child: Card(
                          child: McEmptyState(
                            icon: Icons.inbox_outlined,
                            title: l10n.driverNoOffers,
                            message: l10n.driverNoOffersHelp,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final offer in items) ...[
                            AvailableDeliveryCard(
                              key: ValueKey('${offer.delivery.id}_$_cycle'),
                              offer: offer,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Interrupteur en ligne / hors service (EXI-L03).
class _OnlineSwitch extends ConsumerWidget {
  const _OnlineSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final online = ref.watch(driverOnlineProvider);

    return Card(
      color: online ? AppColors.success.withValues(alpha: 0.10) : null,
      child: SwitchListTile(
        value: online,
        onChanged: (value) =>
            ref.read(driverOnlineProvider.notifier).set(online: value),
        secondary: Icon(
          online ? Icons.wifi_tethering : Icons.wifi_tethering_off,
          color: online ? AppColors.success : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          online ? l10n.driverOnline : l10n.driverOffline,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          online ? l10n.driverOnlineHelp : l10n.driverOfflineHelp,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
