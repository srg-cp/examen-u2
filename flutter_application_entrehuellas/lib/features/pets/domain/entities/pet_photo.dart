import 'dart:typed_data';

class PetPhoto {
  const PetPhoto({
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
}

class PetPhotoDraft {
  const PetPhotoDraft({required this.id, required this.bytes});
  final String id;
  final Uint8List bytes;
}

enum PetPhotoFailureKind {
  unavailable,
  galleryUnavailable,
  invalidPhoto,
  limit,
  forbidden,
}

class PetPhotoFailure implements Exception {
  const PetPhotoFailure(this.kind);
  final PetPhotoFailureKind kind;
}
