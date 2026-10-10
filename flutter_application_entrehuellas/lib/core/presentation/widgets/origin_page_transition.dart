import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Expands a rounded surface from the triggering control and reverses on pop.
class OriginPageTransition extends StatelessWidget {
  const OriginPageTransition({
    required this.animation,
    required this.child,
    this.origin,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;
  final Rect? origin;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    if (origin == null) {
      return FadeTransition(opacity: animation, child: child);
    }
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final progress = Curves.easeInOutCubic.transform(animation.value);
          final bounds = Offset.zero & constraints.biggest;
          final visibleOrigin = origin!.intersect(bounds);
          final start = visibleOrigin.isEmpty
              ? Rect.fromCenter(center: bounds.center, width: 48, height: 48)
              : visibleOrigin;
          final surface = Rect.lerp(start, bounds, progress)!;
          final radius = ui.lerpDouble(24, 0, progress)!;
          final contentOpacity = originContentOpacity(animation.value);
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fromRect(
                rect: surface,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: progress > 0 && progress < 1
                        ? const [
                            BoxShadow(color: Color(0x20000000), blurRadius: 24),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    key: const ValueKey('origin-surface'),
                    borderRadius: BorderRadius.circular(radius),
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: bounds.width,
                      maxWidth: bounds.width,
                      minHeight: bounds.height,
                      maxHeight: bounds.height,
                      child: IgnorePointer(
                        ignoring: animation.status != AnimationStatus.completed,
                        child: Transform.scale(
                          alignment: Alignment.topLeft,
                          scale: surface.width / bounds.width,
                          child: Opacity(opacity: contentOpacity, child: child),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Let the source surface change shape before revealing destination content.
double originContentOpacity(double value) =>
    const Interval(.65, 1, curve: Curves.easeOutCubic).transform(value);
