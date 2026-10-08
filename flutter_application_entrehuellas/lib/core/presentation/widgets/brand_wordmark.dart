import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'brand_mark.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({this.iconSize = 52, this.textSize = 22, super.key});

  final double iconSize;
  final double textSize;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Entre Huellas',
    child: ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(size: iconSize),
            const SizedBox(width: 12),
            Text(
              'Entre\nHuellas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: AppTheme.fontFamily,
                fontSize: textSize,
                fontWeight: FontWeight.w800,
                height: 0.95,
                color: const Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
