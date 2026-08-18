import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/features/delivery/domain/entities/price_estimate.dart';
import 'package:majichrono/features/driver/presentation/providers/driver_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';
import 'package:majichrono/shared/widgets/mc_skeleton.dart';

/// Tableau de bord des gains (EXI-L12).
///
/// Jour, semaine, mois **et detail par course**. Le detail n'est pas un
/// supplement : c'est ce qui permet a un livreur de verifier un montant et de
/// contester precisement, plutot que de constater un ecart global sans pouvoir
/// designer la course en cause.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final earnings = ref.watch(earningsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.earningsTitle)),
      body: earnings.when(
        loading: () => const McSkeletonList(itemCount: 3),
        error: (_, _) => McEmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.earningsEmpty,
          message: l10n.errorNetwork,
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(earningsProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Card(
                child: Padding(
                  padding: AppSpacing.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.earningsToday,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        formatAriary(summary.todayAriary),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.earningsCount(summary.todayCount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _Tile(
                      label: l10n.earningsWeek,
                      amount: summary.weekAriary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _Tile(
                      label: l10n.earningsMonth,
                      amount: summary.monthAriary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.earningsCommission,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (summary.entries.isEmpty)
                SizedBox(
                  height: 200,
                  child: Card(
                    child: McEmptyState(
                      icon: Icons.payments_outlined,
                      title: l10n.earningsEmpty,
                      message: l10n.driverNoOffersHelp,
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final entry in summary.entries) ...[
                        ListTile(
                          leading: const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                          title: Text(entry.label),
                          subtitle: Text(
                            '${entry.at.hour.toString().padLeft(2, '0')}:'
                            '${entry.at.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: Text(
                            formatAriary(entry.amountAriary),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (entry != summary.entries.last)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(formatAriary(amount), style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
