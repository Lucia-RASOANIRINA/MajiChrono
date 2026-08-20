import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:majichrono/app/router/app_routes.dart';
import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';
import 'package:majichrono/l10n/app_localizations.dart';
import 'package:majichrono/shared/widgets/mc_patterns.dart';
import 'package:majichrono/shared/widgets/mc_stopwatch_icon.dart';

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
      body: Stack(
        children: [
          // Fond degrade technique
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2A3894),
                    AppColors.primary,
                    Color(0xFF151E5E),
                  ],
                ),
              ),
            ),
          ),
          // Motif technique en filigrane
          Positioned.fill(
            child: CustomPaint(
              painter: TechPatternPainter(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              // Les `Spacer` repartissent le contenu quand il y a de la place ;
              // mais sur un ecran court (petit telephone, clavier, gros zoom
              // systeme), la meme colonne deborderait. On la rend donc
              // defilable : elle occupe au moins toute la hauteur — d'ou les
              // `Spacer` qui gardent leur effet — et se met a defiler des qu'elle
              // ne tient plus.
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => context.go(AppRoutes.welcome),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // En-tete avec chronometre
                          SizedBox(
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const McStopwatchIcon(size: 180, opacity: 0.08),
                                Text(
                                      l10n.appName,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .scaleXY(
                                      begin: 0.94,
                                      curve: Curves.easeOutCubic,
                                    ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                                l10n.authChoiceTitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: -0.15),
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
                              )
                              .animate()
                              .fadeIn(duration: 320.ms)
                              .slideY(begin: 0.12, curve: Curves.easeOutCubic),
                          const SizedBox(height: AppSpacing.lg),
                          _ChoiceCard(
                                icon: Icons.alternate_email,
                                title: l10n.authChoiceEmail,
                                note: l10n.authChoiceEmailNote,
                                filled: false,
                                backgroundPattern: EnvelopePatternPainter(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                onTap: () => context.push(AppRoutes.authSignIn),
                              )
                              .animate(delay: 80.ms)
                              .fadeIn(duration: 320.ms)
                              .slideY(begin: 0.12, curve: Curves.easeOutCubic),
                          const Spacer(),
                          const _TwoRoads()
                              .animate(delay: 220.ms)
                              .fadeIn(duration: 500.ms)
                              .scaleXY(begin: 0.92, curve: Curves.easeOutBack),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Le telephone et l'enveloppe, relies a une meme marque centrale.
class _TwoRoads extends StatelessWidget {
  const _TwoRoads();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Les deux faisceaux convergent vers le bas
              Positioned.fill(
                child: CustomPaint(painter: const _ConvergePainter()),
              ),
              // Point de convergence lumineux
              Align(
                alignment: const Alignment(0, 0.8),
                child: Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment(-0.6, -0.4),
                child: Icon(Icons.smartphone, size: 48, color: Colors.white70),
              ),
              const Align(
                alignment: Alignment(0.6, -0.4),
                child: Icon(
                  Icons.mail_outline,
                  size: 48,
                  color: Colors.white70,
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const McStopwatchIcon(size: 40, opacity: 0.4),
                    const SizedBox(height: 4),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authChoiceOneAccount,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Deux arcs qui descendent des bords vers le centre bas.
class _ConvergePainter extends CustomPainter {
  const _ConvergePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final target = Offset(size.width / 2, size.height * 0.8);

    for (final side in [-1.0, 1.0]) {
      final from = Offset(size.width / 2 + side * size.width * 0.3, 20);
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(
          size.width / 2 + side * size.width * 0.25,
          size.height * 0.4,
          target.dx,
          target.dy,
        );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.1),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primaryLight.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_ConvergePainter oldDelegate) => false;
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.note,
    required this.filled,
    required this.onTap,
    this.backgroundPattern,
  });

  final IconData icon;
  final String title;
  final String note;
  final bool filled;
  final VoidCallback onTap;
  final CustomPainter? backgroundPattern;

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
        child: ClipRRect(
          borderRadius: AppRadii.sheetAll,
          child: Stack(
            children: [
              if (backgroundPattern != null)
                Positioned.fill(child: CustomPaint(painter: backgroundPattern)),
              Padding(
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
            ],
          ),
        ),
      ),
    );
  }
}
