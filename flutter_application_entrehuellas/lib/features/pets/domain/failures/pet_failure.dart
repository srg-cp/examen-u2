enum PetFailureKind {
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

final class PetFailure implements Exception {
  const PetFailure(this.kind);
  final PetFailureKind kind;
}
