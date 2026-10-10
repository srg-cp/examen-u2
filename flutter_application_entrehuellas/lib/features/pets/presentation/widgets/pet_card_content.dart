import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pet.dart';
import 'pet_labels.dart';

class PetCardContent extends StatelessWidget {
  const PetCardContent({
    required this.pet,
    this.foreground = AppColors.ink,
    this.secondary = AppColors.secondary,
    super.key,
  });
  final Pet pet;
  final Color foreground;
  final Color secondary;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        if (pet.coverUri != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              pet.coverUri.toString(),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              cacheWidth: 128,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.pets_outlined, size: 28, color: secondary),
            ),
          )
        else
          Icon(Icons.pets_outlined, size: 28, color: secondary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.fields.name,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                pet.fields.speciesDetail ?? speciesLabel(pet.fields.species),
                style: TextStyle(fontSize: 15, height: 1.25, color: secondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right_rounded, color: secondary),
      ],
    ),
  );
}
