import '../entities/current_location.dart';
import '../failures/explore_failure.dart';
import '../repositories/current_location_repository.dart';

class GetCurrentExploreLocation {
  const GetCurrentExploreLocation(this._repository);
  final CurrentLocationRepository _repository;

  Future<CurrentLocation> call() async {
    final place = await _repository.locate();
    if (!place.latitude.isFinite ||
        !place.longitude.isFinite ||
        place.latitude.abs() > 85 ||
        place.longitude.abs() > 180 ||
        !place.accuracyMeters.isFinite ||
        place.accuracyMeters < 0) {
      throw const ExploreFailure(ExploreFailureKind.unavailable);
    }
    return place;
  }
}
