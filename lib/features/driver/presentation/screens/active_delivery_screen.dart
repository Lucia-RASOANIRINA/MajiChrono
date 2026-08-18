import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/features/custody/domain/entities/custody_report.dart';
import 'package:majichrono/features/custody/presentation/screens/custody_capture_screen.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/custody/presentation/widgets/custody_proof_action.dart';
import 'package:majichrono/features/payment/presentation/screens/payment_screen.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:majichrono/features/delivery/presentation/screens/deliveries_screen.dart';
import 'package:majichrono/features/driver/domain/entities/driver_entities.dart';
import 'package:majichrono/features/driver/presentation/providers/driver_providers.dart';
import 'package:majichrono/features/driver/presentation/screens/grouped_route_screen.dart';
import 'package:majichrono/features/driver/presentation/widgets/emergency_button.dart';
import 'package:majichrono/features/driver/presentation/widgets/shopping_receipt_card.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';
import 'package:majichrono/shared/widgets/mc_primary_action.dart';

/// Execution d'une course par le livreur (EXI-L08).
///
/// Un seul bouton, pleine largeur, 64 dp, portant le libelle de **l'action
/// suivante** et rien d'autre (§15.3). C'est la contrainte la plus forte du
/// parcours livreur : trois gestes par etape au maximum (§15.2.2), avec un
/// telephone tenu d'une main, moto a l'arret, parfois sous la pluie.
class ActiveDeliveryScreen extends ConsumerStatefulWidget {
  const ActiveDeliveryScreen({required this.deliveryId, super.key});

  final String deliveryId;

