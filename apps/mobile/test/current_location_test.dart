import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/data_sources/device_location_source.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/repositories/current_location_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/use_cases/get_current_explore_location.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'explore_test.dart' show SearchFake;

class SimulatedDeviceLocationSource extends DeviceLocationSource {
  double accuracy = 35;

  @override
  Future<({double latitude, double longitude, double accuracyMeters})>
  locate() async =>
      (latitude: -18.0066, longitude: -70.2463, accuracyMeters: accuracy);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'GPS coordinates and accuracy reach the ViewModel without a GPS plugin',
    () async {
      final repository = CurrentLocationRepositoryImpl(
        SimulatedDeviceLocationSource(),
      );
      final cases = SearchFake();
      final container = ProviderContainer(
        overrides: [
          currentLocationRepositoryProvider.overrideWithValue(repository),
          exploreRepositoryProvider.overrideWithValue(cases),
          exploreSessionProvider.overrideWith(
            (_) => Stream.value(const AuthSession(userId: 'exam-user')),
          ),
        ],
      );
      final subscription = container.listen(
        exploreViewModelProvider,
        (_, _) {},
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });

      final initial = await container.read(exploreViewModelProvider.future);
      expect(initial.currentLocation!.latitude, -18.0066);
      expect(initial.currentLocation!.longitude, -70.2463);
      expect(initial.currentLocation!.accuracyMeters, 35);
      expect(cases.calls.single.$2.latitude, -18.0066);

      await container.read(exploreViewModelProvider.notifier).refresh();
      expect(
        container.read(exploreViewModelProvider).requireValue.currentLocation,
        same(initial.currentLocation),
      );

      // A failed case query must not erase a successful GPS reading.
      cases.fail = true;
      await container
          .read(exploreViewModelProvider.notifier)
          .useCurrentLocation();
      final failed = container.read(exploreViewModelProvider).requireValue;
      expect(failed.failed, isTrue);
      expect(failed.currentLocation!.accuracyMeters, 35);
      expect(failed.currentLocation!.longitude, -70.2463);
    },
  );

  test('The location use case rejects invalid GPS accuracy', () async {
    final source = SimulatedDeviceLocationSource()..accuracy = double.nan;
    final locate = GetCurrentExploreLocation(
      CurrentLocationRepositoryImpl(source),
    );
    await expectLater(locate(), throwsA(isA<ExploreFailure>()));
  });
}
