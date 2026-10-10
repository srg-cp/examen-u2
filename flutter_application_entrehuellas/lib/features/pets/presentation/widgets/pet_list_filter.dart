import 'package:flutter/material.dart';

/// Joined selector for the two real pet lists, with a single moving indicator.
class PetListFilter extends StatelessWidget {
  const PetListFilter({
    required this.archived,
    required this.onChanged,
    super.key,
  });

  final bool archived;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = Theme.of(context).textTheme.labelLarge!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
      final painter = TextPainter(
        text: TextSpan(text: 'Archivadas', style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final stacked = (constraints.maxWidth - 12) / 2 < painter.width + 32;
      painter.dispose();
      final rtl = Directionality.of(context) == TextDirection.rtl;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: archived ? 1.0 : 0.0,
              end: archived ? 1.0 : 0.0,
            ),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            builder: (context, position, _) => Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: stacked
                        ? Alignment(0, position * 2 - 1)
                        : Alignment((rtl ? 1 - position : position) * 2 - 1, 0),
                    child: FractionallySizedBox(
                      widthFactor: stacked ? 1 : .5,
                      heightFactor: stacked ? .5 : 1,
                      child: DecoratedBox(
                        key: const ValueKey('pet-list-active-indicator'),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                  ),
                ),
                Flex(
                  direction: stacked ? Axis.vertical : Axis.horizontal,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: stacked
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.center,
                  children: [
                    for (final option in [false, true])
                      if (stacked)
                        _option(option, style, position)
                      else
                        Expanded(child: _option(option, style, position)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _option(bool option, TextStyle style, double position) => Semantics(
    selected: archived == option,
    button: true,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(option),
        borderRadius: BorderRadius.circular(26),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: Text(
                option ? 'Archivadas' : 'Activas',
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: Color.lerp(
                    const Color(0xFF111111),
                    Colors.white,
                    option ? position : 1 - position,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
