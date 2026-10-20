import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';

/// Decorative community illustration, using the original landing artwork.
class HomeReunionCard extends StatelessWidget {
  const HomeReunionCard({super.key});

  @override
  Widget build(BuildContext context) => StaggerRevealItem(
    order: 2,
    preserveBackdrop: true,
    child: GlassSurface(
      radius: 26,
      backdropBlendMode: BlendMode.src,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: Image.asset(
            'assets/illustrations/reunion.png',
            fit: BoxFit.contain,
            semanticLabel: 'Un perro y un gato de la comunidad Entre Huellas',
          ),
        ),
      ),
    ),
  );
}
