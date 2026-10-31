import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/current_location.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/repositories/current_location_repository.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_map_location_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';

/// Replaces the device GPS without importing geolocator or using an emulator.
class UbicacionSimulada implements CurrentLocationRepository {
  final lecturas = StreamController<CurrentLocation>();
  int solicitudes = 0;

  @override
  Stream<CurrentLocation> watch() {
    solicitudes++;
    return lecturas.stream;
  }

  @override
  Future<CurrentLocation> locate() {
    solicitudes++;
    throw StateError('Estas pruebas usan el seguimiento del mapa.');
  }
}

void main() {
  late UbicacionSimulada gps;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<CurrentLocation?>> listener;

  setUp(() {
    gps = UbicacionSimulada();
    container = ProviderContainer(
      overrides: [currentLocationRepositoryProvider.overrideWithValue(gps)],
    );
    listener = container.listen(exploreMapLocationProvider, (_, _) {});
  });

  tearDown(() async {
    await container.read(exploreMapLocationProvider.notifier).stop();
    listener.close();
    container.dispose();
    // A controller never listened to (test a) cannot finish close's future.
    unawaited(gps.lecturas.close());
  });

  test('a) Crear el ViewModel no solicita ninguna ubicacion', () {
    container.read(exploreMapLocationProvider.notifier);

    expect(gps.solicitudes, 0);
    final estado = container.read(exploreMapLocationProvider);
    expect(estado.hasError, isFalse);
    expect(estado.requireValue, isNull);
  });

  test('b) El estado expone -18.0066, -70.2463 y precision de 35 m', () async {
    container.read(exploreMapLocationProvider.notifier).start();
    gps.lecturas.add(
      const CurrentLocation(
        latitude: -18.0066,
        longitude: -70.2463,
        accuracyMeters: 35,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final ubicacion = container.read(exploreMapLocationProvider).requireValue!;
    expect(ubicacion.latitude, -18.0066);
    expect(ubicacion.longitude, -70.2463);
    expect(ubicacion.accuracyMeters, 35);
    expect(gps.solicitudes, 1);
  });

  test(
    'c) GPS apagado habilita eleccion manual con una sola solicitud',
    () async {
      container.read(exploreMapLocationProvider.notifier).start();
      gps.lecturas.addError(
        const ExploreFailure(ExploreFailureKind.locationDisabled),
      );
      await Future<void>.delayed(Duration.zero);

      final estado = container.read(exploreMapLocationProvider);
      expect(
        estado.error,
        isA<ExploreFailure>().having(
          (error) => error.kind,
          'motivo',
          ExploreFailureKind.locationDisabled,
        ),
      );
      // ExploreMapScreen passes this exact state flag to locationUnavailable,
      // which enables map selection instead of displaying an old GPS reading.
      expect(estado.hasError, isTrue);
      expect(estado.asData?.value, isNull);
      expect(gps.solicitudes, 1);
    },
  );
}
