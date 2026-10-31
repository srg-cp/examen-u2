import 'dart:async';
import 'package:geolocator/geolocator.dart';

enum DeviceLocationIssue { denied, disabled }

class DeviceLocationSource {
  const DeviceLocationSource({this.elapsed});
  final Duration Function()? elapsed;

  Future<void> _checkAccess() async {
    if (!await Geolocator.isLocationServiceEnabled().timeout(
      const Duration(seconds: 5),
    )) {
      throw DeviceLocationIssue.disabled;
    }
    var permission = await Geolocator.checkPermission().timeout(
      const Duration(seconds: 5),
    );
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission().timeout(
        const Duration(seconds: 10),
      );
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw DeviceLocationIssue.denied;
    }
  }

  Future<({double latitude, double longitude, double accuracyMeters})>
  locate() async {
    await _checkAccess();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    ).timeout(const Duration(seconds: 10));
    return (
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }

  Stream<({double latitude, double longitude, double accuracyMeters})> watch() {
    late StreamController<
      ({double latitude, double longitude, double accuracyMeters})
    >
    output;
    StreamSubscription<Position>? gps;
    Timer? firstReading;
    var cancelled = false;
    final clock = Stopwatch()..start();
    Duration? acceptedAt;
    Position? previous;

    Future<void> stop() async {
      cancelled = true;
      firstReading?.cancel();
      clock.stop();
      await gps?.cancel();
    }

    output = StreamController(
      onListen: () async {
        try {
          await _checkAccess();
          if (cancelled) return;
          // Timeout only for the first reading: being stationary is not an error.
          firstReading = Timer(const Duration(seconds: 10), () async {
            await stop();
            if (!output.isClosed) {
              output.addError(TimeoutException('No location in 10 seconds'));
              unawaited(output.close());
            }
          });
          gps =
              Geolocator.getPositionStream(
                locationSettings: AndroidSettings(
                  accuracy: LocationAccuracy.medium,
                  distanceFilter: 50,
                  intervalDuration: const Duration(seconds: 30),
                ),
              ).listen(
                (position) {
                  if (cancelled) return;
                  final last = previous;
                  final receivedAt = elapsed?.call() ?? clock.elapsed;
                  // Android's requested interval is not a strict delivery guarantee.
                  // Enforce BOTH limits against the last accepted reading as well.
                  if (last != null &&
                      (receivedAt - acceptedAt! < const Duration(seconds: 30) ||
                          Geolocator.distanceBetween(
                                last.latitude,
                                last.longitude,
                                position.latitude,
                                position.longitude,
                              ) <
                              50)) {
                    return;
                  }
                  firstReading?.cancel();
                  previous = position;
                  acceptedAt = receivedAt;
                  output.add((
                    latitude: position.latitude,
                    longitude: position.longitude,
                    accuracyMeters: position.accuracy,
                  ));
                },
                onError: (Object error, StackTrace stack) async {
                  await stop();
                  if (!output.isClosed) {
                    output.addError(error, stack);
                    unawaited(output.close());
                  }
                },
                onDone: () {
                  firstReading?.cancel();
                  unawaited(output.close());
                },
              );
        } catch (error, stack) {
          if (!cancelled && !output.isClosed) {
            output.addError(error, stack);
            unawaited(output.close());
          }
        }
      },
      onCancel: stop,
    );
    return output.stream;
  }
}
