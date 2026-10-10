import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pet.dart';
import 'pet_labels.dart';

class PetSizeSelector extends StatelessWidget {
  const PetSizeSelector({
    required this.value,
    required this.onChanged,
    this.invalid = false,
    super.key,
  });
  final PetSize? value;
  final bool invalid;
  final ValueChanged<PetSize?>? onChanged;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final slotWidth = (constraints.maxWidth - 16) / 3;
      final stacked =
          MediaQuery.textScalerOf(context).scale(14) > 18 || slotWidth < 108;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final size in PetSize.values) ...[
            if (size.index > 0) const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: _label(context, size, slotWidth, stacked),
                selected: value == size,
                showCheckmark: false,
                surfaceTintColor: Colors.transparent,
                onSelected: onChanged == null
                    ? null
                    : (selected) => onChanged!(selected ? size : null),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.surface,
                side: BorderSide(
                  color: invalid
                      ? AppColors.error
                      : value == size
                      ? AppColors.ink
                      : AppColors.divider,
                  width: invalid
                      ? 3.5
                      : value == size
                      ? 1.5
                      : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                labelPadding: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                labelStyle: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 14,
                  color: invalid ? AppColors.error : AppColors.ink,
                ),
              ),
            ),
          ],
        ],
      );
    },
  );

  Widget _label(
    BuildContext context,
    PetSize size,
    double slotWidth,
    bool stacked,
  ) {
    final width = (slotWidth - 16 - (invalid ? 7 : 3)).clamp(
      1.0,
      double.infinity,
    );
    final style = TextStyle(
      fontFamily: 'sans-serif',
      fontSize: 14,
      height: 1.3,
      letterSpacing: 0,
      color: invalid ? AppColors.error : AppColors.ink,
    );
    final text = Text(
      sizeLabel(size),
      style: style,
      textAlign: stacked ? TextAlign.center : TextAlign.start,
      softWrap: true,
      maxLines: 3,
      overflow: TextOverflow.visible,
    );
    if (!stacked) {
      return SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon(size),
            const SizedBox(width: 4),
            Flexible(child: text),
          ],
        ),
      );
    }
    final painter = TextPainter(
      text: TextSpan(text: sizeLabel(size), style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 3,
    )..layout(maxWidth: width);
    final height = 26 + painter.height;
    painter.dispose();
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_icon(size), const SizedBox(height: 4), text],
      ),
    );
  }

  Widget _icon(PetSize size) => SizedBox.square(
    dimension: 22,
    child: Icon(
      Icons.pets_outlined,
      size: 14 + size.index * 4,
      color: invalid
          ? AppColors.error
          : value == size
          ? AppColors.ink
          : AppColors.secondary,
    ),
  );
}
