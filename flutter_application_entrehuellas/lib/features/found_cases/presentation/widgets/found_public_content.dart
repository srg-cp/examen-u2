import '../../../../core/presentation/widgets/case_photo.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/case_publication_preview.dart';
import '../../../../core/presentation/widgets/case_photo_failure.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/found_case.dart';

String foundSpeciesLabel(String? species) => switch (species) {
  'dog' => 'Perro',
  'cat' => 'Gato',
  'other' => 'Otra especie',
  _ => 'Mascota',
};
String foundDateLabel(DateTime time) => caseDateTimeLabel(time);

class FoundPublicContent extends StatelessWidget {
  const FoundPublicContent({
    required this.value,
    this.actions,
    this.localPhotos = const {},
    super.key,
  });
  final PublicFoundCase value;
  final Widget? actions;
  final Map<String, Uint8List> localPhotos;
  @override
  Widget build(BuildContext context) => FoundPreviewContent(
    value: value,
    localPhotos: localPhotos,
    actions: actions,
    isPreview: false,
  );
}

class FoundPreviewContent extends StatelessWidget {
  const FoundPreviewContent({
    required this.value,
    required this.localPhotos,
    this.actions,
    this.isPreview = true,
    super.key,
  });
  final PublicFoundCase value;
  final Map<String, Uint8List> localPhotos;
  final Widget? actions;
  final bool isPreview;
  @override
  Widget build(BuildContext context) => CasePublicationPreview(
    name: value.speciesDetail ?? foundSpeciesLabel(value.species),
    latitude: value.latitude,
    longitude: value.longitude,
    locationLabel: value.reportKind == 'possible_loss'
        ? 'Zona de posible desaparición'
        : 'Zona del aviso',
    photos: [
      for (final photo in value.photos)
        localPhotos[photo.id] != null
            ? CasePhotoView.memory(localPhotos[photo.id]!)
            : photo.uri == null
            ? const CasePhotoFailure()
            : CasePhotoView.network(photo.uri!),
    ],
    facts: [
      if (!isPreview && value.status == 'active')
        const PreviewFact(Icons.search, 'Reporte activo'),
      PreviewFact(Icons.pets_outlined, foundSpeciesLabel(value.species)),
      if (value.size != null)
        PreviewFact(Icons.straighten, switch (value.size!) {
          'small' => 'Pequeño',
          'medium' => 'Mediano',
          _ => 'Grande',
        }),
      if (value.sex != null)
        PreviewFact(
          value.sex == 'male' ? Icons.male : Icons.female,
          value.sex == 'male' ? 'Macho' : 'Hembra',
        ),
      if (value.custody != null)
        PreviewFact(
          Icons.home_outlined,
          value.custody == 'with_me'
              ? 'Está bajo mi cuidado'
              : 'No está bajo mi cuidado',
        ),
    ],
    description: value.traits,
    eventLabel: switch (value.reportKind) {
      'possible_loss' => 'Posiblemente perdida',
      'sighting' => 'Avistamiento',
      'with_reporter' => 'Encontrada',
      _ => 'Reporte anterior',
    },
    occurredAt: 'Observada el ${foundDateLabel(value.occurredAt)}',
    privacy: isPreview
        ? 'Zona pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados. Al publicar, estos datos y fotos serán públicos; revisa que no contengan domicilio, documentos ni datos personales.'
        : 'Zona pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados.',
    actions: actions,
  );
}
