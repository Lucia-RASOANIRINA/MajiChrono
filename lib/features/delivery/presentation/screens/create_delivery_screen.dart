import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/features/delivery/domain/entities/address.dart';
import 'package:majichrono/features/delivery/domain/entities/delivery.dart';
import 'package:majichrono/features/delivery/domain/entities/price_estimate.dart';
import 'package:majichrono/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:majichrono/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:majichrono/features/delivery/presentation/widgets/address_form.dart';
import 'package:majichrono/features/delivery/presentation/widgets/price_breakdown.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';
import 'package:majichrono/shared/widgets/mc_primary_action.dart';

/// Assistant de creation de course.
///
/// Trois etapes, et une seule action principale par ecran (§15.2.1). Le
/// decoupage suit l'ordre dans lequel l'expediteur pense sa course : d'ou a ou,
/// puis quoi, puis combien — et le prix n'apparait qu'a la fin, ventile, avant
/// confirmation (EXI-C10).
class CreateDeliveryScreen extends ConsumerStatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  ConsumerState<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends ConsumerState<CreateDeliveryScreen> {
  int _step = 0;

  Address? _pickup;
  Address? _dropoff;
  DeliveryKind _kind = DeliveryKind.standard;
  WeightCategory _weight = WeightCategory.upTo2;
  PickupSlot _slot = const PickupSlot.immediate();
  PaymentMethod _payment = PaymentMethod.cash;
  final TextEditingController _value = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _value.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_step) {
        0 => _pickup != null && _dropoff != null,
        1 => true,
        _ => true,
      };

  PriceEstimate get _estimate => ref.read(tariffGridProvider).estimate(
        straightLineKm: _pickup!.point.distanceKmTo(_dropoff!.point),
        kind: _kind,
        weight: _weight,
        slot: _slot,
        insuredValueAriary: int.tryParse(_value.text.replaceAll(' ', '')),
      );

  Future<void> _submit() async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final delivery =
          await ref.read(deliveryRepositoryProvider).createDelivery(
                DeliveryDraft(
                  pickup: _pickup!,
                  dropoff: _dropoff!,
                  kind: _kind,
                  package: PackageDeclaration(
                    weight: _weight,
                    declaredValueAriary:
                        int.tryParse(_value.text.replaceAll(' ', '')),
                    description: _description.text.trim().isEmpty
                        ? null
                        : _description.text.trim(),
                  ),
                  slot: _slot,
                  paymentMethod: _payment,
                ),
              );

      messenger.showSnackBar(
        SnackBar(
          // Le message distingue les deux cas : une course transmise et une
          // course en attente ne sont pas la meme chose pour l'utilisateur
          // (EXI-C13). Annoncer « creee » alors que rien n'est parti serait
          // exactement le mensonge que le mode hors ligne doit eviter.
          content: Text(
            delivery.pendingSync ? l10n.deliveryQueued : l10n.deliveryCreated,
          ),
        ),
      );
      router.pop();
    } on Failure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final titles = [l10n.stepAddresses, l10n.stepPackage, l10n.stepReview];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newDeliveryTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / 3, minHeight: 4),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                for (var i = 0; i < titles.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StepChip(label: titles[i], active: i <= _step),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: _buildStep(l10n)),
          McPrimaryAction(
            label: _step == 2 ? l10n.confirmDelivery : l10n.commonContinue,
            busy: _busy,
            onPressed: !_canContinue
                ? null
                : () {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      _submit();
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildStep(AppLocalizations l10n) => switch (_step) {
        0 => _AddressStep(
            pickup: _pickup,
            dropoff: _dropoff,
            onPickup: (a) => setState(() => _pickup = a),
            onDropoff: (a) => setState(() => _dropoff = a),
          ),
        1 => _PackageStep(
            kind: _kind,
            weight: _weight,
            slot: _slot,
            payment: _payment,
            value: _value,
            description: _description,
            onKind: (k) => setState(() => _kind = k),
            onWeight: (w) => setState(() => _weight = w),
            onSlot: (s) => setState(() => _slot = s),
            onPayment: (p) => setState(() => _payment = p),
          ),
        _ => _ReviewStep(
            pickup: _pickup!,
            dropoff: _dropoff!,
            kind: _kind,
            weight: _weight,
            slot: _slot,
            payment: _payment,
            estimate: _estimate,
          ),
      };
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: active ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: AppRadii.componentAll,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

// --- Etape 1 : adresses -------------------------------------------------

class _AddressStep extends ConsumerWidget {
  const _AddressStep({
    required this.pickup,
    required this.dropoff,
    required this.onPickup,
    required this.onDropoff,
  });

  final Address? pickup;
  final Address? dropoff;
  final ValueChanged<Address?> onPickup;
  final ValueChanged<Address?> onDropoff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        _SectionHeader(title: l10n.addrPickupTitle, icon: Icons.trip_origin),
        const SizedBox(height: AppSpacing.md),
        AddressForm(initial: pickup, onChanged: onPickup),
        const SizedBox(height: AppSpacing.xxl),
        _SectionHeader(title: l10n.addrDropoffTitle, icon: Icons.place_outlined),
        const SizedBox(height: AppSpacing.md),
        AddressForm(initial: dropoff, onChanged: onDropoff),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

// --- Etape 2 : colis, creneau, paiement ----------------------------------

class _PackageStep extends StatelessWidget {
  const _PackageStep({
    required this.kind,
    required this.weight,
    required this.slot,
    required this.payment,
    required this.value,
    required this.description,
    required this.onKind,
    required this.onWeight,
    required this.onSlot,
    required this.onPayment,
  });

  final DeliveryKind kind;
  final WeightCategory weight;
  final PickupSlot slot;
  final PaymentMethod payment;
  final TextEditingController value;
  final TextEditingController description;
  final ValueChanged<DeliveryKind> onKind;
  final ValueChanged<WeightCategory> onWeight;
  final ValueChanged<PickupSlot> onSlot;
  final ValueChanged<PaymentMethod> onPayment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String kindLabel(DeliveryKind k) => switch (k) {
          DeliveryKind.standard => l10n.kindStandard,
          DeliveryKind.document => l10n.kindDocument,
          DeliveryKind.fragile => l10n.kindFragile,
          DeliveryKind.food => l10n.kindFood,
          DeliveryKind.shopping => l10n.kindShopping,
        };

    String weightLabel(WeightCategory w) => switch (w) {
          WeightCategory.upTo2 => l10n.pkgWeightLt2,
          WeightCategory.from2to5 => l10n.pkgWeight2to5,
          WeightCategory.from5to15 => l10n.pkgWeight5to15,
          WeightCategory.over15 => l10n.pkgWeightGt15,
        };

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        Text(l10n.kindTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final k in DeliveryKind.values)
              ChoiceChip(
                label: Text(kindLabel(k)),
                selected: kind == k,
                // L'achat pour compte arrive au module 9 : la puce reste
                // visible mais desactivee, plutot que masquee. L'utilisateur
                // voit que la fonction existe et viendra.
                onSelected: k == DeliveryKind.shopping
                    ? null
                    : (_) => onKind(k),
              ),
          ],
        ),
        if (kind == DeliveryKind.shopping)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              l10n.kindShoppingSoon,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.pkgWeight, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Column(
          children: [
            for (final w in WeightCategory.values)
              RadioListTileTile(
                label: weightLabel(w),
                selected: weight == w,
                onTap: () => onWeight(w),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: value,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${l10n.pkgValue} (${l10n.addrOptional})',
            prefixIcon: const Icon(Icons.payments_outlined),
            suffixText: 'Ar',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: description,
          decoration: InputDecoration(
            labelText: '${l10n.pkgDescription} (${l10n.addrOptional})',
            prefixIcon: const Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.pkgPhotoLater,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.slotTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text(l10n.slotImmediate)),
            ButtonSegment(value: false, label: Text(l10n.slotScheduled)),
          ],
          selected: {slot.isImmediate},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onSlot(
            selection.first
                ? const PickupSlot.immediate()
                : PickupSlot.scheduled(
                    date: DateTime.now().add(const Duration(days: 1)),
                    hour: 8,
                  ),
          ),
        ),
        if (!slot.isImmediate) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final hour in const [6, 8, 10, 12, 14, 16])
                ChoiceChip(
                  label: Text(l10n.slotRange(hour, hour + 2)),
                  selected: slot.startHour == hour,
                  onSelected: (_) => onSlot(
                    PickupSlot.scheduled(
                      date: slot.scheduledDate ??
                          DateTime.now().add(const Duration(days: 1)),
                      hour: hour,
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.paymentTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        // L'espece est le premier choix et le defaut : c'est la norme de
        // confiance a Madagascar (§4.2), pas un mode degrade.
        RadioListTileTile(
          label: l10n.paymentCash,
          selected: payment == PaymentMethod.cash,
          onTap: () => onPayment(PaymentMethod.cash),
        ),
        RadioListTileTile(
          label: l10n.paymentMajipay,
          subtitle: l10n.paymentMajipaySoon,
          selected: false,
          onTap: null,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Ligne a selection unique, sans `RadioListTile` (deprecie dans Flutter 3.44).
class RadioListTileTile extends StatelessWidget {
  const RadioListTileTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      enabled: onTap != null,
      onTap: onTap,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? scheme.primary : null,
      ),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      contentPadding: EdgeInsets.zero,
    );
  }
}

// --- Etape 3 : recapitulatif et prix -------------------------------------

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.pickup,
    required this.dropoff,
    required this.kind,
    required this.weight,
    required this.slot,
    required this.payment,
    required this.estimate,
  });

  final Address pickup;
  final Address dropoff;
  final DeliveryKind kind;
  final WeightCategory weight;
  final PickupSlot slot;
  final PaymentMethod payment;
  final PriceEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.trip_origin),
                title: Text(pickup.summary),
                subtitle: Text(pickup.contactPhone.displayNational),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(dropoff.summary),
                subtitle: Text(dropoff.contactPhone.displayNational),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.estimateTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        PriceBreakdown(estimate: estimate),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
