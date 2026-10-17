enum PlaceSearchFailureKind { invalid, forbidden, unavailable }

class PlaceSearchFailure implements Exception {
  const PlaceSearchFailure(this.kind);
  final PlaceSearchFailureKind kind;
}
