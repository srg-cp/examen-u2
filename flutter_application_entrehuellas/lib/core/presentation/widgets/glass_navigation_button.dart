import 'package:flutter/material.dart';
import 'glass_surface.dart';

/// Shared glass control for returning from or closing a screen.
class GlassNavigationButton extends StatelessWidget {
  const GlassNavigationButton({
    required this.tooltip,
    required this.onPressed,
    this.icon = Icons.chevron_left_rounded,
    super.key,
  });
  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => GlassSurface(
    radius: 26,
    child: IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size(52, 52),
        shape: const CircleBorder(),
        foregroundColor: const Color(0xFF111111),
      ),
      icon: Icon(icon, size: 28),
    ),
  );
}
