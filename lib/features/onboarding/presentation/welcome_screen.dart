import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/features/onboarding/presentation/pillars_animation.dart';
import 'package:majichrono/l10n/app_localizations.dart';

/// Premier ecran de l'application.
///
/// Il tient en une promesse et quatre preuves. La promesse est la baseline ;
/// les preuves sont les quatre piliers, en rotation dans l'espace — rapidite,
/// expediteur, livreur, confiance.
///
/// Il n'y a **qu'un seul bouton**. Un ecran d'accueil qui propose « se
/// connecter », « creer un compte », « continuer sans compte » et « en savoir
/// plus » fait reflechir avant d'avoir rien montre. Ici, on avance ; le choix
/// entre connexion et inscription vient ensuite, quand il porte sur quelque
/// chose de concret.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

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
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.welcomeTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.4,
                ),
              ),

              // Le carrousel occupe le centre : c'est lui qui doit retenir
              // l'oeil, pas le bouton.
              Expanded(
                child: Center(
                  child: PillarsAnimation(
                    pillars: [
                      Pillar(
                        icon: Icons.bolt,
                        label: l10n.welcomePillarSpeed,
                        color: AppColors.accentDark,
                      ),
                      Pillar(
                        icon: Icons.inventory_2_outlined,
                        label: l10n.welcomePillarSender,
                        color: AppColors.primary,
                      ),
                      Pillar(
                        icon: Icons.two_wheeler,
                        label: l10n.welcomePillarDriver,
                        color: AppColors.info,
                      ),
                      Pillar(
                        icon: Icons.verified_outlined,
                        label: l10n.welcomePillarTrust,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: AppSizes.driverActionHeight,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.authChoice),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.welcomeStart),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.welcomeTrustNote,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
