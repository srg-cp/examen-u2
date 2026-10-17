import '../../domain/entities/search_place.dart';
import '../../domain/failures/place_search_failure.dart';
import '../../domain/repositories/place_search_repository.dart';

class UnavailablePlaceSearchRepository implements PlaceSearchRepository {
  const UnavailablePlaceSearchRepository();
  @override
  Future<List<SearchPlace>> search(
    String query, {
    bool citiesOnly = false,
  }) async =>
      throw const PlaceSearchFailure(PlaceSearchFailureKind.unavailable);
}
