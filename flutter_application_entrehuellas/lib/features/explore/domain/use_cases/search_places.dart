import '../entities/search_place.dart';
import '../repositories/place_search_repository.dart';
import '../failures/explore_failure.dart';

class SearchPlaces {
  const SearchPlaces(this._repository);
  final PlaceSearchRepository _repository;
  Future<List<SearchPlace>> call(String query) {
    final normalized = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.runes.length < 2 || normalized.runes.length > 120) {
      throw const ExploreFailure(ExploreFailureKind.invalid);
    }
    return _repository.search(normalized);
  }
}
