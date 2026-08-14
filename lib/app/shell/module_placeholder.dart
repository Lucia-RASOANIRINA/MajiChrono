import 'package:flutter/material.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_empty_state.dart';

/// Ecran d'attente d'un module non encore livre.
///
/// Il existe pour que la coquille du module 0 soit **reellement navigable** :
/// chaque destination mene a un ecran qui annonce ce qu'il deviendra et a quel
/// module, plutot qu'a une page blanche. Il disparait module par module.
class ModulePlaceholderScreen extends StatelessWidget {
  const ModulePlaceholderScreen({
    required this.title,
    required this.module,
    required this.icon,
    this.requirements = const [],
    super.key,
  });

  final String title;
  final String module;
  final IconData icon;

  /// References du cahier des charges couvertes par ce futur ecran.
  final List<String> requirements;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: McEmptyState(
              icon: icon,
              title: l10n.shellModuleWip,
              message: l10n.shellModuleWipDesc(module),
            ),
          ),
          if (requirements.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final requirement in requirements)
                    Chip(
                      label: Text(requirement),
                      visualDensity: VisualDensity.compact,
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
