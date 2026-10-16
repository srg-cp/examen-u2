import '../entities/search_place.dart';
import '../repositories/place_search_repository.dart';
import '../failures/place_search_failure.dart';

class SearchPlaces {
  const SearchPlaces(this._repository);
  final PlaceSearchRepository _repository;
  Future<List<SearchPlace>> call(String query, {bool citiesOnly = false}) {
    final normalized = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.runes.length < 2 || normalized.runes.length > 120) {
      throw const PlaceSearchFailure(PlaceSearchFailureKind.invalid);
    }
    return _repository.search(normalized, citiesOnly: citiesOnly);
  }
}
