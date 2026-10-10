import 'package:flutter/material.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../domain/entities/lost_case.dart';

String caseDateLabel(DateTime time) {
  final local = time.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String caseFailureLabel(CaseFailureKind? kind) => switch (kind) {
  CaseFailureKind.invalid =>
    'Elige mascota y fotos, fecha y hora válidas, punto y referencia del lugar.',
  CaseFailureKind.activeCase =>
    'Esta mascota ya tiene un caso perdido activo. Consulta Mis casos.',
  CaseFailureKind.photosUnverified =>
    'Vuelve a guardar las fotos desde Editar mascota para procesarlas antes de publicarlas.',
  CaseFailureKind.incompletePet =>
    'Completa tamaño, edad y rasgos desde Editar mascota antes de publicar.',
  CaseFailureKind.conflict =>
    'La ficha o el envío cambió. Consulta Mis casos antes de iniciar otra publicación.',
  CaseFailureKind.forbidden =>
    'No tienes autorización para publicar esta mascota. Revisa tu sesión.',
  _ =>
    'No pudimos confirmar la operación. Conservamos los datos para reintentar.',
};

class CasePublicContent extends StatelessWidget {
  const CasePublicContent({required this.value, super.key});
  final PublicLostCase value;
  @override
  Widget build(BuildContext context) {
    final f = value.fields;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          f.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          '${switch (f.species) {
            PetSpecies.dog => 'Perro',
            PetSpecies.cat => 'Gato',
            _ => f.speciesDetail ?? 'Otra especie',
          }} · ${switch (f.size) {
            PetSize.small => 'Pequeño',
            PetSize.medium => 'Mediano',
            PetSize.large => 'Grande',
            _ => 'Sin tamaño',
          }}',
          style: const TextStyle(fontSize: 18),
        ),
        if (f.ageMonths != null) Text('Edad: ${f.ageMonths} meses'),
        if (f.sex != null) Text(f.sex == PetSex.male ? 'Macho' : 'Hembra'),
        const SizedBox(height: 12),
        Text(f.traits ?? '', style: const TextStyle(fontSize: 16, height: 1.4)),
        const SizedBox(height: 18),
        Text('Desaparición: ${caseDateLabel(value.occurredAt)}'),
        const SizedBox(height: 12),
        Text(
          'Zona aproximada: ${value.latitude.toStringAsFixed(3)}, ${value.longitude.toStringAsFixed(3)}',
        ),
        const Text(
          'Se muestra el centro de una zona de unos 1 km. El punto exacto permanece privado.',
          style: TextStyle(color: Color(0xFF6E6E73), height: 1.4),
        ),
        const SizedBox(height: 20),
        for (final photo in value.photos) ...[
          if (photo.uri != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.network(
                photo.uri.toString(),
                height: 240,
                fit: BoxFit.cover,
                semanticLabel: 'Foto de ${f.name}',
                errorBuilder: (_, _, _) => const _PhotoError(),
              ),
            )
          else
            const _PhotoError(),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PhotoError extends StatelessWidget {
  const _PhotoError();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Foto no disponible. Vuelve a consultar para reintentar.'),
  );
}
