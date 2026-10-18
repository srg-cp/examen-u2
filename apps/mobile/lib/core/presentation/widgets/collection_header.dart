import 'package:flutter/material.dart';

class CollectionHeader extends StatelessWidget {
  const CollectionHeader({
    required this.title,
    this.action,
    this.keepActionInline = false,
    super.key,
  });
  final String title;
  final Widget? action;
  final bool keepActionInline;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Text(
        title,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111111),
        ),
      );
      if (action == null) return heading;
      if (!keepActionInline &&
          (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(32) > 42)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            if (action != null) ...[
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: action!),
            ],
          ],
        );
      }
      // Keep titles aligned across collections with different action sizes.
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Expanded(child: heading),
            const SizedBox(width: 12),
            action!,
          ],
        ),
      );
    },
  );
}
