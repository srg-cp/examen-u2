import '../entities/pet.dart';
import '../failures/pet_failure.dart';
import '../repositories/pet_repository.dart';

class DeletePet {
  const DeletePet(this._repository);
  final PetRepository _repository;
  Future<void> call(String ownerId, Pet pet) {
    if (ownerId.isEmpty || pet.ownerId != ownerId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    return _repository.delete(ownerId, pet.id, pet.version);
  }
}
