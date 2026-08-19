import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/features/onboarding/presentation/pillars_animation.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_brand_mark.dart';

/// Premier ecran de l'application.
///
/// Trois choses, et rien d'autre : le nom, la promesse, et les quatre elements
/// qui tournent sur les deux mains. C'est la maquette a la lettre — pas de
/// bouton, pas de mention de bas de page.
///
/// Un ecran sans bouton doit quand meme laisser passer. Deux issues y pourvoient
/// sans rien ajouter au dessin : **l'ecran entier est touchable**, et la suite
/// s'ouvre d'elle-meme apres un tour complet. Celui qui touche n'attend pas ;
/// celui qui regarde n'est pas bloque.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  /// Duree d'un tour complet des quatre elements, plus une respiration. Assez
  /// long pour avoir lu les quatre mots, assez court pour ne pas retenir
  /// quelqu'un qui veut commander tout de suite.
  static const Duration _dwell = Duration(seconds: 10);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Un `Timer` retenu, et non un `Future.delayed` oublie : sans annulation,
    // il survit a l'ecran, ramene ici quelqu'un parti s'inscrire, et fait
    // echouer tout test de widget qui traverse cet ecran.
    _timer = Timer(_dwell, () {
      if (!mounted) return;
      if (GoRouterState.of(context).matchedLocation != AppRoutes.welcome) {
        return;
      }
      _continue();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue() {
    _timer?.cancel();
    context.go(AppRoutes.authChoice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: DecoratedBox(
        // Degrade radial plutot qu'un aplat : le fond s'eclaircit legerement
        // derriere le schema, ce qui pose l'oeil au centre sans ajouter le
        // moindre element. Les deux teintes sont celles de la charte ; l'ecart
        // reste faible pour que le bleu de la maquette demeure reconnaissable.
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0.18),
            radius: 0.95,
            colors: [Color(0xFF2A3894), AppColors.primary],
          ),
        ),
        child: GestureDetector(
          onTap: _continue,
          // Sans couleur, la zone transparente ne recoit pas les touchers.
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  // Marge fixe et non un ressort : le titre doit se poser haut,
                  // comme sur la maquette. Un `Spacer` en tete repoussait tout le
                  // bloc vers le bas et laissait un vide que rien n'occupait —
                  // celui ou vivait autrefois le logo.
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Le pays, en petit, sous le nom. Il dit d'ou vient
                  // l'application sans une ligne de texte de plus — et sur un
                  // marche ou la confiance se joue sur l'ancrage local, c'est
                  // une information qui vaut d'etre montree en premier.
                  const MadagascarMark(height: 34),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.welcomeTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // `Expanded` et non une taille libre : sur un ecran court — 320
                  // dp de haut sur le parc d'entree de gamme — le schema doit se
                  // reduire plutot que deborder. Aligne en haut, il reste sous la
                  // promesse au lieu de flotter au milieu du vide.
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: PillarsAnimation(
                        pillars: [
                          Pillar(
                            icon: Icons.two_wheeler,
                            label: l10n.welcomePillarSpeed,
                            color: AppColors.primaryLight,
                          ),
                          Pillar(
                            icon: Icons.outbox,
                            label: l10n.welcomePillarSender,
                            color: AppColors.primary,
                          ),
                          Pillar(
                            icon: Icons.delivery_dining,
                            label: l10n.welcomePillarDriver,
                            color: AppColors.primaryLight,
                          ),
                          Pillar(
                            icon: Icons.handshake,
                            label: l10n.welcomePillarTrust,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Le bas de l'ecran restait vide, et ce vide se lisait comme
                  // un ecran inacheve. Un scooter le traverse en boucle, sur
                  // une route pointillee.
                  const McScooterStrip(),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
