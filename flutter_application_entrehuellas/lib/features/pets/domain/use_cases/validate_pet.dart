import '../entities/pet.dart';
import '../failures/pet_failure.dart';

PetFields validatePet(PetFields value) {
  final name = value.name.trim();
  final traits = value.traits?.trim();
  final detail = value.speciesDetail?.trim();
  if (value.species == PetSpecies.other &&
      (detail == null || detail.isEmpty || detail.runes.length > 60)) {
    throw const PetFailure(PetFailureKind.invalidSpeciesDetail);
  }
  if (name.isEmpty || name.runes.length > 80) {
    throw const PetFailure(PetFailureKind.invalidName);
  }
  if (value.species == null) {
    throw const PetFailure(PetFailureKind.invalidSpecies);
  }
  if (value.ageMonths != null &&
      (value.ageMonths! < 0 || value.ageMonths! > 600)) {
    throw const PetFailure(PetFailureKind.invalidAge);
  }
  if (traits != null && traits.runes.length > 500) {
    throw const PetFailure(PetFailureKind.invalidTraits);
  }
  return PetFields(
    speciesDetail: value.species == PetSpecies.other ? detail : null,
    size: value.size,
    name: name,
    species: value.species,
    sex: value.sex,
    ageMonths: value.ageMonths,
    traits: traits == null || traits.isEmpty ? null : traits,
  );
}
