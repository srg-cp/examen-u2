import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../../domain/repositories/pet_repository.dart';

class UnavailablePetRepository implements PetRepository {
  const UnavailablePetRepository();
  @override
  Future<void> delete(
    String ownerId,
    String petId,
    int expectedVersion,
  ) async => throw const PetFailure(PetFailureKind.unavailable);
  Never _fail() => throw const PetFailure(PetFailureKind.unavailable);
  @override
  Future<List<Pet>> list(String ownerId) async => _fail();
  @override
  Future<Pet> read(String ownerId, String petId) async => _fail();
  @override
  Future<Pet> create(String ownerId, String petId, PetFields fields) async =>
      _fail();
  @override
  Future<Pet> update(
    String ownerId,
    String petId,
    int expectedVersion,
    PetFields fields,
  ) async => _fail();
}
