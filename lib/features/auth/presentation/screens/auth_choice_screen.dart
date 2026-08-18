import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/l10n/app_localizations.dart';

/// Choix de la porte d'entree : le numero, ou une adresse e-mail.
///
/// Les deux menent au **meme compte**, et l'ecran le dit. Sans cette phrase,
/// beaucoup croient choisir entre deux comptes distincts et hesitent, ou pire,
/// en creent deux.
///
/// Le numero est presente en premier et en pleine couleur : c'est la cle du
/// compte, et le seul chemin qui fonctionne sur un telephone sans services
/// Google — la majorite du parc vise.
class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go(AppRoutes.welcome),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.authChoiceTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.authChoiceSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const Spacer(),
              _ChoiceCard(
                icon: Icons.smartphone,
                title: l10n.authChoicePhone,
                note: l10n.authChoicePhoneNote,
                filled: true,
                onTap: () => context.push(AppRoutes.authPhone),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChoiceCard(
                icon: Icons.alternate_email,
                title: l10n.authChoiceEmail,
                note: l10n.authChoiceEmailNote,
                filled: false,
                onTap: () => context.push(AppRoutes.authSignIn),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.note,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String note;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = filled ? AppColors.primary : Colors.white;

    return Material(
      color: filled ? Colors.white : Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.sheetAll,
        side: filled
            ? BorderSide.none
            : BorderSide(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.sheetAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: 28, color: foreground),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
