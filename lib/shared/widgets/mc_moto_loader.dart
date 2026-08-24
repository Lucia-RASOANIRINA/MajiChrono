import 'package:flutter/material.dart';

import 'package:majichrono/app/theme/app_colors.dart';

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

/// Ecran de chargement complet aux couleurs de la marque : le nom, puis la moto
/// qui roule sur sa barre. Pose sur le bleu de la charte, il prolonge l'ecran de
/// lancement Android sans rupture.
class McMotoLoadingView extends StatelessWidget {
  const McMotoLoadingView({this.label = 'MajiChrono', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 28),
            const McMotoLoader(width: 200),
            const SizedBox(height: 24),
            // Barre de chargement explicite, sous la moto : elle dit « ca charge »
            // avec le vocabulaire attendu d'un premier lancement, la ou la moto
            // porte la marque.
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
