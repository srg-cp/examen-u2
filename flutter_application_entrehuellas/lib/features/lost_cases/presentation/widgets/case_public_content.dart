import '../../../../core/presentation/widgets/case_photo.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/case_publication_preview.dart';
import '../../../../core/presentation/widgets/case_photo_failure.dart';
import 'package:flutter/material.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../domain/entities/lost_case.dart';

String caseDateLabel(DateTime time) => caseDateTimeLabel(time);

String caseFailureLabel(CaseFailureKind? kind) => switch (kind) {
  CaseFailureKind.busy =>
    'Otra operación está usando esta mascota. Reintenta en unos segundos.',
  CaseFailureKind.timedOut =>
    'La publicación no respondió. Reintenta o consulta Mis casos.',
  CaseFailureKind.invalid =>
    'Elige mascota y fotos, fecha y hora válidas, punto y referencia del lugar.',
  CaseFailureKind.activeCase =>
    'Esta mascota ya tiene un caso perdido activo. Consulta Mis casos.',
  CaseFailureKind.photosUnverified =>
    'Vuelve a guardar las fotos en Editar mascota.',
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
  const CasePublicContent({required this.value, this.actions, super.key});
  final PublicLostCase value;
  final Widget? actions;
  @override
  Widget build(BuildContext context) =>
      CasePreviewContent(value: value, actions: actions, isPreview: false);
}

class CasePreviewContent extends StatelessWidget {
  const CasePreviewContent({
    required this.value,
    this.actions,
    this.isPreview = true,
    super.key,
  });
  final PublicLostCase value;
  final Widget? actions;
  final bool isPreview;
  @override
  Widget build(BuildContext context) {
    final f = value.fields;
    return CasePublicationPreview(
      name: f.name,
      latitude: value.latitude,
      longitude: value.longitude,
      locationLabel: 'Zona de desaparición',
      photos: [
        for (final photo in value.photos)
          photo.uri == null
              ? const CasePhotoFailure()
              : CasePhotoView.network(
                  photo.uri!,
                  semanticLabel: 'Foto de ${f.name}',
                ),
      ],
      facts: [
        if (!isPreview && value.status == 'active')
          const PreviewFact(Icons.search, 'Búsqueda activa'),
        if (f.ageMonths != null)
          PreviewFact(Icons.calendar_today_outlined, '${f.ageMonths} meses'),
        PreviewFact(Icons.pets_outlined, switch (f.species) {
          PetSpecies.dog => 'Perro',
          PetSpecies.cat => 'Gato',
          _ => f.speciesDetail ?? 'Otra especie',
        }),
        if (f.sex != null)
          PreviewFact(
            f.sex == PetSex.male ? Icons.male : Icons.female,
            f.sex == PetSex.male ? 'Macho' : 'Hembra',
          ),
        if (f.size != null)
          PreviewFact(Icons.straighten, switch (f.size!) {
            PetSize.small => 'Pequeño',
            PetSize.medium => 'Mediano',
            PetSize.large => 'Grande',
          }),
      ],
      description: f.traits ?? '',
      occurredAt: 'Desaparición: ${caseDateLabel(value.occurredAt)}',
      privacy: isPreview
          ? 'Zona pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados. Al publicar, estos datos y fotos serán públicos; revisa que no contengan domicilio, documentos ni datos personales.'
          : 'Zona pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados.',
      actions: actions,
    );
  }
}
