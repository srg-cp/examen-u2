import '../../../../core/presentation/state/event_date_time_draft.dart';
import 'recovery_case_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/found_case.dart';
import '../../providers/found_case_providers.dart';
import '../state/found_editor_state.dart';
import 'found_read_view_model.dart';

final foundEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<FoundEditorViewModel, FoundEditorState>(
      FoundEditorViewModel.new,
      dependencies: [foundEditorContextProvider],
      retry: (_, _) => null,
    );

class FoundEditorViewModel extends AsyncNotifier<FoundEditorState> {
  FoundEditorViewModel({Duration? operationTimeout})
    : _operationTimeout = operationTimeout ?? const Duration(seconds: 90);
  final Duration _operationTimeout;
  bool get communitySearch =>
      ref.read(foundEditorContextProvider).communitySearch;
  int _generation = 0;
  @override
  Future<FoundEditorState> build() async {
    _generation++;
    final session = await ref.watch(foundSessionProvider.future);
    if (session == null) throw const FoundFailure(FoundFailureKind.forbidden);
    final context = ref.watch(foundEditorContextProvider);
    final target = context.communitySearch
        ? null
        : await ref.watch(readRecoverySearchProvider)(
            context.targetId ?? '',
            context.communityTarget,
          );
    final value = FoundEditorState(
      ownerId: session.userId,
      draftId: newEntityId(),
      communitySearch: context.communitySearch,
      reportKind: context.communitySearch ? 'possible_loss' : 'sighting',
      target: target,
    );
    return target == null
        ? value
        : value.copyWith(
            targetId: target.id,
            communityTarget: target.community,
            species: target.species,
            speciesDetail: target.speciesDetail,
            size: target.size,
            sex: target.sex,
          );
  }

