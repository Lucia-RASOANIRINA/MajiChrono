import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/shared/widgets/mc_loader.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/security/device_integrity.dart';
import 'package:majichrono/core/security/secure_screen.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/features/admin/domain/entities/admin_entities.dart';
import 'package:majichrono/features/admin/presentation/providers/admin_providers.dart';
import 'package:majichrono/features/admin/presentation/widgets/reason_sheet.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';
import 'package:majichrono/shared/widgets/mc_error_view.dart';
import 'package:majichrono/shared/widgets/mc_skeleton.dart';

/// File de validation des dossiers livreurs (EXI-A03).
///
/// Le plus ancien depot en tete : servir les derniers arrives laisserait un
/// dossier attendre indefiniment, et c'est un livreur qui ne travaille pas
/// pendant ce temps.
///
/// L'etat de completude est annonce **avant** l'ouverture du dossier. Un
/// exploitant qui ouvre dix dossiers pour decouvrir que trois sont incomplets a
/// perdu dix fois le temps qu'il fallait pour le lui dire.
class KycQueueScreen extends ConsumerWidget {
  const KycQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final queue = ref.watch(kycQueueProvider);

    // EXI-SEC06 : un dossier KYC porte des pieces d'identite. Meme la liste des
    // pieces fournies designe une personne identifiable.
    return SecureScreen(
      surface: SecureSurface.kycDocuments,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.adminKycTitle)),
        body: queue.when(
          loading: () => const McSkeletonList(itemCount: 3),
          error: (error, _) => McErrorView(
            failure: error is Failure ? error : const UnknownFailure(),
            onRetry: () => ref.invalidate(kycQueueProvider),
          ),
          data: (applications) {
            if (applications.isEmpty) {
              return McEmptyState(
                icon: Icons.verified_outlined,
                title: l10n.adminKycEmpty,
                message: l10n.adminKycApproveHelp,
              );
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(kycQueueProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: applications.length,
                itemBuilder: (_, index) =>
                    _ApplicationCard(application: applications[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ApplicationCard extends ConsumerStatefulWidget {
  const _ApplicationCard({required this.application});

  final KycApplication application;

  @override
  ConsumerState<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends ConsumerState<_ApplicationCard> {
  bool _busy = false;

  Future<void> _review({required bool approve}) async {
    final l10n = AppLocalizations.of(context);

    final decision = await askForReason(
      context,
      action: approve
          ? ModerationAction.kycApprove
          : ModerationAction.kycReject,
      title: approve ? l10n.adminKycApprove : l10n.adminKycReject,
      actionLabel: approve ? l10n.adminKycApprove : l10n.adminKycReject,
      help: approve ? l10n.adminKycApproveHelp : l10n.adminKycRejectHelp,
      destructive: !approve,
    );
    if (decision == null || !mounted) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(adminActionsProvider)
          .reviewKyc(driverId: widget.application.driverId, decision: decision);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminActionDone)));
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
    final theme = Theme.of(context);
    final application = widget.application;

    final missing = application.documents.where((d) => !d.provided).length;
    final complete = application.isComplete;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    application.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (application.submittedAt != null)
                  Text(
                    l10n.adminKycSubmittedAt(_age(application.submittedAt!)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  complete ? Icons.check_circle_outline : Icons.error_outline,
                  size: 18,
                  color: complete ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                // `Expanded` : « Dossier incomplet · 2 piece(s) manquante(s) »
                // deborde de quinze pixels sur un ecran de 320 dp, et davantage
                // en malgache. Le texte doit pouvoir passer a la ligne.
                Expanded(
                  child: Text(
                    complete
                        ? l10n.adminKycComplete
                        : '${l10n.adminKycIncomplete} · '
                              '${l10n.adminKycMissingDocs(missing)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: complete ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            // Visionneuse des pieces : ce qui est fourni, ce qui manque. Les
            // images elles-memes arrivent avec la capture KYC du module 10 ; ce
            // qui compte deja ici, c'est de savoir sur quoi porte la decision.
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final document in application.documents)
                  Chip(
                    avatar: Icon(
                      document.provided
                          ? Icons.description_outlined
                          : Icons.block_outlined,
                      size: 16,
                      color: document.provided
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                    label: Text(_documentLabel(l10n, document.code)),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            if (_busy)
              const Center(child: McLoader())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _review(approve: false),
                      icon: const Icon(Icons.close),
                      label: Text(l10n.adminKycReject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      // Un dossier incomplet reste refusable, jamais
                      // approuvable : valider ce qu'on sait manquant serait
                      // pire qu'un oubli, ce serait une decision consciente.
                      onPressed: complete ? () => _review(approve: true) : null,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.adminKycApprove),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _age(DateTime at) {
    final age = DateTime.now().difference(at);
    if (age.inHours < 1) return '${age.inMinutes} min';
    if (age.inDays < 1) return '${age.inHours} h';
    return '${age.inDays} j';
  }

  String _documentLabel(AppLocalizations l10n, String code) => switch (code) {
    'cin_front' => l10n.kycDocCinFront,
    'cin_back' => l10n.kycDocCinBack,
    'licence' => l10n.kycDocLicence,
    'selfie' => l10n.kycDocSelfie,
    'registration' => l10n.kycDocRegistration,
    'vehicle' => l10n.kycDocVehicle,
    'plate' => l10n.kycDocPlate,
    _ => code,
  };
}
