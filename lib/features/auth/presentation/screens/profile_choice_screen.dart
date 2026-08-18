import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/error/failure.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/l10n/failure_messages.dart';
import 'package:majichrono/shared/widgets/mc_primary_action.dart';

/// Choix du profil a l'inscription (EXI-T02).
///
/// Seuls client et livreur figurent ici. Le profil exploitation est attribue
/// cote serveur ; l'ecran le dit explicitement plutot que de le taire, pour
/// qu'un responsable d'exploitation ne cherche pas un bouton qui n'existe pas.
class ProfileChoiceScreen extends ConsumerStatefulWidget {
  const ProfileChoiceScreen({super.key});

  @override
  ConsumerState<ProfileChoiceScreen> createState() =>
      _ProfileChoiceScreenState();
}

class _ProfileChoiceScreenState extends ConsumerState<ProfileChoiceScreen> {
  final TextEditingController _name = TextEditingController();
  UserRole? _role;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final role = _role;
    final l10n = AppLocalizations.of(context);

    if (role == null || _busy) return;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.authProfileNameRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .chooseProfile(role: role, displayName: _name.text.trim());
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.localizedMessage(l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authProfileTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Text(
                  l10n.authProfileSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ProfileCard(
                  role: UserRole.client,
                  title: l10n.roleClient,
                  description: l10n.roleClientDesc,
                  selected: _role == UserRole.client,
                  onTap: () => setState(() => _role = UserRole.client),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProfileCard(
                  role: UserRole.driver,
                  title: l10n.roleDriver,
                  description: l10n.roleDriverDesc,
                  selected: _role == UserRole.driver,
                  onTap: () => setState(() => _role = UserRole.driver),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.authProfileName,
                    hintText: l10n.authProfileNameHint,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.authProfileAdminNote,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _error!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          McPrimaryAction(
            label: l10n.commonConfirm,
            busy: _busy,
            onPressed: _role == null ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.role,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: selected ? theme.colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.sheetAll,
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Icon(role.icon, size: 32, color: theme.colorScheme.primary),
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
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
