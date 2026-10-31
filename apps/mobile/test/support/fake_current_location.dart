import 'package:flutter_application_entrehuellas/features/explore/domain/entities/current_location.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/repositories/current_location_repository.dart';

class FakeCurrentLocation implements CurrentLocationRepository {
  const FakeCurrentLocation();
  @override
  Stream<CurrentLocation> watch() => Stream.fromFuture(locate());
  @override
  Future<CurrentLocation> locate() async => const CurrentLocation(
    accuracyMeters: 35,
    latitude: -12.05,
    longitude: -77.05,
  );
}
