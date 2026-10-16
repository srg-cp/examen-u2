import 'dart:async';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/search_place.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/repositories/place_search_repository.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';

class FakePlaceSearch implements PlaceSearchRepository {
  final queries = <String>[];
  bool fail = false;
  Completer<List<SearchPlace>>? pending;
  static const place = SearchPlace(
    label: 'Miraflores, Lima, Perú',
    latitude: -12.12,
    longitude: -77.03,
  );
  @override
  Future<List<SearchPlace>> search(String query) async {
    queries.add(query);
    if (fail) throw const ExploreFailure(ExploreFailureKind.unavailable);
    if (pending != null) return pending!.future;
    return const [place];
  }
}
