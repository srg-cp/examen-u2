import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/current_location.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_query.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/screens/explore_map_screen.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/state/explore_state.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_map_location_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_case_map.dart';

const point = CurrentLocation(
  latitude: -18.0066,
  longitude: -70.2463,
  accuracyMeters: 35,
);

class FixedExplore extends ExploreViewModel {
  @override
  Future<ExploreState> build() async => ExploreState(
    owner: 'exam',
    query: const ExploreQuery(
      latitude: -18.0066,
      longitude: -70.2463,
      radiusMeters: 15000,
    ),
    items: const [],
    currentLocation: point,
  );
}

class ScriptedTracking extends ExploreMapLocationViewModel {
  @override
  AsyncValue<CurrentLocation?> build() => const AsyncData(point);
  @override
  void start() {}
  void timeout() => state = AsyncError(
    const ExploreFailure(ExploreFailureKind.locationTimeout),
    StackTrace.current,
  );
}

class OfflineTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      const AssetImage('assets/branding/app_icon.png');
}

void main() {
  testWidgets('timeout shows Tiempo agotado and removes old GPS coordinates', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        exploreViewModelProvider.overrideWith(FixedExplore.new),
        exploreMapLocationProvider.overrideWith(ScriptedTracking.new),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: ExploreMapScreen(createTileProvider: OfflineTiles.new),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<ExploreCaseMap>(find.byType(ExploreCaseMap))
          .currentLocation,
      same(point),
    );
    (container.read(exploreMapLocationProvider.notifier) as ScriptedTracking)
        .timeout();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Tiempo agotado'), findsOneWidget);
    expect(
      tester
          .widget<ExploreCaseMap>(find.byType(ExploreCaseMap))
          .currentLocation,
      isNull,
    );
    expect(find.textContaining('Latitud:'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
