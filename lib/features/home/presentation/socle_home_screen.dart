import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/network/data_meter.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';

/// Accueil du module 0.
///
/// Cet ecran est le livrable verifiable du socle : il rend visible ce que le
/// module 0 apporte — sonde reseau reelle, compteur de donnees, langue a chaud,
/// base locale ouverte — avant que les modules metier ne le remplacent par le
/// vrai accueil de chaque profil.
class SocleHomeScreen extends ConsumerWidget {
  const SocleHomeScreen({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final status = ref.watch(networkStatusProvider);
    final meter = ref.watch(dataMeterProvider);
    final pending = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;

    final title = switch (role) {
      UserRole.client => l10n.clientHomeTitle,
      UserRole.driver => l10n.driverHomeTitle,
      UserRole.admin => l10n.adminHomeTitle,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (config.enableDevPanel)
            IconButton(
              tooltip: l10n.devPanelTitle,
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => context.push(AppRoutes.devPanel),
            ),
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionTitle(title: l10n.networkOnline),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: AppSpacing.card,
              child: status.when(
                loading: () => Row(
                  children: [
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(l10n.commonLoading),
                  ],
                ),
                error: (_, _) => Text(l10n.errorNetwork),
                data: (value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _KeyValueRow(
                      icon: value.isOnline
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                      label: l10n.socleProbe,
                      value: value.isOnline
                          ? '${value.profile.label} · ${value.rttMs} ms'
                          : l10n.networkOfflineNoPending,
                      color: value.isOnline ? AppColors.success : AppColors.offline,
                    ),
                    const Divider(height: AppSpacing.xl),
                    _KeyValueRow(
                      icon: Icons.sync_outlined,
                      label: l10n.socleSyncQueue,
                      value: '$pending',
                    ),
                    const Divider(height: AppSpacing.xl),
                    _KeyValueRow(
                      icon: Icons.api_outlined,
                      label: l10n.devApiMode,
                      value: config.apiMode.name,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(title: l10n.dataUsageTitle),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListenableBuilder(
              listenable: meter,
              builder: (context, _) => ListTile(
                leading: const Icon(Icons.data_usage_outlined),
                title: Text(l10n.dataUsageThisMonth),
                subtitle: Text(DataMeter.format(meter.total)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.dataUsage),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(title: l10n.navDeliveries),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 260,
            child: Card(
              child: McEmptyState(
                icon: Icons.inventory_2_outlined,
                title: l10n.emptyDeliveries,
                message: l10n.shellModuleWipDesc(role == UserRole.driver ? '4' : '2'),
                actionLabel: role == UserRole.client ? l10n.emptyDeliveriesAction : null,
                onAction: role == UserRole.client
                    ? () => context.push(AppRoutes.clientNewDelivery)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleMedium);
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
