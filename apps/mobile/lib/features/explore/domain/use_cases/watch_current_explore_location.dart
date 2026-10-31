import '../entities/current_location.dart';
import '../repositories/current_location_repository.dart';

class WatchCurrentExploreLocation {
  const WatchCurrentExploreLocation(this._repository);
  final CurrentLocationRepository _repository;

  Stream<CurrentLocation> call() => _repository.watch();
}
