import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/core/session/user_role.dart';
import 'package:majichrono/features/auth/domain/entities/auth_entities.dart';
import 'package:majichrono/features/auth/presentation/controllers/auth_state.dart';
import 'package:majichrono/features/auth/presentation/providers/auth_providers.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_loader.dart';

/// Ecran de profil, partage par l'expediteur et l'exploitation.
///
/// Les deux profils voient la meme chose : qui je suis, comment on me joint,
/// comment mon telephone est protege, et comment je pars. Ce qui differe d'un
/// role a l'autre — la note pour un livreur, le dossier KYC — est porte par les
/// ecrans du role, pas par celui-ci.
///
/// Le livreur, lui, a son propre ecran : son profil est domine par l'etat de son
/// dossier (EXI-L02), qui n'a pas d'equivalent chez les autres.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: auth.when(
        loading: () => const Center(child: McLoader()),
        error: (_, _) => Center(child: Text(l10n.errorUnknown)),
        data: (state) => switch (state) {
          AuthAuthenticated(:final account) => _Body(account: account),
          AuthLocked(:final account) => _Body(account: account),
          // Sans session, le routeur a deja renvoye ailleurs : cet etat n'est
          // atteignable qu'une image avant la redirection.
          _ => const Center(child: McLoader()),
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.account});

  final UserAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // L'adresse du compte, ou celle qui attend d'y etre rattachee — la seconde
    // n'existe qu'entre la verification de la boite mail et la confirmation du
    // numero, et il serait deroutant de ne rien montrer pendant ce temps-la.
    final linkedEmail = account.email ?? ref.watch(pendingEmailLinkProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary,
              foregroundImage: account.avatarUrl == null
                  ? null
                  : NetworkImage(account.avatarUrl!),
              child: Text(
                account.displayName.isEmpty
                    ? '?'
                    : account.displayName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName.isEmpty
                        ? l10n.navProfile
                        : account.displayName,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  // Le numero complet, pas la forme masquee : c'est **son**
                  // numero, sur **son** telephone. Le masque (EXI-T10) protege
                  // l'autre partie, pas soi-meme.
                  Text(
                    account.phone.displayNational,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (account.rating != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(account.rating!.toStringAsFixed(1)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        _Section(title: l10n.profileAccount),
        _Tile(
          icon: Icons.badge_outlined,
          title: _roleLabel(l10n, account.role),
          subtitle: l10n.profileMemberSince(_month(account.createdAt)),
        ),
        _Tile(
          icon: Icons.alternate_email,
          title: linkedEmail ?? l10n.profileEmailNone,
          subtitle: linkedEmail == null ? null : l10n.profileEmailLinked,
        ),

        const SizedBox(height: AppSpacing.lg),
        _Section(title: l10n.profileSecurity),
        FutureBuilder<bool>(
          future: ref.read(authRepositoryProvider).hasPin(),
          builder: (context, snapshot) {
            final hasPin = snapshot.data ?? false;
            return _Tile(
              icon: hasPin ? Icons.lock_outline : Icons.lock_open_outlined,
              title: hasPin ? l10n.profilePinOn : l10n.profilePinOff,
              subtitle: hasPin ? l10n.profilePinChange : l10n.profilePinSet,
              onTap: () => context.push(AppRoutes.authPin),
            );
          },
        ),
        _Tile(
          icon: Icons.settings_outlined,
          title: l10n.settingsTitle,
          onTap: () => context.push(AppRoutes.settings),
        ),

        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context, ref),
          icon: const Icon(Icons.logout),
          label: Text(l10n.authSignOut),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
            minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
          ),
        ),
      ],
    );
  }

  String _roleLabel(AppLocalizations l10n, UserRole role) => switch (role) {
    UserRole.client => l10n.roleClient,
    UserRole.driver => l10n.roleDriver,
    UserRole.admin => l10n.roleAdmin,
  };

  /// Mois et annee suffisent : le jour exact d'inscription n'apprend rien, et
  /// une date complete invite a la comparer a celle du voisin.
  String _month(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.authSignOut),
        // La deconnexion efface les donnees locales (EXI-SEC10). Sur un parcours
        // hors ligne, cela peut emporter des constats pas encore synchronises :
        // l'utilisateur doit le savoir avant, pas apres.
        content: Text(l10n.authSignOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.authSignOut),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
