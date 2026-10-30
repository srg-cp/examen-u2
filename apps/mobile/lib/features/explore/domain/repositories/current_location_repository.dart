import '../entities/current_location.dart';

abstract class CurrentLocationRepository {
  Future<CurrentLocation> locate();
}
