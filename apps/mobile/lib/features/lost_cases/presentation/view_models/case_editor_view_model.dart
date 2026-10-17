import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/use_cases/publish_lost_case.dart';
import '../../../pets/providers/pet_providers.dart';
import '../../domain/entities/lost_case.dart';
import '../../providers/lost_case_providers.dart';
import '../state/case_editor_state.dart';
import 'case_read_view_model.dart';

final caseEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<CaseEditorViewModel, CaseEditorState>(
      CaseEditorViewModel.new,
      retry: (_, _) => null,
    );

class CaseEditorViewModel extends AsyncNotifier<CaseEditorState> {
  CaseEditorViewModel({Duration? publicationTimeout})
    : _publicationTimeout = publicationTimeout;
  final Duration? _publicationTimeout;
  Duration get publicationTimeout =>
      _publicationTimeout ?? const Duration(seconds: 35);
  int _generation = 0;
  @override
  Future<CaseEditorState> build() async {
    _generation++;
    final session = await ref.watch(caseSessionProvider.future);
    if (session == null) throw const CaseFailure(CaseFailureKind.forbidden);
    final pets = await ref.read(listMyPetsProvider)(session.userId);
    return CaseEditorState(
      ownerId: session.userId,
      draftId: newEntityId(),
      pets: pets.where((p) => !p.isArchived).toList(),
    );
  }

  void retry() => ref.invalidateSelf();
  bool _current(int generation, String owner) =>
      ref.mounted &&
      generation == _generation &&
      !state.isLoading &&
      state.asData?.value.ownerId == owner;
  bool _editable(CaseEditorState? value) =>
      value != null &&
      !state.isLoading &&
      !value.busy &&
      !value.loadingPhotos &&
      value.lockedDraft == null &&
      value.stage != CaseEditorStage.confirmed;
  Future<void> selectPet(String id) async {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    final pet = current!.pets.where((p) => p.id == id).firstOrNull;
    if (pet == null) return;
    final generation = _generation;
    state = AsyncData(
      current.copyWith(
        pet: pet,
        photos: [],
        selectedPhotos: {},
        loadingPhotos: true,
        dirty: true,
        clearIssue: true,
      ),
    );
    try {
      final updatedPet = await ref.read(readPetProvider)(current.ownerId, id);
      final photos = await ref
          .read(managePetPhotosProvider)
          .list(current.ownerId, id);
      if (!_current(generation, current.ownerId)) return;
      state = AsyncData(
        state.requireValue.copyWith(
          pet: updatedPet,
          photos: photos.where((p) => p.ready).toList(),
          loadingPhotos: false,
        ),
      );
    } catch (_) {
      if (_current(generation, current.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            loadingPhotos: false,
            issue: CaseFailureKind.unavailable,
          ),
        );
      }
    }
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
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
    String? placeReference,
  }) {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    state = AsyncData(
      current!.copyWith(
        occurredAt: occurredAt,
        latitude: latitude,
        longitude: longitude,
        placeReference: placeReference,
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  void togglePhoto(String id) {
    final current = state.asData?.value;
    if (!_editable(current) || !current!.photos.any((p) => p.id == id)) return;
    final selected = {...current.selectedPhotos};
    if (!selected.remove(id)) selected.add(id);
    state = AsyncData(
      current.copyWith(selectedPhotos: selected, dirty: true, clearIssue: true),
    );
  }

  LostCaseDraft _draft(CaseEditorState current) {
    return LostCaseDraft(
      id: current.draftId,
      petId: current.pet?.id ?? '',
      petVersion: current.pet?.version ?? 0,
      occurredAt: current.occurredAt ?? DateTime.utc(1999),
      latitude: current.latitude ?? double.nan,
      longitude: current.longitude ?? double.nan,
      placeReference: current.placeReference,
      photoIds: current.selectedPhotos.toList(),
    );
  }

  void preview() {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    try {
      validateLostCasePet(current!.pet);
      final draft = _draft(current);
      ref.read(publishLostCaseProvider).validate(draft, DateTime.now());
      state = AsyncData(
        current.copyWith(stage: CaseEditorStage.preview, clearIssue: true),
      );
    } catch (e) {
      state = AsyncData(
        current!.copyWith(
          issue: e is CaseFailure ? e.kind : CaseFailureKind.invalid,
          invalidFields: e is CaseFailure ? e.fields : {},
        ),
      );
    }
  }

  void backToForm() {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    state = AsyncData(
      current!.copyWith(stage: CaseEditorStage.form, clearIssue: true),
    );
  }

  Future<void> publish() async {
    final current = state.asData?.value;
    if (current == null ||
        state.isLoading ||
        current.busy ||
        current.stage != CaseEditorStage.preview) {
      return;
    }
    final generation = _generation;
    final keep = ref.keepAlive();
    try {
      final draft = current.lockedDraft ?? _draft(current);
      state = AsyncData(
        current.copyWith(busy: true, lockedDraft: draft, clearIssue: true),
      );
      final published = await ref
          .read(publishLostCaseProvider)(current.ownerId, draft)
          .timeout(
            publicationTimeout,
            onTimeout: () => throw const CaseFailure(CaseFailureKind.timedOut),
          );
      if (!_current(generation, current.ownerId)) return;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          published: published,
          stage: CaseEditorStage.confirmed,
          dirty: false,
          clearIssue: true,
        ),
      );
      ref.read(notifyPetChangedProvider)(current.ownerId, draft.petId);
      ref.invalidate(myCasesViewModelProvider);
    } catch (e) {
      if (_current(generation, current.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            clearLockedDraft:
                e is CaseFailure &&
                e.kind != CaseFailureKind.unavailable &&
                e.kind != CaseFailureKind.timedOut,
            issue: e is CaseFailure ? e.kind : CaseFailureKind.unavailable,
            invalidFields: e is CaseFailure ? e.fields : {},
          ),
        );
      }
    } finally {
      keep.close();
    }
  }
}
