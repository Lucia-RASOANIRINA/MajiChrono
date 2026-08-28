import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:majichrono/app/theme/app_colors.dart';
import 'package:majichrono/app/theme/design_tokens.dart';

/// Chargement de marque : une moto qui file le long d'une barre de progression.
///
/// L'icone moto tient lieu de logo — c'est elle qui avance, et la barre se
/// remplit derriere son passage. Le mouvement dit « ca travaille » sans le mot,
/// et reste dans l'univers du service : une livraison, c'est une moto qui roule.
///
/// L'animation est retiree quand le systeme demande la suppression des effets
/// (EXI-T09) : elle laisse alors une barre a demi remplie, moto posee dessus.
class McMotoLoader extends StatefulWidget {
  const McMotoLoader({
    this.width = 200,
    this.color = Colors.white,
    this.icon = Icons.two_wheeler,
    super.key,
  });

  final double width;

  /// Couleur de la moto et du remplissage. Le fond de piste en est une version
  /// attenuee. Blanc par defaut, pour poser sur le bleu de la charte.
  final Color color;
  final IconData icon;

  @override
  State<McMotoLoader> createState() => _McMotoLoaderState();
}

class _McMotoLoaderState extends State<McMotoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    // Un peu plus d'une seconde par traversee : assez lent pour lire le geste,
    // assez vif pour ne pas donner l'impression d'un blocage.
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    const trackHeight = 6.0;
    const iconSize = 30.0;

    if (reduceMotion) {
      return _frame(0.6, trackHeight, iconSize);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Depart doux, arrivee douce : la moto accelere puis se pose au bout,
        // au lieu de filer a vitesse constante et de se teleporter au retour.
        final t = Curves.easeInOut.transform(_controller.value);
        return _frame(t, trackHeight, iconSize);
      },
    );
  }

  Widget _frame(double t, double trackHeight, double iconSize) {
    final w = widget.width;
    // La moto va de son bord gauche colle a 0 jusqu'a son bord droit colle a w :
    // elle ne deborde jamais de la piste.
    final iconLeft = t * (w - iconSize);
    final fillWidth = (iconLeft + iconSize / 2).clamp(0.0, w);

    return SizedBox(
      width: w,
      height: iconSize + trackHeight + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Piste
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: trackHeight,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(trackHeight),
              ),
            ),
          ),
          // Remplissage, jusqu'a la moto
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: fillWidth,
              height: trackHeight,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(trackHeight),
              ),
            ),
          ),
          // La moto, posee sur la barre a la tete du remplissage
          Positioned(
            left: iconLeft,
            bottom: trackHeight - 2,
            child: Icon(widget.icon, size: iconSize, color: widget.color),
          ),
        ],
      ),
    );
  }
}

/// Ecran de chargement complet aux couleurs de la marque : l'illustration du
/// livreur — **la meme** que l'ecran de demarrage natif d'Android 12
/// (`assets/brand/logo_rider.png` == `res/drawable/splash_logo.png`, sur le meme
/// bleu `#1E2A78`) — accompagnee d'un petit indicateur de chargement.
///
/// Le livreur est cale **exactement au centre**, a la meme place et a la meme
/// taille que l'icone du splash natif. Le passage du splash natif a cet ecran
/// est donc invisible : rien ne bouge, ce n'est pas un second ecran — c'est le
/// meme, ou les points de chargement viennent simplement apparaitre en dessous.
/// On evite ainsi le doublon « livreur puis livreur+points ».
///
/// Ce signe de vie manquait au premier lancement et au reveil du serveur (plan
/// gratuit Render, ~30-50 s), ou l'ecran restait fige sans retour.
class McMotoLoadingView extends StatelessWidget {
  const McMotoLoadingView({super.key});

  /// Cote de la vignette du livreur — cale sur la taille de l'icone du splash
  /// natif (livreur visible ~510 px @3x) pour que la transition ne fasse aucun
  /// saut, ni de position ni de taille. Mesure verifiee a l'ecran.
  static const double _riderSize = 286;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      // Le livreur reste dead-center (comme le splash natif) ; les points
      // debordent sous sa vignette sans jamais le decaler.
      body: Center(
        child: SizedBox.square(
          dimension: _riderSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/brand/logo_rider.png',
                width: _riderSize,
                filterQuality: FilterQuality.medium,
              ),
              const Positioned(
                bottom: -AppSpacing.lg,
                left: 0,
                right: 0,
                child: Align(child: _SplashLoadingDots()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trois points blancs qui pulsent en cascade, de gauche a droite — un « ca
/// charge » discret, dans la veine des lignes de vitesse du livreur.
///
/// Retire quand le systeme demande la suppression des animations (EXI-T09) :
/// trois points a demi-opacite le remplacent alors.
class _SplashLoadingDots extends StatefulWidget {
  const _SplashLoadingDots();

  @override
  State<_SplashLoadingDots> createState() => _SplashLoadingDotsState();
}

class _SplashLoadingDotsState extends State<_SplashLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  static const int _count = 3;
  static const double _dotSize = 8;
  static const double _gap = 6;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduceMotion) {
      return _row(List.filled(_count, 0.55));
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacities = <double>[
          for (var i = 0; i < _count; i++)
            // Chaque point est decale d'un tiers de cycle : la vague court de
            // gauche a droite. Cloche cosinus : plein au passage, attenue
            // autour, sans a-coup au bouclage.
            0.3 +
                0.7 *
                    (0.5 +
                        0.5 *
                            math.cos(
                              2 *
                                  math.pi *
                                  ((_controller.value - i / _count) % 1.0),
                            )),
        ];
        return _row(opacities);
      },
    );
  }

  Widget _row(List<double> opacities) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < opacities.length; i++) ...[
        if (i > 0) const SizedBox(width: _gap),
        Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: opacities[i].clamp(0.0, 1.0),
            ),
            shape: BoxShape.circle,
          ),
        ),
      ],
    ],
  );
}
