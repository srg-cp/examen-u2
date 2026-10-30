import '../../domain/entities/current_location.dart';
import '../../domain/failures/explore_failure.dart';
import '../../domain/repositories/current_location_repository.dart';
import '../data_sources/device_location_source.dart';

class CurrentLocationRepositoryImpl implements CurrentLocationRepository {
  const CurrentLocationRepositoryImpl(this._source);
  final DeviceLocationSource _source;

  @override
  Future<CurrentLocation> locate() async {
    try {
      final point = await _source.locate();
      return CurrentLocation(
        latitude: point.latitude,
        longitude: point.longitude,
        accuracyMeters: point.accuracyMeters,
      );
    } catch (error) {
      throw ExploreFailure(switch (error) {
        DeviceLocationIssue.denied => ExploreFailureKind.locationDenied,
        DeviceLocationIssue.disabled => ExploreFailureKind.locationDisabled,
        _ => ExploreFailureKind.unavailable,
      });
    }
  }
}

class UnavailableCurrentLocationRepository
    implements CurrentLocationRepository {
  const UnavailableCurrentLocationRepository();
  @override
  Future<CurrentLocation> locate() async =>
      throw const ExploreFailure(ExploreFailureKind.unavailable);
}
