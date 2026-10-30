import 'dart:async';
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
        TimeoutException() => ExploreFailureKind.locationTimeout,
        _ => ExploreFailureKind.unavailable,
      });
    }
  }

  @override
  Stream<CurrentLocation> watch() => _source
      .watch()
      .map(
        (point) => CurrentLocation(
          latitude: point.latitude,
          longitude: point.longitude,
          accuracyMeters: point.accuracyMeters,
        ),
      )
      .handleError((Object error) {
        throw ExploreFailure(switch (error) {
          DeviceLocationIssue.denied => ExploreFailureKind.locationDenied,
          DeviceLocationIssue.disabled => ExploreFailureKind.locationDisabled,
          TimeoutException() => ExploreFailureKind.locationTimeout,
          _ => ExploreFailureKind.unavailable,
        });
      });
}

class UnavailableCurrentLocationRepository
    implements CurrentLocationRepository {
  const UnavailableCurrentLocationRepository();
  @override
  Future<CurrentLocation> locate() async =>
      throw const ExploreFailure(ExploreFailureKind.unavailable);
  @override
  Stream<CurrentLocation> watch() =>
      Stream.error(const ExploreFailure(ExploreFailureKind.unavailable));
}
