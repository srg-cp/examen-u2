import 'package:flutter/material.dart';
import 'app_text_field.dart';
import 'stagger_reveal.dart';
import 'shake_field.dart';
import 'validation_surface.dart';
import 'zone_map_picker.dart';

/// Both report forms use the same private location interaction and guidance.
class CaseLocationFields extends StatelessWidget {
  const CaseLocationFields({
    required this.title,
    required this.order,
    required this.latitude,
    required this.longitude,
    required this.placeController,
    required this.onSelect,
    required this.onPlaceChanged,
    required this.errorId,
    this.pointInvalid = false,
    this.placeInvalid = false,
    super.key,
  });
  final String title;
  final int order, errorId;
  final double? latitude, longitude;
  final TextEditingController placeController;
  final void Function(double, double)? onSelect;
  final ValueChanged<String>? onPlaceChanged;
  final bool pointInvalid, placeInvalid;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StaggerRevealItem(
        order: order,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca el mapa para marcar el lugar. No necesitas dar permiso de ubicación. La referencia y el punto exacto son privados.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      StaggerRevealItem(
        order: order + 1,
        child: ValidationSurface(
          invalid: pointInvalid,
          errorId: errorId,
          child: ZoneMapPicker(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: 0,
            onSelect: onSelect,
          ),
        ),
      ),
      const SizedBox(height: 20),
      StaggerRevealItem(
        order: order + 2,
        child: ShakeField(
          errorId: errorId,
          hasError: placeInvalid,
          child: AppTextField(
            label: 'Referencia privada del lugar',
            invalid: placeInvalid,
            controller: placeController,
            enabled: onPlaceChanged != null,
            maxLines: 3,
            onChanged: onPlaceChanged,
          ),
        ),
      ),
    ],
  );
}
