import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/data_sources/device_location_source.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/repositories/current_location_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_map_location_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';

class GpsPlatformFake extends GeolocatorPlatform {
  late final positions = StreamController<Position>(
    onListen: () => active++,
    onCancel: () => active--,
  );
  int active = 0;
  LocationSettings? settings;
  Completer<bool>? permissionPending;

  @override
  Future<bool> isLocationServiceEnabled() async =>
      permissionPending == null ? true : await permissionPending!.future;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;
  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    settings = locationSettings;
    return positions.stream;
  }

  void emit(double latitude) => positions.add(
    Position(
      longitude: -70.2463,
      latitude: latitude,
      timestamp: DateTime.now(),
      accuracy: 35,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GpsPlatformFake gps;
  late GeolocatorPlatform original;
  setUp(() {
    original = GeolocatorPlatform.instance;
    gps = GpsPlatformFake();
    GeolocatorPlatform.instance = gps;
  });
  tearDown(() async {
    GeolocatorPlatform.instance = original;
    unawaited(gps.positions.close());
  });

  test(
    'medium accuracy and BOTH 30 seconds and 50 metres are required',
    () async {
      final readings = <double>[];
      var time = Duration.zero;
      final subscription = DeviceLocationSource(
        elapsed: () => time,
      ).watch().listen((point) => readings.add(point.latitude));
      await Future<void>.delayed(Duration.zero);
      final settings = gps.settings! as AndroidSettings;
      expect(settings.accuracy, LocationAccuracy.medium);
      expect(settings.intervalDuration, const Duration(seconds: 30));
      expect(settings.distanceFilter, 50);
      gps.emit(-18.0066);
      await Future<void>.delayed(Duration.zero);
      expect(readings, [-18.0066]);
      time += const Duration(seconds: 29);
      gps.emit(-18.0057); // 100 m but too early.
      await Future<void>.delayed(Duration.zero);
      expect(readings, hasLength(1));
      time += const Duration(seconds: 1);
      gps.emit(-18.0065); // 30 s but only 11 m.
      await Future<void>.delayed(Duration.zero);
      expect(readings, hasLength(1));
      gps.emit(-18.0057); // Both limits now satisfied.
      await Future<void>.delayed(Duration.zero);
      expect(readings, [-18.0066, -18.0057]);
      time += const Duration(seconds: 30);
      gps.emit(-18.0057); // Stationary remains valid, without timeout.
      await Future<void>.delayed(Duration.zero);
      expect(readings, hasLength(2));
      await subscription.cancel();
      expect(gps.active, 0);
    },
  );

  test(
    'no first reading in 10 seconds maps to locationTimeout and stops GPS',
    () async {
      Object? failure;
      final subscription = CurrentLocationRepositoryImpl(
        const DeviceLocationSource(),
      ).watch().listen((_) {}, onError: (Object error) => failure = error);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(seconds: 9));
      expect(failure, isNull);
      expect(gps.active, 1);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      expect(
        failure,
        isA<ExploreFailure>().having(
          (error) => error.kind,
          'kind',
          ExploreFailureKind.locationTimeout,
        ),
      );
      expect(gps.active, 0);
      await subscription.cancel();
    },
  );

  test(
    'leaving cancels native subscription before logging GPS detenido',
    () async {
      final logs = <String?>[];
      final oldPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message == 'GPS detenido') expect(gps.active, 0);
        logs.add(message);
      };
      addTearDown(() => debugPrint = oldPrint);
      final container = ProviderContainer(
        overrides: [
          currentLocationRepositoryProvider.overrideWithValue(
            CurrentLocationRepositoryImpl(const DeviceLocationSource()),
          ),
        ],
      );
      final listener = container.listen(exploreMapLocationProvider, (_, _) {});
      final vm = container.read(exploreMapLocationProvider.notifier);
      vm.start();
      await Future<void>.delayed(Duration.zero);
      expect(gps.active, 1);
      gps.emit(-18.0066);
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(exploreMapLocationProvider).requireValue!.accuracyMeters,
        35,
      );
      await vm.stop();
      expect(gps.active, 0);
      expect(logs, ['GPS detenido']);
      await vm.stop();
      expect(logs, hasLength(1));
      listener.close();
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    },
  );

  test(
    'leaving during access check never starts a late GPS listener',
    () async {
      gps.permissionPending = Completer<bool>();
      final subscription = const DeviceLocationSource().watch().listen((_) {});
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      gps.permissionPending!.complete(true);
      await Future<void>.delayed(Duration.zero);
      expect(gps.settings, isNull);
      expect(gps.active, 0);
    },
  );

  test(
    'tracking error replaces a previous valid reading with an error',
    () async {
      final container = ProviderContainer(
        overrides: [
          currentLocationRepositoryProvider.overrideWithValue(
            CurrentLocationRepositoryImpl(const DeviceLocationSource()),
          ),
        ],
      );
      final listener = container.listen(exploreMapLocationProvider, (_, _) {});
      addTearDown(() {
        listener.close();
        container.dispose();
      });
      final vm = container.read(exploreMapLocationProvider.notifier);
      vm.start();
      await Future<void>.delayed(Duration.zero);
      gps.emit(-18.0066);
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(exploreMapLocationProvider).asData?.value,
        isNotNull,
      );
      gps.positions.addError(DeviceLocationIssue.disabled);
      await Future<void>.delayed(Duration.zero);
      final failed = container.read(exploreMapLocationProvider);
      expect(failed.hasError, isTrue);
      expect(failed.asData, isNull);
      expect(gps.active, 0);
    },
  );

  test(
    'disposing the map provider cancels GPS while waiting for the first reading',
    () async {
      final container = ProviderContainer(
        overrides: [
          currentLocationRepositoryProvider.overrideWithValue(
            CurrentLocationRepositoryImpl(const DeviceLocationSource()),
          ),
        ],
      );
      container.listen(exploreMapLocationProvider, (_, _) {});
      container.read(exploreMapLocationProvider.notifier).start();
      await Future<void>.delayed(Duration.zero);
      expect(gps.active, 1);
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(gps.active, 0);
      // The initial 10-second timer must also have been cancelled.
      await Future<void>.delayed(const Duration(milliseconds: 10100));
      expect(gps.active, 0);
    },
  );
}
