import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      body: DecoratedBox(
        // Meme degrade que l'accueil : les deux ecrans se suivent, et un
        // changement de fond entre eux se lirait comme un changement
        // d'application.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A3894), AppColors.primary, Color(0xFF151E5E)],
          ),
        ),
        child: SafeArea(
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
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scaleXY(begin: 0.94, curve: Curves.easeOutCubic),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l10n.authChoiceTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.15),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.authChoiceSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const Spacer(),

                // Les deux cartes arrivent l'une apres l'autre, decalees de
                // quatre-vingts millisecondes. Ce decalage n'est pas decoratif :
                // il fait lire les options **dans l'ordre**, le numero d'abord,
                // ce qui est precisement la recommandation de l'ecran.
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
                      onTap: () => context.push(AppRoutes.authSignIn),
                    )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 320.ms)
                    .slideY(begin: 0.12, curve: Curves.easeOutCubic),
                const Spacer(),
                // « Un compte, deux voies » : les deux portes convergent vers la
                // meme identite. La phrase du haut le dit ; ce dessin le montre,
                // et c'est ce qui empeche de croire qu'on choisit entre deux
                // comptes distincts.
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
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Les deux faisceaux, dessines derriere les icones.
              Positioned.fill(
                child: CustomPaint(painter: const _ConvergePainter()),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.smartphone, size: 34, color: Colors.white70),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.mail_outline,
                  size: 34,
                  color: Colors.white70,
                ),
              ),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.appName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
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

/// Deux arcs qui montent des bords vers le centre.
class _ConvergePainter extends CustomPainter {
  const _ConvergePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);

    for (final side in [-1.0, 1.0]) {
      final from = Offset(centre.dx + side * size.width * 0.42, centre.dy);
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(
          centre.dx + side * size.width * 0.24,
          centre.dy + size.height * 0.34,
          centre.dx,
          centre.dy,
        );

      // Deux passes, comme le trace de l'accueil : un halo puis le trait net.
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primaryLight.withValues(alpha: 0.16),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primaryLight.withValues(alpha: 0.75),
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
