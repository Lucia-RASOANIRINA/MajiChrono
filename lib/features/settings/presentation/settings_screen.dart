import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/i18n/locale_controller.dart';
import 'package:majichrono/core/providers/core_providers.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';

/// Reglages : langue (EXI-T05), apparence, consommation (EXI-T07), verrou et
/// deconnexion (EXI-T04, EXI-SEC10).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.authSignOut),
        content: Text(l10n.authSignOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          // Bascule a chaud : aucun redemarrage, l'ecran se retraduit sous les
          // doigts de l'utilisateur (EXI-T05).
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'fr',
                label: Text(l10n.langFrench),
                icon: const Icon(Icons.translate),
              ),
              ButtonSegment(
                value: 'mg',
                label: Text(l10n.langMalagasy),
                icon: const Icon(Icons.translate),
              ),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (selection) => ref
                .read(localeProvider.notifier)
                .set(AppLocales.fromCode(selection.first)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.settingsTheme, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
            ],
            selected: {themeMode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                ref.read(themeModeProvider.notifier).set(selection.first),
          ),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.data_usage_outlined),
                  title: Text(l10n.dataUsageTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.dataUsage),
                ),
                if (config.enableDevPanel) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: Text(l10n.devPanelTitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.devPanel),
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.authPinTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.authPin),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    l10n.authSignOut,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  // Action destructrice : confirmee, et l'utilisateur est
                  // prevenu de ce qu'elle efface (§15.2.6, EXI-SEC10).
                  onTap: () => _confirmSignOut(context, ref, l10n),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
