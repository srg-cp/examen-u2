import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/failures/pet_failure.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/use_cases/create_pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/use_cases/validate_pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_list_view_model.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_pets.dart';

void main() {
  test(
    'Pet field rules trim Unicode, permit unknown values and reject incomplete/overlong data before storage',
    () async {
      final repo = FakePets();
      final create = CreatePet(repo);
      final fields = validatePet(
        PetFields(
          name: '\u00a0${'🐾' * 80}\u00a0',
          species: PetSpecies.other,
          speciesDetail: ' Conejo ',
          size: PetSize.medium,
          traits: '  ',
        ),
      );
      expect(fields.name.runes.length, 80);
      expect(fields.traits, isNull);
      expect(fields.speciesDetail, 'Conejo');
      expect(fields.size, PetSize.medium);
      expect(fields.sex, isNull);
      expect(fields.ageMonths, isNull);
      for (final f in [
        const PetFields(name: 'Luna', species: PetSpecies.other),
        const PetFields(name: ' ', species: PetSpecies.dog),
        const PetFields(name: 'Luna', species: null),
        const PetFields(name: 'Luna', species: PetSpecies.dog, ageMonths: -1),
        PetFields(name: 'Luna', species: PetSpecies.dog, traits: 'x' * 501),
      ]) {
        await expectLater(
          create('one', newPetId(), f),
          throwsA(isA<PetFailure>()),
        );
      }
      expect(repo.creates, 0);
    },
  );
  late FakeAuthRepository auth;
  late FakePets repo;
  late ProviderContainer container;
  setUp(() {
    auth = FakeAuthRepository()..current = const AuthSession(userId: 'one');
    repo = FakePets();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        petRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });
  test(
    'Create retains the UUID/draft, blocks duplicates and recovers a lost acknowledgement without a duplicate',
    () async {
      final provider = petEditorViewModelProvider('new');
      final sub = container.listen(provider, (_, _) {});
      addTearDown(sub.close);
      final list = container.listen(petListViewModelProvider, (_, _) {});
      addTearDown(list.close);
      final initial = await container.read(provider.future);
      final model = container.read(provider.notifier);
      model.edit(name: ' Luna ', species: PetSpecies.dog);
      repo.pending = Completer<void>();
      repo.ambiguousCreate = true;
      final saving = model.save();
      await model.save();
      model.edit(name: 'Ignored');
      expect(repo.creates, 1);
      expect(container.read(provider).requireValue.saved, isNull);
      repo.pending!.complete();
      await saving;
      final failed = container.read(provider).requireValue;
      expect(failed.name, ' Luna ');
      expect(failed.id, initial.id);
      expect(failed.issue, PetFailureKind.unavailable);
      await model.save();
      expect(repo.pets.length, 1);
      expect(container.read(provider).requireValue.saved!.fields.name, 'Luna');
      expect(
        (await container.read(petListViewModelProvider.future)).single.id,
        initial.id,
      );
      container.invalidate(provider);
      expect(
        (await container.read(
          petDetailViewModelProvider(initial.id).future,
        )).fields.name,
        'Luna',
      );
    },
  );
  test(
    'Edit keeps fields after failure and surfaces concurrent conflict instead of overwriting',
    () async {
      const p = Pet(
        id: 'pet-one',
        ownerId: 'one',
        fields: PetFields(name: 'Luna', species: PetSpecies.cat),
        version: 1,
      );
      repo.pets[p.id] = p;
      final details = container.listen(
        petDetailViewModelProvider(p.id),
        (_, _) {},
      );
      addTearDown(details.close);
      await container.read(petDetailViewModelProvider(p.id).future);
      final provider = petEditorViewModelProvider(p.id);
      final sub = container.listen(provider, (_, _) {});
      addTearDown(sub.close);
      await container.read(provider.future);
      final model = container.read(provider.notifier);
      model.edit(traits: 'Blanca');
      repo.fail = true;
      await model.save();
      expect(container.read(provider).requireValue.traits, 'Blanca');
      repo.fail = false;
      repo.pets[p.id] = const Pet(
        id: 'pet-one',
        ownerId: 'one',
        fields: PetFields(
          name: 'Luna',
          species: PetSpecies.cat,
          traits: 'Negra',
        ),
        version: 2,
      );
      await model.save();
      expect(
        container.read(provider).requireValue.issue,
        PetFailureKind.conflict,
      );
      expect(repo.pets[p.id]!.fields.traits, 'Negra');
      expect(
        container
            .read(petDetailViewModelProvider(p.id))
            .requireValue
            .fields
            .traits,
        isNull,
      );
      model.refreshDetail();
      expect(
        (await container.read(
          petDetailViewModelProvider(p.id).future,
        )).fields.traits,
        'Negra',
      );
      expect(container.read(provider).requireValue.traits, 'Blanca');
    },
  );
  test(
    'Account change clears pending editor and ignores old acknowledgement',
    () async {
      final provider = petEditorViewModelProvider('new');
      final sub = container.listen(provider, (_, _) {});
      addTearDown(sub.close);
      await container.read(provider.future);
      final model = container.read(provider.notifier);
      model.edit(name: 'Luna', species: PetSpecies.dog);
      repo.pending = Completer<void>();
      final saving = model.save();
      auth.emit(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      final next = await container.read(provider.future);
      expect(next.ownerId, 'two');
      expect(next.name, '');
      repo.pending!.complete();
      await saving;
      expect(container.read(provider).requireValue.saved, isNull);
    },
  );
  test(
    'List failure is not an empty result and can recover for the same account',
    () async {
      repo.fail = true;
      final sub = container.listen(petListViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      await expectLater(
        container.read(petListViewModelProvider.future),
        throwsA(isA<PetFailure>()),
      );
      repo.fail = false;
      container.read(petListViewModelProvider.notifier).reload();
      expect(await container.read(petListViewModelProvider.future), isEmpty);
    },
  );
}
