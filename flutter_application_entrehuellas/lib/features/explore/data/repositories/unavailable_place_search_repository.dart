import '../../domain/entities/search_place.dart';
import '../../domain/failures/explore_failure.dart';
import '../../domain/repositories/place_search_repository.dart';

class UnavailablePlaceSearchRepository implements PlaceSearchRepository {
  const UnavailablePlaceSearchRepository();
  @override
  Future<List<SearchPlace>> search(String query) async =>
      throw const ExploreFailure(ExploreFailureKind.unavailable);
}
