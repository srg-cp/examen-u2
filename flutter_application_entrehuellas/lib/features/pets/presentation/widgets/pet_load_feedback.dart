import 'package:flutter/material.dart';
import '../../domain/failures/pet_failure.dart';

class PetLoadFeedback extends StatelessWidget {
  const PetLoadFeedback({required this.onRetry, this.error, super.key});
  final Object? error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        liveRegion: true,
        child: Text(
          error is PetFailure &&
                  (error as PetFailure).kind == PetFailureKind.missing
              ? 'No encontramos esta mascota.'
              : 'No se pudo cargar la información.',
          style: const TextStyle(fontSize: 16, color: Color(0xFF6E6E73)),
        ),
      ),
      ...[
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    ],
  );
}
