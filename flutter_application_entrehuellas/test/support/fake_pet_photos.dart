import 'dart:typed_data';
import 'dart:async';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/repositories/pet_photo_repository.dart';

class FakePetPhotos implements PetPhotoRepository {
  Completer<void>? pendingList;
  int lists = 0;
  Uint8List? selection;
  Uint8List? recovered;
  bool loseAcknowledgement = false;
  final photos = <String, PetPhoto>{};
  final attempts = <String>[];
  @override
  Future<Uint8List?> choose(String owner, String pet, bool existing) async =>
      selection;
  @override
  Future<Uint8List?> recover(String owner, String pet, bool existing) async {
    final bytes = recovered;
    recovered = null;
    return bytes;
  }

  @override
  Future<List<PetPhoto>> list(String owner, String pet) async {
    lists++;
    await pendingList?.future;
    return photos.values
        .where((p) => p.ownerId == owner && p.petId == pet)
        .toList();
  }

  @override
  Future<PetPhoto> upload(String owner, String pet, PetPhotoDraft draft) async {
    attempts.add(draft.id);
    final photo = photos.putIfAbsent(
      draft.id,
      () => PetPhoto(
        id: draft.id,
        petId: pet,
        ownerId: owner,
        ready: true,
        uri: Uri.parse('https://example.invalid/${draft.id}.jpg'),
      ),
    );
    if (loseAcknowledgement) {
      loseAcknowledgement = false;
      throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
    }
    return photo;
  }

  @override
  Future<void> remove(String owner, String pet, String id) async {
    photos.remove(id);
  }
}
