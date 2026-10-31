enum ExploreFailureKind {
  invalid,
  forbidden,
  unavailable,
  locationDenied,
  locationDisabled,
  locationTimeout,
}

class ExploreFailure implements Exception {
  const ExploreFailure(this.kind);
  final ExploreFailureKind kind;
}
