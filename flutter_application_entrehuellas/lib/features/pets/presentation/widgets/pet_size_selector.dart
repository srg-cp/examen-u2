import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pet.dart';
import 'pet_labels.dart';

class PetSizeSelector extends StatelessWidget {
  const PetSizeSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final PetSize? value;
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
                label: SizedBox(
                  width: (slotWidth - 16).clamp(0, double.infinity),
                  child: stacked
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _icon(size),
                            const SizedBox(height: 4),
                            Text(
                              sizeLabel(size),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              maxLines: 3,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _icon(size),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                sizeLabel(size),
                                softWrap: true,
                                maxLines: 3,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                ),
                selected: value == size,
                showCheckmark: false,
                surfaceTintColor: Colors.transparent,
                onSelected: onChanged == null
                    ? null
                    : (selected) => onChanged!(selected ? size : null),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.surface,
                side: BorderSide(
                  color: value == size ? AppColors.ink : AppColors.divider,
                  width: value == size ? 1.5 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                labelPadding: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                labelStyle: const TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 14,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ],
      );
    },
  );

  Widget _icon(PetSize size) => SizedBox.square(
    dimension: 22,
    child: Icon(
      Icons.pets_outlined,
      size: 14 + size.index * 4,
      color: value == size ? AppColors.ink : AppColors.secondary,
    ),
  );
}