  @override
  ConsumerState<ActiveDeliveryScreen> createState() =>
      _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen> {
  bool _busy = false;

  Future<void> _advance(Delivery delivery, DriverAction action) async {
    if (_busy) return;

    // EXI-CC03 : le statut ne progresse pas tant que le constat de l'etape
    // n'est pas complet. La verification passe par l'ecran de constat, qui ne
    // rend la main qu'une fois le document scelle — un retour vide signifie que
    // le livreur a renonce, et la course reste ou elle est.
    if (action.requiresCustodyReport) {
      final sealed = await Navigator.of(context).push<CustodyReport>(
        MaterialPageRoute(
          builder: (_) => CustodyCaptureScreen(
            delivery: delivery,
            stage: action == DriverAction.pickedUp
                ? CustodyStage.pickup
                : CustodyStage.handover,
          ),
        ),
      );
      if (sealed == null || !mounted) return;
    }

    setState(() => _busy = true);

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(driverActionsProvider).advance(delivery, action);
    } on ConflictFailure catch (failure) {
      // Le serveur fait foi (EXI-S04) : on affiche son etat plutot que de
      // laisser le livreur re-appuyer sur un bouton qui ne passera pas.
      messenger.showSnackBar(
        SnackBar(content: Text(failure.currentState ?? l10n.errorConflict)),
      );
    } on Failure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Delegue l'itineraire a l'application cartographique installee (EXI-L07).
  ///
  /// L'exigence est de deleguer, pas de reimplementer : un livreur connait deja
  /// son application de navigation, ses raccourcis et ses cartes hors ligne.
  Future<void> _navigate(Delivery delivery) async {
    final target =
        delivery.status == DeliveryStatus.accepted ||
            delivery.status == DeliveryStatus.atPickup
        ? delivery.pickup.point
        : delivery.dropoff.point;

    final uri = Uri.parse(
      'geo:${target.latitude},${target.longitude}'
      '?q=${target.latitude},${target.longitude}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final deliveries = ref.watch(deliveriesProvider).valueOrNull;
    final delivery = deliveries
        ?.where((d) => d.id == widget.deliveryId)
        .firstOrNull;

    if (delivery == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.driverActiveDelivery)),
        body: McEmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.emptyDeliveries,
          message: l10n.errorUnknown,
        ),
      );
    }

    final action = DriverAction.nextFor(delivery.status);

    String label(DriverAction a) => switch (a) {
      DriverAction.arrivedAtPickup => l10n.driverStepArrivedPickup,
      DriverAction.pickedUp => l10n.driverStepPickedUp,
      DriverAction.arrivedAtDestination => l10n.driverStepArrivedDestination,
      DriverAction.delivered => l10n.driverStepDelivered,
    };

    final target =
        delivery.status == DeliveryStatus.accepted ||
            delivery.status == DeliveryStatus.atPickup
        ? delivery.pickup
        : delivery.dropoff;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driverActiveDelivery),
        actions: [
          // L'encaissement n'apparait qu'une fois le colis remis : proposer de
          // se faire payer avant d'avoir livre inverserait l'ordre des choses
          // et exposerait le client.
          if (delivery.paymentMethod == PaymentMethod.majipay &&
              (delivery.status == DeliveryStatus.delivered ||
                  delivery.status == DeliveryStatus.deliveredWithReserves))
            IconButton(
              icon: const Icon(Icons.qr_code_2),
              tooltip: l10n.payCollect,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      PaymentScreen(delivery: delivery, role: UserRole.driver),
                ),
              ),
            ),
          // Le parcours groupe n'apparait que lorsqu'il y a un groupe : un
          // bouton qui mene a une liste d'une seule course serait un detour.
          if (ref.watch(activeGroupProvider) != null)
            IconButton(
              icon: const Icon(Icons.route_outlined),
              tooltip: l10n.groupTitle,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      GroupedRouteScreen(group: ref.read(activeGroupProvider)!),
                ),
              ),
            ),
          // Le livreur relit ses propres constats : c'est ce qui lui permet de
          // contester une reclamation avec la preuve qu'il a lui-meme etablie.
          CustodyProofAction(delivery: delivery),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(status: delivery.status),
                  const SizedBox(height: AppSpacing.md),
                  // L'adresse affichee est celle de l'etape en cours, et non les
                  // deux : le livreur n'a besoin que de sa destination immediate.
                  Text(target.landmark, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    target.district,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _navigate(delivery),
                          icon: const Icon(Icons.navigation_outlined),
                          label: Text(l10n.driverNavigate),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.outlined(
                        onPressed: () {},
                        icon: const Icon(Icons.phone_outlined),
                        tooltip: l10n.driverCall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (action?.requiresCustodyReport ?? false)
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: AppSpacing.card,
                child: Row(
                  children: [
                    const Icon(Icons.fact_check_outlined),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        // EXI-CC03 : le statut ne progressera pas sans constat.
                        // On l'annonce avant, pour que l'etape ne surprenne pas
                        // le livreur au moment ou il tient le colis.
                        l10n.driverCustodyRequired,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // EXI-C07 : la liste et le plafond restent sous les yeux du livreur
          // pendant toute la course, pas seulement a l'acceptation.
          if (delivery.kind == DeliveryKind.shopping) ...[
            const SizedBox(height: AppSpacing.lg),
            ShoppingReceiptCard(delivery: delivery),
          ],
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => _showIncidentSheet(context, delivery),
            icon: const Icon(Icons.report_problem_outlined),
            label: Text(l10n.driverIncident),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning),
          ),
          const SizedBox(height: AppSpacing.md),
          // EXI-L13, D10. Volontairement **sous** le signalement d'incident et
          // visuellement distinct : ce sont deux gestes differents. Un incident
          // se motive et se met en file ; une urgence part tout de suite. Les
          // confondre ferait porter a l'une la prudence de l'autre.
          EmergencyButton(deliveryId: delivery.id),
        ],
      ),
      bottomNavigationBar: action == null
          ? null
          : McPrimaryAction.driver(
              label: label(action),
              busy: _busy,
              icon: Icons.check_circle_outline,
              onPressed: () => _advance(delivery, action),
            ),
    );
  }

  /// Signalement d'incident (EXI-L14).
  ///
  /// Chaque motif affiche **sa consequence** : l'exigence demande que la suite
  /// soit definie, et un livreur planté devant un portail a besoin de savoir ce
  /// qui se passe ensuite, pas seulement d'avoir coche une case.
  void _showIncidentSheet(BuildContext context, Delivery delivery) {
    final l10n = AppLocalizations.of(context);

    String title(IncidentType type) => switch (type) {
      IncidentType.recipientAbsent => l10n.incidentRecipientAbsent,
      IncidentType.addressNotFound => l10n.incidentAddressNotFound,
      IncidentType.refusedByRecipient => l10n.incidentRefused,
      IncidentType.vehicleBreakdown => l10n.incidentBreakdown,
    };

    String outcome(IncidentOutcome o) => switch (o) {
      IncidentOutcome.waitThenReturn => l10n.outcomeWaitThenReturn,
      IncidentOutcome.contactSupport => l10n.outcomeContactSupport,
      IncidentOutcome.returnToSender => l10n.outcomeReturnToSender,
      IncidentOutcome.reassign => l10n.outcomeReassign,
    };

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              l10n.driverIncident,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final type in IncidentType.values)
              ListTile(
                leading: const Icon(Icons.report_problem_outlined),
                title: Text(title(type)),
                subtitle: Text(outcome(type.outcome)),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
          ],
        ),
      ),
    );
  }
}
