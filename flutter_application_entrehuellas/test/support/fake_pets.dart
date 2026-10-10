import 'dart:async';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/failures/pet_failure.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/repositories/pet_repository.dart';

class FakePets implements PetRepository {
  final pets = <String, Pet>{};
  Completer<void>? pending;
  Completer<void>? pendingList;
  Completer<void>? pendingRead;
  bool fail = false;
  bool ambiguousCreate = false;
  int creates = 0;
  int updates = 0;
  int reads = 0;
  int deletes = 0;
  bool ambiguousDelete = false;
  @override
  Future<void> delete(String ownerId, String petId, int expectedVersion) async {
    deletes++;
    await pending?.future;
    if (fail) throw const PetFailure(PetFailureKind.unavailable);
    final pet = pets[petId];
    if (pet != null && pet.ownerId != ownerId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    if (pet != null && pet.version != expectedVersion) {
      throw const PetFailure(PetFailureKind.conflict);
    }
    pets.remove(petId);
    if (ambiguousDelete) {
      ambiguousDelete = false;
      throw const PetFailure(PetFailureKind.unavailable);
    }
  }

  @override
  Future<List<Pet>> list(String ownerId) async {
    await pendingList?.future;
    if (fail) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
    return pets.values.where((p) => p.ownerId == ownerId).toList();
  }

  @override
  Future<Pet> read(String ownerId, String petId) async {
    reads++;
    await pendingRead?.future;
    if (fail) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
    final p = pets[petId];
    if (p == null || p.ownerId != ownerId) {
      throw const PetFailure(PetFailureKind.missing);
    }
    return p;
  }

  @override
  Future<Pet> create(String ownerId, String petId, PetFields fields) async {
    creates++;
    await pending?.future;
    if (fail) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
    final pet =
        pets[petId] ??
        Pet(id: petId, ownerId: ownerId, fields: fields, version: 1);
    pets[petId] = pet;
    if (ambiguousCreate) {
      ambiguousCreate = false;
      throw const PetFailure(PetFailureKind.unavailable);
    }
    return pet;
  }

  @override
  Future<Pet> update(
    String ownerId,
    String petId,
    int expectedVersion,
    PetFields fields,
  ) async {
    updates++;
    await pending?.future;
    if (fail) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
    final old = await read(ownerId, petId);
    if (old.version != expectedVersion) {
      throw const PetFailure(PetFailureKind.conflict);
    }
    return pets[petId] = Pet(
      id: petId,
      ownerId: ownerId,
      fields: fields,
      version: old.version + 1,
    );
  }
}
