import 'package:flutter/material.dart';

/// Shared surface of segmented selectors and floating filter controls.
class SelectionPillSurface extends StatelessWidget {
  const SelectionPillSurface({required this.child, super.key});
  static const background = Color(0xFFE5E5EA);
  static const selected = Color(0xFF111111);
  static const optionRadius = 26.0;
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Padding(padding: const EdgeInsets.all(6), child: child),
  );
}
