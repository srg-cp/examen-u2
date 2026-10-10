import 'dart:typed_data';
import '../../domain/entities/pet_photo.dart';
import '../../domain/repositories/pet_photo_repository.dart';
import '../data_sources/pet_gallery_source.dart';
import '../data_sources/pet_photo_data_source.dart';

class PetPhotoRepositoryImpl implements PetPhotoRepository {
  const PetPhotoRepositoryImpl(this._gallery, this._remote);
  final PetGallerySource _gallery;
  final PetPhotoDataSource _remote;
  Future<T> _run<T>(Future<T> Function() action, {bool gallery = false}) async {
    try {
      return await action();
    } on PetGalleryFailure catch (e) {
      throw PetPhotoFailure(
        e.kind == PetGalleryFailureKind.invalidPhoto
            ? PetPhotoFailureKind.invalidPhoto
            : PetPhotoFailureKind.galleryUnavailable,
      );
    } on PetPhotoSourceFailure catch (e) {
      throw PetPhotoFailure(switch (e.kind) {
        PetPhotoSourceFailureKind.forbidden => PetPhotoFailureKind.forbidden,
        PetPhotoSourceFailureKind.limit => PetPhotoFailureKind.limit,
        _ => PetPhotoFailureKind.unavailable,
      });
    } catch (_) {
      throw PetPhotoFailure(
        gallery
            ? PetPhotoFailureKind.galleryUnavailable
            : PetPhotoFailureKind.unavailable,
      );
    }
  }

  @override
  Future<Uint8List?> choose(String ownerId, String petId, bool existing) =>
      _run(() => _gallery.choose(ownerId, petId, existing), gallery: true);
  @override
  Future<Uint8List?> recover(String ownerId, String petId, bool existing) =>
      _run(() => _gallery.recover(ownerId, petId, existing), gallery: true);
  @override
  Future<List<PetPhoto>> list(String ownerId, String petId) => _run(
    () async =>
        (await _remote.list(ownerId, petId)).map((d) => d.toEntity()).toList(),
  );
  @override
  Future<PetPhoto> upload(String ownerId, String petId, PetPhotoDraft draft) =>
      _run(
        () async => (await _remote.upload(
          ownerId,
          petId,
          draft.id,
          draft.bytes,
        )).toEntity(),
      );
  @override
  Future<void> remove(String ownerId, String petId, String photoId) =>
      _run(() => _remote.remove(ownerId, petId, photoId));
}
