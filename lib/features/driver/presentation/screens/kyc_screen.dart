import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
import 'package:majichrono/features/driver/presentation/providers/driver_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_primary_action.dart';
import 'package:majichrono/shared/widgets/mc_skeleton.dart';

/// Dossier de verification du livreur (EXI-L01, EXI-L02).
///
/// Le dossier est **bloquant** : aucune course ne peut etre executee tant qu'il
/// n'est pas valide. L'ecran le dit en tete plutot que de laisser le livreur
/// decouvrir le blocage en essayant d'accepter une course.
///
/// La prise de vue des pieces arrive au module 5, avec le reste de la chaine
/// photo — meme pipeline de capture, compression et stockage chiffre que les
/// constats. Les emplacements sont deja en place et l'etat du dossier circule.
class KycScreen extends ConsumerWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = ref.watch(kycStatusProvider);

    final documents = <(IconData, String)>[
      (Icons.badge_outlined, l10n.kycDocCinFront),
      (Icons.badge_outlined, l10n.kycDocCinBack),
      (Icons.card_membership_outlined, l10n.kycDocLicence),
      (Icons.face_outlined, l10n.kycDocSelfie),
      (Icons.description_outlined, l10n.kycDocRegistration),
      (Icons.two_wheeler_outlined, l10n.kycDocVehicle),
      (Icons.pin_outlined, l10n.kycDocPlate),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.kycTitle)),
      body: status.when(
        loading: () => const McSkeletonList(itemCount: 3),
        error: (_, _) => Center(child: Text(l10n.errorNetwork)),
        data: (raw) {
          final kyc = KycStatus.fromWire(raw) ?? KycStatus.draft;

          final (color, label) = switch (kyc) {
            KycStatus.draft => (AppColors.warning, l10n.kycStatusDraft),
            KycStatus.submitted => (AppColors.info, l10n.kycStatusSubmitted),
            KycStatus.underReview => (
              AppColors.info,
              l10n.kycStatusUnderReview,
            ),
            KycStatus.approved => (AppColors.success, l10n.kycStatusApproved),
            KycStatus.rejected => (AppColors.danger, l10n.kycStatusRejected),
          };

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Card(
                color: color.withValues(alpha: 0.10),
                child: Padding(
                  padding: AppSpacing.card,
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: color),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: theme.textTheme.titleMedium),
                            if (kyc != KycStatus.approved) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.kycBlocking,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Column(
                  children: [
                    for (final (icon, name) in documents) ...[
                      ListTile(
                        leading: Icon(icon),
                        title: Text(name),
                        trailing: const Icon(Icons.add_a_photo_outlined),
                        enabled: false,
                      ),
                      if (name != documents.last.$2) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.kycCaptureLater,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: McPrimaryAction(
        label: l10n.kycSubmit,
        icon: Icons.send_outlined,
        onPressed: null,
      ),
    );
  }
}
