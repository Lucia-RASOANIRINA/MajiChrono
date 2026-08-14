import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/i18n/locale_controller.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/l10n/app_localizations.dart';

/// Choix du profil.
///
/// Au module 1 cet ecran devient l'etape finale de l'inscription (EXI-T02) :
/// le choix client / livreur y sera fait une seule fois, et le role
/// administrateur restera attribue cote serveur. La selection alimente deja le
/// meme provider, la bascule sera donc transparente.
class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'fr', label: Text(l10n.langFrench)),
                    ButtonSegment(value: 'mg', label: Text(l10n.langMalagasy)),
                  ],
                  selected: {locale.languageCode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) => ref
                      .read(localeProvider.notifier)
                      .set(AppLocales.fromCode(selection.first)),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(l10n.appName, style: theme.textTheme.displaySmall),
              const SizedBox(height: AppSpacing.xxl),
              Text(l10n.roleChooseTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              _RoleCard(
                role: UserRole.client,
                title: l10n.roleClient,
                description: l10n.roleClientDesc,
              ),
              const SizedBox(height: AppSpacing.md),
              _RoleCard(
                role: UserRole.driver,
                title: l10n.roleDriver,
                description: l10n.roleDriverDesc,
              ),
              const SizedBox(height: AppSpacing.md),
              _RoleCard(
                role: UserRole.admin,
                title: l10n.roleAdmin,
                description: l10n.roleAdminDesc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends ConsumerWidget {
  const _RoleCard({required this.role, required this.title, required this.description});

  final UserRole role;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => ref.read(activeRoleProvider.notifier).select(role),
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Container(
                height: AppSizes.avatarMd,
                width: AppSizes.avatarMd,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadii.componentAll,
                ),
                child: Icon(role.icon, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
