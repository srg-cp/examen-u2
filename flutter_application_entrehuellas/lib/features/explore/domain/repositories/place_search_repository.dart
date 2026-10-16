import '../entities/search_place.dart';

abstract interface class PlaceSearchRepository {
  Future<List<SearchPlace>> search(String query);
}
