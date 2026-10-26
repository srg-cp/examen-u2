import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/origin_page_transition.dart';

void openLostReport(
  BuildContext context, {
  VoidCallback? onReturn,
  Color color = const Color(0xFF111111),
  double radius = 32,
  IconData icon = Icons.search_rounded,
}) {
  context
      .push(
        '/home/lost-cases/new',
        extra: _source(context, color, radius, icon, 24),
      )
      .then((_) => onReturn?.call());
}

void openHomeAction(
  BuildContext context,
  String path,
  IconData icon, {
  Color color = const Color(0xFF111111),
  double radius = 22,
  double iconSize = 24,
}) =>
    context.push(path, extra: _source(context, color, radius, icon, iconSize));

OriginPageSource? _source(
  BuildContext context,
  Color color,
  double radius,
  IconData icon,
  double iconSize,
) {
  final box = context.findRenderObject();
  final navigator = Navigator.of(context).context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return OriginPageSource(
    bounds: box.localToGlobal(Offset.zero, ancestor: navigator) & box.size,
    color: color,
    radius: radius,
    child: Icon(
      icon,
      size: iconSize,
      color: color == const Color(0xFF111111)
          ? Colors.white
          : const Color(0xFF459FF6),
    ),
  );
}