  void retry() => ref.invalidateSelf();
  bool _current(int g, String owner) =>
      ref.mounted &&
      g == _generation &&
      !state.isLoading &&
      state.asData?.value.ownerId == owner;
  bool _editable(FoundEditorState? v) =>
      v != null &&
      !state.isLoading &&
      !v.busy &&
      v.lockedDraft == null &&
      v.issue != FoundFailureKind.targetClosed &&
      v.stage != FoundStage.confirmed;
  void chooseObservation(String kind) {
    final value = state.asData?.value;
    if (!_editable(value) ||
        value!.communitySearch ||
        !{'sighting', 'with_reporter'}.contains(kind)) {
      return;
    }
    state = AsyncData(
      value.copyWith(
        reportKind: kind,
        custody: kind == 'with_reporter' ? 'with_me' : 'not_with_me',
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  /// Restores report fields without changing animal data or photos.
  void restoreReportDetails({
    required String ownerId,
    required EventDateTimeDraft dateTime,
    required double? latitude,
    required double? longitude,
    required String placeReference,
  }) {
    final current = state.asData?.value;
    if (!_editable(current) || current!.ownerId != ownerId) return;
    final hasDetails =
        dateTime.date != null ||
        dateTime.hour != null ||
        latitude != null ||
        longitude != null ||
        placeReference.isNotEmpty;
    state = AsyncData(
      current.copyWith(
        dateTimeDraft: dateTime,
        latitude: latitude,
        longitude: longitude,
        clearPoint: latitude == null && longitude == null,
        placeReference: placeReference,
        dirty: current.dirty || hasDetails,
        clearIssue: true,
      ),
    );
  }

  void chooseDate(DateTime date) {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    state = AsyncData(
      current!.copyWith(
        dateTimeDraft: current.dateTimeDraft.withDate(date),
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  void chooseTime(int hour, int minute) {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    state = AsyncData(
      current!.copyWith(
        dateTimeDraft: current.dateTimeDraft.withTime(hour, minute),
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  void edit({
    String? species,
    String? speciesDetail,
    String? size,
    String? sex,
    String? traits,
    String? custody,
    String? placeReference,
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
  }) {
    final v = state.asData?.value;
    if (!_editable(v)) return;
    state = AsyncData(
      v!.copyWith(
        species: species,
        speciesDetail: species != null && species != 'other'
            ? ''
            : speciesDetail,
        size: size,
        sex: sex,
        traits: traits,
        custody: custody,
        placeReference: placeReference,
        occurredAt: occurredAt,
        latitude: latitude,
        longitude: longitude,
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  Future<void> choosePhoto({bool camera = false, bool recover = false}) async {
    final v = state.asData?.value;
    if (!_editable(v) || v!.photos.length >= 3) return;
    final g = _generation;
    state = AsyncData(v.copyWith(busy: true, clearIssue: true));
    try {
      final action = ref.read(chooseFoundPhotoProvider);
      final bytes = recover
          ? await action.recover(v.ownerId, v.draftId)
          : await action(v.ownerId, v.draftId, camera: camera);
      if (!_current(g, v.ownerId)) return;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          photos: bytes == null
              ? v.photos
              : [...v.photos, FoundPhotoDraft(newEntityId(), bytes)],
          dirty: v.dirty || bytes != null,
        ),
      );
    } catch (e) {
      if (_current(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is FoundFailure ? e.kind : FoundFailureKind.gallery,
          ),
        );
      }
    }
  }

  void removePhoto(String id) {
    final v = state.asData?.value;
    if (!_editable(v)) return;
    state = AsyncData(
      v!.copyWith(
        photos: v.photos.where((p) => p.id != id).toList(),
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  FoundCaseDraft _draft(FoundEditorState v) => FoundCaseDraft(
    id: v.draftId,
    reportKind: v.reportKind,
    targetId: v.targetId,
    communityTarget: v.communityTarget,
    occurredAt: v.occurredAt ?? DateTime.utc(1999),
    latitude: v.latitude ?? double.nan,
    longitude: v.longitude ?? double.nan,
    placeReference: v.placeReference,
    species: v.species,
    speciesDetail: v.species == 'other' ? v.speciesDetail : null,
    size: v.size.isEmpty ? null : v.size,
    sex: v.sex.isEmpty ? null : v.sex,
    traits: v.traits,
    custody: v.custody.isEmpty ? null : v.custody,
    photos: v.photos,
  );
  void preview() {
    final v = state.asData?.value;
    if (!_editable(v)) return;
    try {
      ref.read(publishFoundCaseProvider).validate(_draft(v!), DateTime.now());
      state = AsyncData(
        v.copyWith(stage: FoundStage.preview, clearIssue: true),
      );
    } catch (e) {
      state = AsyncData(
        v!.copyWith(
          issue: e is FoundFailure ? e.kind : FoundFailureKind.invalid,
          invalidFields: e is FoundFailure ? e.fields : {},
        ),
      );
    }
  }

  void backToForm() {
    final v = state.asData?.value;
    if (!_editable(v)) return;
    state = AsyncData(v!.copyWith(stage: FoundStage.form, clearIssue: true));
  }

  Future<void> publish() async {
    final v = state.asData?.value;
    if (v == null ||
        state.isLoading ||
        v.busy ||
        v.issue == FoundFailureKind.targetClosed ||
        v.stage != FoundStage.preview) {
      return;
    }
    final g = _generation, keep = ref.keepAlive();
    final d = v.lockedDraft ?? _draft(v);
    state = AsyncData(
      v.copyWith(busy: true, lockedDraft: d, attempted: true, clearIssue: true),
    );
    try {
      final published = await ref
          .read(publishFoundCaseProvider)(v.ownerId, d)
          .timeout(
            _operationTimeout,
            onTimeout: () =>
                throw const FoundFailure(FoundFailureKind.timedOut),
          );
      if (!_current(g, v.ownerId)) return;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          stage: FoundStage.confirmed,
          published: published,
          dirty: false,
          clearIssue: true,
        ),
      );
      ref.invalidate(myFoundCasesViewModelProvider);
      if (d.targetId != null) {
        ref.invalidate(
          recoveryCaseViewModelProvider((d.targetId!, d.communityTarget)),
        );
      }
    } catch (e) {
      if (_current(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is FoundFailure ? e.kind : FoundFailureKind.unavailable,
            clearLock:
                e is FoundFailure &&
                {
                  FoundFailureKind.invalid,
                  FoundFailureKind.photoInvalid,
                  FoundFailureKind.photos,
                  FoundFailureKind.draftLimit,
                  FoundFailureKind.targetClosed,
                }.contains(e.kind),
          ),
        );
      }
    } finally {
      keep.close();
    }
  }

  // The frozen request can only be released after the server confirms no active case exists.
  Future<bool> discard() async {
    final v = state.asData?.value;
    if (v == null || v.busy) return false;
    if (!v.attempted) return true;
    final g = _generation, keep = ref.keepAlive();
    state = AsyncData(v.copyWith(busy: true, clearIssue: true));
    try {
      await ref
          .read(discardFoundDraftProvider)(v.ownerId, v.draftId)
          .timeout(
            _operationTimeout,
            onTimeout: () =>
                throw const FoundFailure(FoundFailureKind.timedOut),
          );
      if (!_current(g, v.ownerId)) return false;
      state = AsyncData(state.requireValue.copyWith(busy: false, dirty: false));
      ref.invalidate(myFoundCasesViewModelProvider);
      return true;
    } catch (e) {
      if (_current(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is FoundFailure ? e.kind : FoundFailureKind.unavailable,
          ),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }
}
