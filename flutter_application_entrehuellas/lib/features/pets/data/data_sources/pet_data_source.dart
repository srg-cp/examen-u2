import '../models/pet_dto.dart';

enum PetSourceFailureKind {
  unavailable,
  signedOut,
  missing,
  forbidden,
  conflict,
  invalidName,
  invalidSpecies,
  invalidAge,
  invalidTraits,
  invalidSpeciesDetail,
}

class PetSourceFailure implements Exception {
  const PetSourceFailure(this.kind);
  final PetSourceFailureKind kind;
}

abstract interface class PetDataSource {
  Future<void> delete(String ownerId, String petId, int expectedVersion);
  Future<List<PetDto>> list(String ownerId);
  Future<PetDto> read(String ownerId, String petId);
  Future<PetDto> create(
    String ownerId,
    String petId, {
    required String name,
    required String species,
    String? sex,
    int? ageMonths,
    String? traits,
    String? speciesDetail,
    String? size,
  });
  Future<PetDto> update(
    String ownerId,
    String petId,
    int expectedVersion, {
    required String name,
    required String species,
    String? sex,
    int? ageMonths,
    String? traits,
    String? speciesDetail,
    String? size,
  });
}
