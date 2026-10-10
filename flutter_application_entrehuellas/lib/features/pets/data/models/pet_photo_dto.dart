import '../../domain/entities/pet_photo.dart';

class PetPhotoDto {
  const PetPhotoDto({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.ready,
    this.uri,
  });
  final String id;
  final String petId;
  final String ownerId;
  final bool ready;
  final Uri? uri;
  factory PetPhotoDto.fromMap(Map<String, dynamic> row, {Uri? uri}) =>
      PetPhotoDto(
        id: row['id'] as String,
        petId: row['pet_id'] as String,
        ownerId: row['owner_id'] as String,
        ready: row['status'] == 'published',
        uri: uri,
      );
  PetPhoto toEntity() =>
      PetPhoto(id: id, petId: petId, ownerId: ownerId, ready: ready, uri: uri);
}
