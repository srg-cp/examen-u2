import '../domain/repositories/place_search_repository.dart';
import '../domain/repositories/current_location_repository.dart';
import '../domain/use_cases/get_current_explore_location.dart';
import '../domain/use_cases/search_places.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/explore_repository.dart';
import '../domain/use_cases/search_cases.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>(
  (ref) => throw StateError('ExploreRepository must be injected'),
);
final searchCasesProvider = Provider(
  (ref) => SearchCases(ref.watch(exploreRepositoryProvider)),
);
final exploreSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);

final placeSearchRepositoryProvider = Provider<PlaceSearchRepository>(
  (ref) => throw StateError('PlaceSearchRepository must be injected'),
);
final searchPlacesProvider = Provider(
  (ref) => SearchPlaces(ref.watch(placeSearchRepositoryProvider)),
);

final currentLocationRepositoryProvider = Provider<CurrentLocationRepository>(
  (ref) => throw StateError('CurrentLocationRepository must be injected'),
);
final getCurrentExploreLocationProvider = Provider(
  (ref) =>
      GetCurrentExploreLocation(ref.watch(currentLocationRepositoryProvider)),
);
