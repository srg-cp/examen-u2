import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/data_sources/gallery_profile_photo_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/pet_gallery_source.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_photos_view_model.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Lost gallery data is scoped to account and pet, and profile does not consume it',
    () async {
      final picker = _LostPicker(
        img.encodeJpg(img.Image(width: 10, height: 10)),
      );
      SharedPreferences.setMockInitialValues({
        NativePetGallerySource.marker: 'one|pet|true',
      });
      expect(await GalleryProfilePhotoSource(picker).recover('one'), isNull);
      expect(picker.calls, 0);
      final source = NativePetGallerySource(picker);
      expect(await source.recover('one', 'different-pet', true), isNull);
      expect(picker.calls, 0);
      expect(await source.recover('one', 'pet', true), isNotNull);
      expect(picker.calls, 1);
      SharedPreferences.setMockInitialValues({
        NativePetGallerySource.marker: 'one|pet|true',
      });
      expect(await source.recover('two', 'pet', true), isNull);
      expect(
        (await SharedPreferences.getInstance()).getString(
          NativePetGallerySource.marker,
        ),
        isNull,
      );
    },
  );
  test('Pet JPEG preserves aspect, bounds resolution and removes EXIF/GPS', () {
    final original = img.Image(width: 1400, height: 700);
    original.exif.imageIfd.imageDescription = 'private-location';
    original.exif.gpsIfd[1] = img.IfdValueAscii('N');
    final result = preparePetPhoto(img.encodeJpg(original));
    final decoded = img.decodeJpg(result)!;
    expect(decoded.width, 1280);
    expect(decoded.height, 640);
    expect(decoded.exif.gpsIfd[1], isNull);
    expect(
      utf8.decode(result, allowMalformed: true),
      isNot(contains('private-location')),
    );
    expect(
      () => preparePetPhoto(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<PetGalleryFailure>()),
    );
  });
  test(
    'Metadata save plus photo retry keeps IDs and acknowledges only a confirmed gallery',
    () async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final pets = FakePets();
      final photos = FakePetPhotos()
        ..selection = img.encodeJpg(img.Image(width: 10, height: 10));
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          petRepositoryProvider.overrideWithValue(pets),
          petPhotoRepositoryProvider.overrideWithValue(photos),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
      });
      final editor = petEditorViewModelProvider('new');
      final subscription = container.listen(editor, (_, __) {});
      addTearDown(subscription.close);
      final initial = await container.read(editor.future);
      final gallery = petPhotosViewModelProvider(initial.id);
      final photoSubscription = container.listen(gallery, (_, __) {});
      addTearDown(photoSubscription.close);
      final photoModel = container.read(gallery.notifier);
      await photoModel.initialize(false);
      await photoModel.choose(false);
      final id = container.read(gallery).pending.single.id;
      final model = container.read(editor.notifier);
      model.edit(
        name: 'Luna',
        species: PetSpecies.cat,
        size: PetSize.medium,
        age: '24',
        traits: 'Blanca',
      );
      photos.loseAcknowledgement = true;
      await model.save();
      expect(pets.pets.length, 1);
      expect(container.read(editor).requireValue.saved, isNull);
      expect(container.read(gallery).pending.single.id, id);
      await model.save();
      expect(pets.creates, 1);
      expect(pets.updates, 0);
      expect(photos.attempts, [id, id]);
      expect(photos.photos.length, 1);
      expect(container.read(gallery).pending, isEmpty);
      expect(container.read(editor).requireValue.saved, isNotNull);
      photos.selection = null;
      await photoModel.choose(true);
      expect(container.read(gallery).pending, isEmpty);
      photos.selection = img.encodeJpg(img.Image(width: 10, height: 10));
      await photoModel.choose(true);
      await photoModel.choose(true);
      await photoModel.choose(true);
      expect(container.read(gallery).pending.length, 2);
      expect(container.read(gallery).issue, PetPhotoFailureKind.limit);
      auth.emit(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      expect(container.read(gallery).pending, isEmpty);
      expect(container.read(gallery).photos, isEmpty);
    },
  );

  for (final scenario in [
    'discard',
    'replacement',
    'retry',
    'invalid',
    'account',
    'metadata failure',
  ]) {
    test('Photos remain unchanged before confirmation: $scenario', () async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final pets = FakePets();
      pets.pets['pet'] = const Pet(
        id: 'pet',
        ownerId: 'one',
        version: 1,
        fields: PetFields(
          name: 'Luna',
          species: PetSpecies.cat,
          size: PetSize.medium,
          ageMonths: 24,
          traits: 'Blanca',
        ),
      );
      final photos = FakePetPhotos()
        ..selection = img.encodeJpg(img.Image(width: 10, height: 10));
      for (final id in ['first', 'second', 'third']) {
        photos.photos[id] = PetPhoto(
          id: id,
          petId: 'pet',
          ownerId: 'one',
          ready: true,
          uri: Uri.parse('https://example.invalid/$id.jpg'),
        );
      }
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          petRepositoryProvider.overrideWithValue(pets),
          petPhotoRepositoryProvider.overrideWithValue(photos),
        ],
      );
      final editor = petEditorViewModelProvider('pet');
      final subscription = container.listen(editor, (_, __) {});
      final gallery = petPhotosViewModelProvider('pet');
      final photoSubscription = container.listen(gallery, (_, __) {});
      addTearDown(() async {
        subscription.close();
        photoSubscription.close();
        container.dispose();
        await auth.controller.close();
      });
      await container.read(editor.future);
      final model = container.read(editor.notifier);
      final photoModel = container.read(gallery.notifier);
      photoModel.stageRemoval('first');
      expect(container.read(gallery).hasPendingChanges, isTrue);
      expect(container.read(gallery).photos, hasLength(3));
      expect(container.read(gallery).visiblePhotos, hasLength(2));
      expect(photos.photos, hasLength(3));
      expect(photos.removals, isEmpty);
      if (scenario == 'discard') {
        await photoModel.choose(true);
        photoModel.stageRemoval(container.read(gallery).pending.single.id);
        expect(photos.removals, isEmpty);
        photoModel.discardPending();
        expect(container.read(gallery).visiblePhotos, hasLength(3));
        expect(container.read(gallery).hasPendingChanges, isFalse);
        expect(photos.attempts, isEmpty);
      } else if (scenario == 'account') {
        auth.emit(const AuthSession(userId: 'two'));
        await Future<void>.delayed(Duration.zero);
        expect(container.read(gallery).pendingRemovals, isEmpty);
        expect(container.read(gallery).photos, isEmpty);
        expect(photos.removals, isEmpty);
      } else if (scenario == 'invalid') {
        model.edit(name: '');
        await model.save();
        expect(photos.removals, isEmpty);
        expect(container.read(gallery).pendingRemovals, {'first'});
        expect(container.read(editor).requireValue.invalidFields, isNotEmpty);
      } else if (scenario == 'metadata failure') {
        model.edit(name: 'Luna nueva');
        pets.fail = true;
        await model.save();
        expect(photos.removals, isEmpty);
        expect(container.read(gallery).pendingRemovals, {'first'});
        expect(container.read(editor).requireValue.saved, isNull);
      } else if (scenario == 'replacement') {
        await photoModel.choose(true);
        final id = container.read(gallery).pending.single.id;
        expect(photos.attempts, isEmpty);
        await model.save();
        expect(photos.operations, ['remove:first', 'upload:$id']);
        expect(photos.photos, hasLength(3));
        expect(container.read(gallery).hasPendingChanges, isFalse);
        expect(container.read(editor).requireValue.saved, isNotNull);
        expect(pets.updates, 0);
      } else {
        photos.failRemoval = true;
        await model.save();
        expect(photos.photos, hasLength(3));
        expect(container.read(gallery).pendingRemovals, {'first'});
        expect(container.read(editor).requireValue.saved, isNull);
        photos.failRemoval = false;
        photos.loseRemovalAcknowledgement = true;
        await model.save();
        expect(photos.photos, hasLength(2));
        expect(container.read(gallery).pendingRemovals, {'first'});
        await model.save();
        expect(photos.removals, ['first', 'first', 'first']);
        expect(container.read(gallery).hasPendingChanges, isFalse);
        expect(container.read(editor).requireValue.saved, isNotNull);
        expect(pets.updates, 0);
      }
    });
  }
}

class _LostPicker extends ImagePicker {
  _LostPicker(this.bytes);
  final Uint8List bytes;
  int calls = 0;
  @override
  Future<LostDataResponse> retrieveLostData() async {
    calls++;
    return LostDataResponse(files: [XFile.fromData(bytes, name: 'pet.jpg')]);
  }
}
