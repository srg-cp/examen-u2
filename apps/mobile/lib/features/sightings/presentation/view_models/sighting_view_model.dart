import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/sighting.dart';
import '../../providers/sighting_providers.dart';
import '../state/sighting_state.dart';

final sightingViewModelProvider =
    AsyncNotifierProvider.autoDispose<SightingViewModel, SightingState>(
      SightingViewModel.new,
      dependencies: [sightingTargetProvider],
      retry: (_, _) => null,
    );

class SightingViewModel extends AsyncNotifier<SightingState> {
  int _generation = 0;
  @override
  Future<SightingState> build() async {
    _generation++;
    ref.watch(sightingTargetProvider);
    final session = await ref.watch(sightingSessionProvider.future);
    if (session == null) throw const SightingFailure(SightingIssue.forbidden);
    return SightingState(owner: session.userId, id: newEntityId());
  }

  bool _current(int generation, String owner) =>
      ref.mounted &&
      generation == _generation &&
      !state.isLoading &&
      state.asData?.value.owner == owner;
  void retry() => ref.invalidateSelf();
  void comment(String text) {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    state = AsyncData(v!.copy(comment: text, dirty: true));
  }

  void date(DateTime date) {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    state = AsyncData(
      v!.copy(dateTime: v.dateTime.withDate(date), dirty: true),
    );
  }

  void time(int hour, int minute) {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    state = AsyncData(
      v!.copy(dateTime: v.dateTime.withTime(hour, minute), dirty: true),
    );
  }

  void point(double latitude, double longitude) {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    state = AsyncData(
      v!.copy(point: SightingPoint(latitude, longitude), dirty: true),
    );
  }

  void removePhoto() {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    state = AsyncData(v!.copy(removePhoto: true, dirty: true));
  }

  Future<void> locate() async {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    final generation = _generation;
    state = AsyncData(v!.copy(busy: true));
    try {
      final point = await ref.read(locateSightingProvider)();
      if (_current(generation, v.owner)) {
        state = AsyncData(
          state.requireValue.copy(point: point, busy: false, dirty: true),
        );
      }
    } catch (_) {
      if (_current(generation, v.owner)) {
        state = AsyncData(
          state.requireValue.copy(
            busy: false,
            failure: const SightingFailure(SightingIssue.location),
          ),
        );
      }
    }
  }

  Future<void> photo({bool camera = false}) async {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    final generation = _generation;
    state = AsyncData(v!.copy(busy: true));
    try {
      final bytes = await ref.read(chooseSightingPhotoProvider)(camera: camera);
      if (_current(generation, v.owner)) {
        state = AsyncData(
          state.requireValue.copy(
            photo: bytes,
            busy: false,
            dirty: v.dirty || bytes != null,
          ),
        );
      }
    } catch (_) {
      if (_current(generation, v.owner)) {
        state = AsyncData(
          state.requireValue.copy(
            busy: false,
            failure: const SightingFailure(SightingIssue.photo, {'photo'}),
          ),
        );
      }
    }
  }

  Future<void> submit() async {
    final v = state.asData?.value;
    if (v == null ||
        state.isLoading ||
        v.busy ||
        v.receipt != null ||
        v.issue == SightingIssue.closed) {
      return;
    }
    if (v.frozen == null && (v.dateTime.value == null || v.point == null)) {
      state = AsyncData(
        v.copy(
          failure: SightingFailure(SightingIssue.invalid, {
            if (v.dateTime.value == null) 'observedAt',
            if (v.point == null) 'point',
          }),
        ),
      );
      return;
    }
    final draft =
        v.frozen ??
        SightingDraft(
          id: v.id,
          target: ref.read(sightingTargetProvider),
          observedAt: v.dateTime.value!,
          point: v.point!,
          comment: v.comment,
          photo: v.photo,
        );
    final generation = _generation, keep = ref.keepAlive();
    state = AsyncData(v.copy(busy: true, frozen: draft));
    try {
      final receipt = await ref
          .read(submitSightingProvider)(v.owner, draft)
          .timeout(const Duration(seconds: 60));
      if (_current(generation, v.owner)) {
        state = AsyncData(
          state.requireValue.copy(busy: false, receipt: receipt, dirty: false),
        );
      }
    } catch (error) {
      var failure = error is SightingFailure
          ? error
          : const SightingFailure(SightingIssue.unavailable);
      if (failure.issue == SightingIssue.photo && failure.fields.isEmpty) {
        failure = const SightingFailure(SightingIssue.photo, {'photo'});
      }
      if (_current(generation, v.owner)) {
        state = AsyncData(
          state.requireValue.copy(
            busy: false,
            failure: failure,
            unfreeze: {
              SightingIssue.invalid,
              SightingIssue.photo,
              SightingIssue.rateLimited,
            }.contains(failure.issue),
          ),
        );
      }
    } finally {
      keep.close();
    }
  }
}
