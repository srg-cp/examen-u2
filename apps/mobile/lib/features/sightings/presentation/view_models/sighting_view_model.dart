import 'dart:async';
import '../../../offline_drafts/providers/local_draft_providers.dart';
import '../state/sighting_local_draft.dart';
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
  Object? _checkpointKey;
  void Function()? _stopObserving;
  String _slot = "";
  Future<bool> discardLocalDraft(String expectedId) async {
    final value = state.asData?.value;
    if (value == null ||
        value.id != expectedId ||
        value.busy ||
        value.frozen != null) {
      return false;
    }
    final generation = _generation;
    final remove = ref.read(removeLocalDraftProvider);
    final slot = _slot;
    final keep = ref.keepAlive();
    state = AsyncData(value.copy(busy: true));
    try {
      await remove(value.owner, slot, value.id);
      if (!_current(generation, value.owner)) return false;
      ref.invalidateSelf();
      return true;
    } catch (_) {
      if (_current(generation, value.owner)) {
        state = AsyncData(
          state.requireValue.copy(
            busy: false,
            failure: const SightingFailure(SightingIssue.localStorage),
          ),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }

  Future<bool> saveForLater() async {
    final value = state.asData?.value;
    if (value == null || state.isLoading) return false;
    final generation = _generation;
    final saved = await _saveLocal(value);
    if (saved &&
        _current(generation, value.owner) &&
        state.requireValue.issue == SightingIssue.localStorage) {
      state = AsyncData(state.requireValue.copy());
    }
    return saved;
  }

  Future<bool> _saveLocal(SightingState value) async {
    if (!value.dirty && value.frozen == null) return true;
    final generation = _generation;
    final slot = _slot;
    final save = ref.read(saveLocalDraftProvider);
    final keep = ref.keepAlive();
    try {
      await save(sightingLocalDraft(value, slot));
      return true;
    } catch (_) {
      if (_current(generation, value.owner) &&
          sightingCheckpointKey(state.requireValue) ==
              sightingCheckpointKey(value)) {
        state = AsyncData(
          state.requireValue.copy(
            failure: const SightingFailure(SightingIssue.localStorage),
          ),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }

  void _observeDraft() {
    _checkpointKey = null;
    _stopObserving?.call();
    final generation = _generation;
    _stopObserving = listenSelf((previous, next) {
      if (generation != _generation) return;
      final value = next.asData?.value;
      if (next.isLoading || value == null) return;
      final key = sightingCheckpointKey(value);
      if (_checkpointKey == key) return;
      _checkpointKey = key;
      if (value.receipt != null) {
        final remove = ref.read(removeLocalDraftProvider);
        unawaited(
          remove(value.owner, _slot, value.id).catchError((Object _) {
            // The receipt remains confirmed. An undeleted exact command is safe to replay.
          }),
        );
      } else {
        unawaited(_saveLocal(value));
      }
    });
  }

  @override
  Future<SightingState> build() async {
    final generation = ++_generation;
    final target = ref.watch(sightingTargetProvider);
    _slot = sightingDraftSlot(target);
    final session = await ref.watch(sightingSessionProvider.future);
    if (!ref.mounted || generation != _generation) {
      throw const SightingFailure(SightingIssue.forbidden);
    }
    if (session == null) throw const SightingFailure(SightingIssue.forbidden);
    _observeDraft();
    final local = await ref.read(readLocalDraftProvider)(session.userId, _slot);
    return local == null
        ? SightingState(owner: session.userId, id: newEntityId())
        : restoreSightingLocalDraft(local, target);
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
      if (!await _saveLocal(state.requireValue)) {
        if (_current(generation, v.owner)) {
          state = AsyncData(
            state.requireValue.copy(
              busy: false,
              failure: const SightingFailure(SightingIssue.localStorage),
            ),
          );
        }
        return;
      }
      if (!_current(generation, v.owner)) return;
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
              SightingIssue.blocked,
            }.contains(failure.issue),
          ),
        );
      }
    } finally {
      keep.close();
    }
  }
}
