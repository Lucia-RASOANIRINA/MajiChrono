import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:majichrono/app/theme/design_tokens.dart';

/// Les quatre piliers de MajiChrono, en rotation dans l'espace.
///
/// Rapidite, expediteur, livreur, confiance : ce sont les quatre promesses du
/// produit, et elles tournent sur un carrousel incline plutot que de s'empiler
/// dans une liste. La perspective sert un propos — les quatre sont **liees**,
/// on ne choisit pas entre elles.
///
/// Le relief est obtenu par `Matrix4` seul : ni moteur 3D, ni Lottie, ni
/// texture. Un carrousel de quatre cartes ne justifie pas une dependance de
/// plusieurs megaoctets dans un APK deja au-dessus de son budget (EXI-P03).
///
/// L'animation s'arrete si l'utilisateur a desactive les animations systeme
/// (EXI-T09) : les cartes restent alors disposees en eventail, lisibles et
/// immobiles.
class PillarsAnimation extends StatefulWidget {
  const PillarsAnimation({required this.pillars, this.size = 280, super.key});

  final List<Pillar> pillars;
  final double size;

  @override
  State<PillarsAnimation> createState() => _PillarsAnimationState();
}

/// Un pilere : une icone, un mot, une couleur.
class Pillar {
  const Pillar({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;
}

class _PillarsAnimationState extends State<PillarsAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SizedBox(
      height: widget.size,
      width: widget.size * 1.4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final turn = reduced ? 0.0 : _controller.value;
          return _Carousel(
            pillars: widget.pillars,
            turn: turn,
            radius: widget.size * 0.42,
            // Le battement vertical donne du poids aux cartes : sans lui, la
            // rotation seule fait plat.
            bob: reduced ? 0.0 : math.sin(turn * 2 * math.pi) * 6,
          );
        },
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.pillars,
    required this.turn,
    required this.radius,
    required this.bob,
  });

  final List<Pillar> pillars;
  final double turn;
  final double radius;
  final double bob;

  @override
  Widget build(BuildContext context) {
    final count = pillars.length;

    // Les cartes sont triees par profondeur avant d'etre empilees : sans cela,
    // celle de derriere passerait devant une fois sur deux.
    final placed = <_PlacedPillar>[];
    for (var i = 0; i < count; i++) {
      final angle = (turn + i / count) * 2 * math.pi;
      placed.add(
        _PlacedPillar(
          pillar: pillars[i],
          angle: angle,
          depth: math.cos(angle),
        ),
      );
    }
    placed.sort((a, b) => a.depth.compareTo(b.depth));

    return Stack(
      alignment: Alignment.center,
      children: [
        for (final p in placed) _card(context, p),
      ],
    );
  }

  Widget _card(BuildContext context, _PlacedPillar placed) {
    final theme = Theme.of(context);

    // Position sur l'ellipse. L'axe vertical est ecrase pour simuler
    // l'inclinaison du plan de rotation.
    final dx = math.sin(placed.angle) * radius;
    final dy = -placed.depth * radius * 0.22 + bob;

    // Ce qui est loin est plus petit et plus pale : c'est tout ce qu'il faut
    // pour que l'oeil lise une profondeur.
    final scale = 0.72 + (placed.depth + 1) / 2 * 0.34;
    final opacity = 0.45 + (placed.depth + 1) / 2 * 0.55;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        // Perspective : la valeur reste faible, une fuite trop marquee
        // deformerait le texte au point de le rendre penible a lire.
        ..setEntry(3, 2, 0.0012)
        ..translateByDouble(dx, dy, 0, 1)
        ..scaleByDouble(scale, scale, 1, 1)
        ..rotateY(-math.sin(placed.angle) * 0.55),
      child: Opacity(
        opacity: opacity,
        child: _PillarCard(pillar: placed.pillar, theme: theme),
      ),
    );
  }
}

class _PlacedPillar {
  const _PlacedPillar({
    required this.pillar,
    required this.angle,
    required this.depth,
  });

  final Pillar pillar;
  final double angle;

  /// De -1 (au fond) a 1 (au premier plan).
  final double depth;
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({required this.pillar, required this.theme});

  final Pillar pillar;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Semantics(
    label: pillar.label,
    child: Container(
      width: 108,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.sheetAll,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: pillar.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(pillar.icon, size: 26, color: pillar.color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            pillar.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E2A78),
            ),
          ),
        ],
      ),
    ),
  );
}
