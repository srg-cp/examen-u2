import 'dart:typed_data';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PetGalleryFailureKind { invalidPhoto, unavailable }

class PetGalleryFailure implements Exception {
  const PetGalleryFailure(this.kind);
  final PetGalleryFailureKind kind;
}

Uint8List preparePetPhoto(Uint8List bytes) {
  try {
    if (bytes.isEmpty || bytes.length > 10485760) {
      throw const PetGalleryFailure(PetGalleryFailureKind.invalidPhoto);
    }
    final decoder = img.findDecoderForData(bytes);
    final info = decoder?.startDecode(bytes);
    if (info == null ||
        info.width > 4096 ||
        info.height > 4096 ||
        info.width * info.height > 16000000) {
      throw const PetGalleryFailure(PetGalleryFailureKind.invalidPhoto);
    }
    final raw = decoder!.decodeFrame(0);
    if (raw == null) {
      throw const PetGalleryFailure(PetGalleryFailureKind.invalidPhoto);
    }
    var image = img.bakeOrientation(raw);
    if (image.width > 1280 || image.height > 1280) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? 1280 : null,
        height: image.height > image.width ? 1280 : null,
      );
    }
    final clean = img.Image(width: image.width, height: image.height);
    img.fill(clean, color: img.ColorRgb8(245, 245, 247));
    img.compositeImage(clean, image);
    return img.encodeJpg(clean, quality: 85);
  } on PetGalleryFailure {
    rethrow;
  } catch (_) {
    throw const PetGalleryFailure(PetGalleryFailureKind.invalidPhoto);
  }
}

abstract interface class PetGallerySource {
  Future<Uint8List?> choose(String owner, String pet, bool existing);
  Future<Uint8List?> recover(String owner, String pet, bool existing);
}

class NativePetGallerySource implements PetGallerySource {
  const NativePetGallerySource(this._picker);
  final ImagePicker _picker;
  static const marker = 'pet_photo_pending';
  Future<Uint8List?> _prepare(XFile? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (const bool.fromEnvironment('dart.library.js_interop')) {
      return preparePetPhoto(bytes);
    }
    return Isolate.run(() => preparePetPhoto(bytes));
  }

  @override
  Future<Uint8List?> choose(String owner, String pet, bool existing) async {
    final preferences = await SharedPreferences.getInstance();
    final context = '$owner|$pet|$existing';
    if (!await preferences.setString(marker, context)) {
      throw const PetGalleryFailure(PetGalleryFailureKind.unavailable);
    }
    try {
      return await _prepare(
        await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 90,
          requestFullMetadata: false,
        ),
      );
    } finally {
      if (preferences.getString(marker) == context) {
        await preferences.remove(marker);
      }
    }
  }

  @override
  Future<Uint8List?> recover(String owner, String pet, bool existing) async {
    final preferences = await SharedPreferences.getInstance();
    final context = preferences.getString(marker);
    if (context == null) return null;
    final parts = context.split('|');
    if (parts.length != 3) return null;
    if (parts[0] == owner &&
        (parts[2] == 'true' ? parts[1] != pet : existing)) {
      return null;
    }
    try {
      final lost = await _picker.retrieveLostData();
      if (parts[0] != owner) return null;
      if (lost.exception != null) {
        throw const PetGalleryFailure(PetGalleryFailureKind.unavailable);
      }
      return await _prepare(lost.files?.firstOrNull);
    } on UnimplementedError {
      return null;
    } finally {
      if (preferences.getString(marker) == context) {
        await preferences.remove(marker);
      }
    }
  }
}
