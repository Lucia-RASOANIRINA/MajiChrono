import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:majichrono/app/theme/app_colors.dart';

/// Un des quatre piliers montres a l'accueil.
class Pillar {
  const Pillar({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

/// Ronde des quatre piliers, chacun passant a son tour dans les deux mains.
///
/// La maquette montre quatre vignettes disposees en cercle, reliees par un
/// trace, et une paire de mains qui porte le colis. L'animation reprend
/// exactement cela : les vignettes tournent **de la gauche vers la droite**, et
/// s'arretent une a une au creux des mains, en bas du cercle.
///
/// Le mouvement est **decoupe en tours**, pas continu. Une rotation lente et
/// permanente ne donne a lire aucun des quatre piliers : l'oeil suit le
/// mouvement au lieu de lire les mots. Ici chaque pilier avance d'un quart de
/// tour, puis reste pose deux secondes et demie dans les mains — le temps de
/// lire « Rapidite », puis « Expediteur », puis « Livreur », puis « Confiance ».
///
/// Aucun moteur 3D, aucune animation vectorielle importee : quatre widgets
/// positionnes sur un cercle et un [CustomPainter] pour le decor. Le budget de
/// 25 Mo d'APK ne supporterait pas une bibliotheque d'animation, et un ecran
/// d'accueil n'est pas l'endroit ou depenser cette marge.
class PillarsAnimation extends StatefulWidget {
  const PillarsAnimation({required this.pillars, super.key});

  final List<Pillar> pillars;

  @override
  State<PillarsAnimation> createState() => _PillarsAnimationState();
}

class _PillarsAnimationState extends State<PillarsAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Duree d'un tour complet : glissement puis pose.
  static const Duration _travel = Duration(milliseconds: 900);
  static const Duration _rest = Duration(milliseconds: 2400);

  /// Part du cycle occupee par le glissement. Le reste est la pose.
  static final double _travelFraction =
      _travel.inMilliseconds / (_travel + _rest).inMilliseconds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _travel + _rest,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Avancement continu en quarts de tour, adouci aux deux extremites.
  ///
  /// Sans adoucissement, la vignette part et s'arrete net : le mouvement parait
  /// mecanique. `easeInOutCubic` lui donne l'inertie d'un objet qu'on pose.
  double _progress() {
    final t = _controller.value;
    if (t >= _travelFraction) return 1;
    return Curves.easeInOutCubic.transform(t / _travelFraction);
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.pillars.length;
    if (count == 0) return const SizedBox.shrink();

    // Accessibilite : quand le systeme demande la suppression des animations,
    // la ronde s'arrete sur le premier pilier. Les quatre restent lisibles,
    // c'est le mouvement qui disparait (EXI-T09).
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(
          constraints.maxWidth,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 320.0,
        );
        final radius = side * 0.33;

        return SizedBox.square(
          dimension: side,
          child: AnimationBuilderOrStill(
            controller: _controller,
            still: still,
            builder: (context) {
              // Nombre de quarts de tour deja accomplis, plus l'avancement du
              // tour en cours.
              final step = still
                  ? 0.0
                  : (_controller.lastElapsedDuration ?? Duration.zero)
                            .inMilliseconds ~/
                        (_travel + _rest).inMilliseconds;
              final advance = still ? 0.0 : _progress();

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Decor : le cercle de liaison, le trace de suivi et les deux
                  // mains, dessines une fois pour toutes derriere les vignettes.
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _OrbitPainter(radius: radius),
                    ),
                  ),
                  for (final entry in _placed(count, step + advance, radius))
                    Positioned(
                      left: side / 2 + entry.offset.dx - _cardSide / 2,
                      top: side / 2 + entry.offset.dy - _cardSide / 2,
                      child: Opacity(
                        opacity: entry.focus,
                        child: Transform.scale(
                          scale: 0.68 + 0.32 * entry.focus,
                          child: _PillarCard(
                            pillar: widget.pillars[entry.index],
                            focused: entry.focus > 0.75,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static const double _cardSide = 92;

  /// Position de chaque pilier pour un avancement donne, du plus lointain au
  /// plus proche des mains — l'ordre de peinture, pour que la vignette portee
  /// passe devant les autres.
  List<_Placed> _placed(int count, double advance, double radius) {
    final placed = <_Placed>[];
    for (var i = 0; i < count; i++) {
      // Le creux des mains est en bas du cercle. Un pilier y arrive quand son
      // rang atteint l'avancement courant. Le sens est horaire — de la gauche
      // vers la droite, comme demande.
      final turns = (advance - i) / count;
      final angle = math.pi / 2 - turns * 2 * math.pi;

      final offset = Offset(
        radius * math.cos(angle),
        // L'ellipse est aplatie : un cercle parfait pousserait les vignettes
        // hautes hors du cadre sur un ecran de 320 dp.
        radius * math.sin(angle) * 0.62,
      );

      // Proximite du creux des mains, entre 0 et 1.
      final focus = ((math.sin(angle) + 1) / 2).clamp(0.35, 1.0);
      placed.add(_Placed(index: i, offset: offset, focus: focus));
    }

    placed.sort((a, b) => a.focus.compareTo(b.focus));
    return placed;
  }
}

class _Placed {
  const _Placed({
    required this.index,
    required this.offset,
    required this.focus,
  });

  final int index;
  final Offset offset;
  final double focus;
}

/// Reconstruit a chaque image, ou une seule fois si les animations sont
/// desactivees. Evite d'abonner l'arbre a un contrôleur qui ne tourne pas.
class AnimationBuilderOrStill extends StatelessWidget {
  const AnimationBuilderOrStill({
    required this.controller,
    required this.still,
    required this.builder,
    super.key,
  });

  final AnimationController controller;
  final bool still;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => still
      ? builder(context)
      : AnimatedBuilder(
          animation: controller,
          builder: (context, _) => builder(context),
        );
}

/// Vignette d'un pilier : icone dans une pastille, libelle dessous.
class _PillarCard extends StatelessWidget {
  const _PillarCard({required this.pillar, required this.focused});

  final Pillar pillar;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _PillarsAnimationState._cardSide,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: focused ? pillar.color : Colors.white.withValues(alpha: 0.6),
                width: focused ? 2.5 : 1.5,
              ),
              boxShadow: focused
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Icon(pillar.icon, size: 26, color: pillar.color),
          ),
          const SizedBox(height: 6),
          Text(
            pillar.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: focused ? 14 : 12,
              fontWeight: focused ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decor fixe : l'ellipse de liaison, la ligne de suivi et les deux mains.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // L'ellipse qui relie les quatre piliers, reprise de la maquette.
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 2 * 0.62,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.28),
    );

    _paintPulse(canvas, center);
    _paintHands(canvas, center);
  }

  /// Le trace de suivi qui traverse le cercle sur la maquette. Il dit en une
  /// ligne ce que fait l'application : un colis suivi, battement par battement.
  void _paintPulse(Canvas canvas, Offset center) {
    final width = radius * 1.1;
    final path = Path()..moveTo(center.dx - width / 2, center.dy);
    final points = <Offset>[
      Offset(center.dx - width * 0.28, center.dy),
      Offset(center.dx - width * 0.18, center.dy - radius * 0.20),
      Offset(center.dx - width * 0.06, center.dy + radius * 0.22),
      Offset(center.dx + width * 0.06, center.dy - radius * 0.14),
      Offset(center.dx + width * 0.20, center.dy),
      Offset(center.dx + width / 2, center.dy),
    ];
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = AppColors.accent.withValues(alpha: 0.85),
    );
  }

  /// Les deux mains ouvertes, au creux desquelles chaque pilier vient se poser.
  ///
  /// Deux paumes stylisees et non un dessin realiste : a cette taille, un
  /// contour detaille se referme en tache, et l'ecran est dessine par le code —
  /// pas de fichier vectoriel a charger.
  void _paintHands(Canvas canvas, Offset center) {
    final base = Offset(center.dx, center.dy + radius * 0.66);
    final s = radius * 0.58;

    // Paumes pleines et non simples traits : a cette taille, deux arcs se
    // lisent comme deux collines. Une surface fermee, avec des doigts creuses
    // par-dessus, se lit comme une main.
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.94);
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, s * 0.075)
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary.withValues(alpha: 0.85);

    for (final side in [-1.0, 1.0]) {
      double x(double k) => base.dx + side * s * k;
      double y(double k) => base.dy + s * k;

      final palm = Path()
        // Poignet, qui sort du cadre en bas comme sur la maquette.
        ..moveTo(x(1.42), y(0.86))
        // Tranche exterieure, qui remonte vers les doigts.
        ..quadraticBezierTo(x(1.28), y(-0.16), x(0.66), y(-0.34))
        // Bout des doigts, incline vers le centre pour former le creux.
        ..quadraticBezierTo(x(0.30), y(-0.44), x(0.06), y(-0.18))
        // Creux de la paume.
        ..quadraticBezierTo(x(0.34), y(0.10), x(0.62), y(0.24))
        // Retour au poignet par le dessous.
        ..quadraticBezierTo(x(1.02), y(0.48), x(1.14), y(0.96))
        ..close();
      canvas.drawPath(palm, fill);

      // Trois separations de doigts, creusees dans la paume.
      for (var i = 0; i < 3; i++) {
        final k = 0.28 + i * 0.20;
        canvas.drawLine(
          Offset(x(k), y(-0.30 + i * 0.06)),
          Offset(x(k + 0.14), y(0.04 + i * 0.05)),
          groove,
        );
      }

      // Pouce, pose en travers de la paume.
      canvas.drawLine(
        Offset(x(1.02), y(0.16)),
        Offset(x(0.58), y(0.40)),
        groove,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
