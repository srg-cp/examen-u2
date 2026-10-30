import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/data_sources/device_location_source.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/repositories/current_location_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';

class StalledGps extends GeolocatorPlatform {
  final pending = Completer<Position>();
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;
  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) =>
      pending.future;
}

void main() {
  testWidgets(
    'A stalled native request releases the caller after ten seconds',
    (tester) async {
      final original = GeolocatorPlatform.instance;
      GeolocatorPlatform.instance = StalledGps();
      addTearDown(() => GeolocatorPlatform.instance = original);
      Object? failure;
      var completed = false;
      unawaited(
        CurrentLocationRepositoryImpl(
          const DeviceLocationSource(),
        ).locate().then(
          (_) => completed = true,
          onError: (Object error) {
            failure = error;
            completed = true;
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 9));
      expect(completed, isFalse);
      await tester.pump(const Duration(seconds: 1));
      expect(completed, isTrue);
      expect(
        failure,
        isA<ExploreFailure>().having(
          (error) => error.kind,
          'kind',
          ExploreFailureKind.locationTimeout,
        ),
      );
    },
  );
}
