import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_entrehuellas/core/config/map_config.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/current_location.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_query.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_case_map.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/screens/explore_map_screen.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/repositories/current_location_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'explore_test.dart' show SearchFake;
import 'explore_map_test.dart' show capturePanel;
import 'alert_preferences_test.dart' show loadFonts;

late Uint8List tileBytes;

class MemoryTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(tileBytes);
}

class DisabledLocation implements CurrentLocationRepository {
  @override
  Future<CurrentLocation> locate() async =>
      throw const ExploreFailure(ExploreFailureKind.locationDisabled);

  // The point 2 tracking contract uses the same simulated failure.
  Stream<CurrentLocation> watch() => Stream.error(
    const ExploreFailure(ExploreFailureKind.locationDisabled),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await loadFonts();
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.white, BlendMode.src);
    final picture = recorder.endRecording();
    final raster = await picture.toImage(256, 256);
    tileBytes = (await raster.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    raster.dispose();
    picture.dispose();
  });
  const reading = CurrentLocation(
    latitude: -18.0066,
    longitude: -70.2463,
    accuracyMeters: 35,
  );
  const query = ExploreQuery(
    latitude: -18.0066,
    longitude: -70.2463,
    radiusMeters: 500,
  );

  for (final small in [false, true]) {
    testWidgets('GPS accuracy circle and visible attribution; small=$small', (
      tester,
    ) async {
      tester.view.physicalSize = small
          ? const Size(320, 350)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(
              size: tester.view.physicalSize,
              textScaler: TextScaler.linear(small ? 2 : 1),
              disableAnimations: small,
            ),
            child: Scaffold(
              body: RepaintBoundary(
                key: boundary,
                child: ExploreCaseMap(
                  items: const [],
                  query: query,
                  currentLocation: reading,
                  onOpen: null,
                  createTileProvider: MemoryTiles.new,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final picker = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
      expect(picker.circles, hasLength(1));
      final circle = picker.circles.single;
      expect(circle.point, const LatLng(-18.0066, -70.2463));
      expect(circle.radius, 35);
      expect(circle.useRadiusInMeter, isTrue);
      expect(picker.readOnly, isTrue);
      expect(find.text('Precisión ± 35 m'), findsOneWidget);
      final credit = find.text('© OpenStreetMap contributors');
      expect(credit, findsOneWidget);
      expect(
        tester.getRect(credit).bottom,
        lessThan(tester.view.physicalSize.height),
      );
      expect(
        find.text('© CARTO'),
        MapConfig.usesCarto ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
      await capturePanel(
        tester,
        boundary,
        'punto3-gps-${small ? 'small' : 'normal'}',
      );
      if (small) {
        await tester.ensureVisible(find.text('Precisión ± 35 m'));
        await tester.pumpAndSettle();
        expect(find.text('Precisión ± 35 m').hitTestable(), findsOneWidget);
        await capturePanel(tester, boundary, 'punto3-gps-small-expanded');
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'GPS failure removes old accuracy and actual map tap selects a manual point',
    (tester) async {
      final selected = <LatLng>[];
      final key = GlobalKey();
      final boundary = GlobalKey();
      Future<void> show({bool failed = false}) => tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: RepaintBoundary(
              key: boundary,
              child: ExploreCaseMap(
                key: key,
                items: const [],
                query: query,
                currentLocation: reading,
                locationUnavailable: failed,
                onManualLocationSelected: (lat, lon) =>
                    selected.add(LatLng(lat, lon)),
                onOpen: null,
                createTileProvider: MemoryTiles.new,
              ),
            ),
          ),
        ),
      );
      await show();
      await tester.pumpAndSettle();
      expect(find.text('Precisión ± 35 m'), findsOneWidget);
      // The last successful reading still exists upstream, but is no longer valid.
      await show(failed: true);
      await tester.pumpAndSettle();
      var picker = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
      expect(picker.circles, isEmpty);
      await capturePanel(tester, boundary, 'punto3-sin-gps-normal');
      expect(picker.readOnly, isFalse);
      expect(find.text('Precisión ± 35 m'), findsNothing);
      expect(
        find.text('Toca el mapa para elegir tu ubicación.'),
        findsOneWidget,
      );

      final map = find.byType(FlutterMap);
      final touch = tester.getTopLeft(map) + const Offset(160, 90);
      final camera = MapCamera.of(tester.element(find.byType(TileLayer)));
      final expected = camera.screenOffsetToLatLng(
        touch - tester.getTopLeft(map),
      );
      await tester.tapAt(touch);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(selected, hasLength(1));
      expect(selected.single.latitude, closeTo(expected.latitude, .000001));
      expect(selected.single.longitude, closeTo(expected.longitude, .000001));
      expect(
        find.textContaining('Ubicación elegida en el mapa'),
        findsOneWidget,
      );
      picker = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
      expect(picker.showCenterMarker, isTrue);
      expect(picker.circles, isEmpty);
      await capturePanel(tester, boundary, 'punto3-manual-normal');

      await show();
      await tester.pumpAndSettle();
      expect(find.textContaining('Ubicación elegida en el mapa'), findsNothing);
      expect(find.text('Precisión ± 35 m'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('No initial GPS and no query still render a selectable map', (
    tester,
  ) async {
    final selected = <LatLng>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ExploreCaseMap(
            items: const [],
            query: const ExploreQuery(),
            onOpen: null,
            locationUnavailable: true,
            onManualLocationSelected: (lat, lon) =>
                selected.add(LatLng(lat, lon)),
            createTileProvider: MemoryTiles.new,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
    await tester.tapAt(
      tester.getTopLeft(find.byType(FlutterMap)) + const Offset(150, 90),
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(selected, hasLength(1));
    expect(find.textContaining('Precisión ±'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'The real map screen explains GPS failure and searches the tapped location',
    (tester) async {
      final cases = SearchFake();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreRepositoryProvider.overrideWithValue(cases),
            currentLocationRepositoryProvider.overrideWithValue(
              DisabledLocation(),
            ),
            exploreSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'exam')),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ExploreMapScreen(createTileProvider: MemoryTiles.new),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Activa la ubicación del dispositivo'),
        findsOneWidget,
      );
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(cases.calls, isEmpty);
      await tester.tapAt(
        tester.getTopLeft(find.byType(FlutterMap)) + const Offset(150, 90),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(cases.calls, hasLength(1));
      expect(cases.calls.single.$2.latitude, isNotNull);
      expect(cases.calls.single.$2.longitude, isNotNull);
      expect(
        find.textContaining('Ubicación elegida en el mapa'),
        findsOneWidget,
      );
      expect(find.textContaining('Precisión ±'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
