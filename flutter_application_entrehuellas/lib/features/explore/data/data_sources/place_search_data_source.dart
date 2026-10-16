import '../models/search_place_dto.dart';

abstract interface class PlaceSearchDataSource {
  Future<List<SearchPlaceDto>> search(String query);
}
