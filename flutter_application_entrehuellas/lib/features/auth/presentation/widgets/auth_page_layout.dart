import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/brand_wordmark.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';

/// Shared header geometry: changing form height must not move the brand/title.
class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    required this.title,
    required this.child,
    this.onClose,
    this.showClose = false,
    this.reveal = false,
    super.key,
  });

  final String? title;
  final Widget child;
  final VoidCallback? onClose;
  final bool showClose;
  final bool reveal;

  Widget _item(int order, Widget child) =>
      reveal ? StaggerRevealItem(order: order, child: child) : child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  // Retain the login's normal-scale anchor, independent of form.
                  padding: EdgeInsets.fromLTRB(
                    24,
                    math.max(28, (constraints.maxHeight - 660) / 2),
                    24,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _item(
                        1,
                        const Align(
                          key: ValueKey('auth-brand'),
                          alignment: Alignment.centerLeft,
                          child: BrandWordmark(iconSize: 80, textSize: 32),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (title != null) ...[
                        _item(
                          2,
                          Text(
                            title!,
                            key: const ValueKey('auth-title'),
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: 48,
                                  color: const Color(0xFF111111),
                                ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      child,
                    ],
                  ),
                ),
              ),
              if (showClose)
                Positioned(
                  top: 0,
                  left: 16,
                  child: _item(
                    0,
                    IconButton(
                      onPressed: onClose,
                      tooltip: 'Cerrar registro',
                      icon: const Icon(Icons.close_rounded, size: 30),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
