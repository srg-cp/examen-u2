import 'dart:typed_data';
import 'dart:isolate';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'profile_photo_source.dart';

/// A fresh image copies only pixels, dropping EXIF/GPS from the original.
Uint8List prepareProfilePhoto(Uint8List bytes) {
  try {
    return _prepareProfilePhoto(bytes);
  } on ProfilePhotoSourceFailure {
    rethrow;
  } catch (_) {
    throw const ProfilePhotoSourceFailure(
      ProfilePhotoSourceFailureKind.invalidPhoto,
    );
  }
}

Uint8List _prepareProfilePhoto(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > 10485760) {
    throw const ProfilePhotoSourceFailure(
      ProfilePhotoSourceFailureKind.invalidPhoto,
    );
  }
  final decoder = img.findDecoderForData(bytes);
  final info = decoder?.startDecode(bytes);
  if (info == null ||
      info.width > 4096 ||
      info.height > 4096 ||
      info.width * info.height > 16000000) {
    throw const ProfilePhotoSourceFailure(
      ProfilePhotoSourceFailureKind.invalidPhoto,
    );
  }
  final decoded = decoder!.decodeFrame(0);
  if (decoded == null) {
    throw const ProfilePhotoSourceFailure(
      ProfilePhotoSourceFailureKind.invalidPhoto,
    );
  }
  final cropped = img.copyResizeCropSquare(
    img.bakeOrientation(decoded),
    size: 512,
  );
  final clean = img.Image(width: 512, height: 512);
  img.fill(clean, color: img.ColorRgb8(245, 245, 247));
  img.compositeImage(clean, cropped);
  return img.encodeJpg(clean, quality: 85);
}

Future<Uint8List> _prepareWithoutBlocking(Uint8List bytes) async {
  if (const bool.fromEnvironment('dart.library.js_interop')) {
    return prepareProfilePhoto(bytes);
  }
  return Isolate.run(() => prepareProfilePhoto(bytes));
}

final class GalleryProfilePhotoSource implements ProfilePhotoSource {
  GalleryProfilePhotoSource(this._picker);
  final ImagePicker _picker;
  Future<Uint8List?> _prepare(XFile? file) async =>
      file == null ? null : _prepareWithoutBlocking(await file.readAsBytes());
  static const pendingOwnerKey = 'profile_photo_pending_owner';
  @override
  Future<Uint8List?> choose(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(pendingOwnerKey, userId)) {
      throw const ProfilePhotoSourceFailure(
        ProfilePhotoSourceFailureKind.unavailable,
      );
    }
    try {
      return await _prepare(
        await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 90,
          requestFullMetadata: false,
        ),
      );
    } finally {
      if (preferences.getString(pendingOwnerKey) == userId) {
        await preferences.remove(pendingOwnerKey);
      }
    }
  }

  @override
  Future<Uint8List?> recover(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final owner = preferences.getString(pendingOwnerKey);
    if (owner == null) {
      // Another feature may own the native lost selection.
      return null;
    }
    try {
      final lost = await _picker.retrieveLostData();
      if (owner != userId) {
        return null;
      }
      if (lost.exception != null) {
        throw const ProfilePhotoSourceFailure(
          ProfilePhotoSourceFailureKind.unavailable,
        );
      }
      return await _prepare(lost.files?.firstOrNull);
    } on UnimplementedError {
      return null;
    } finally {
      if (preferences.getString(pendingOwnerKey) == owner) {
        await preferences.remove(pendingOwnerKey);
      }
    }
  }
}
