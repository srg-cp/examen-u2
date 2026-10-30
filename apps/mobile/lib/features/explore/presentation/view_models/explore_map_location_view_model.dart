import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/current_location.dart';
import '../../providers/explore_providers.dart';

final exploreMapLocationProvider =
    NotifierProvider.autoDispose<
      ExploreMapLocationViewModel,
      AsyncValue<CurrentLocation?>
    >(ExploreMapLocationViewModel.new);

class ExploreMapLocationViewModel
    extends Notifier<AsyncValue<CurrentLocation?>> {
  StreamSubscription<CurrentLocation>? _gps;
  int _generation = 0;

  @override
  AsyncValue<CurrentLocation?> build() {
    ref.onDispose(() => unawaited(stop()));
    return const AsyncData(null);
  }

  void start() {
    if (_gps != null) return;
    final generation = ++_generation;
    _gps = ref
        .read(watchCurrentExploreLocationProvider)()
        .listen(
          (location) {
            if (ref.mounted && generation == _generation) {
              state = AsyncData(location);
            }
          },
          onError: (Object error, StackTrace stack) {
            if (ref.mounted && generation == _generation) {
              state = AsyncError(error, stack);
            }
            unawaited(stop());
          },
        );
  }

  Future<void> stop() async {
    ++_generation;
    final gps = _gps;
    _gps = null;
    if (gps == null) return;
    await gps.cancel();
    debugPrint('GPS detenido');
  }
}
