import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import '../../domain/entities/pet_photo.dart';
import '../../providers/pet_providers.dart';
import 'pet_list_view_model.dart';

class PetPhotosState {
  const PetPhotosState({
    this.photos = const [],
    this.pending = const [],
    this.pendingRemovals = const {},
    this.busy = false,
    this.loading = false,
    this.issue,
    this.errorId = 0,
    this.recovered = false,
  });
  final List<PetPhoto> photos;
  final List<PetPhotoDraft> pending;
  final Set<String> pendingRemovals;
  List<PetPhoto> get visiblePhotos =>
      photos.where((photo) => !pendingRemovals.contains(photo.id)).toList();
  bool get hasPendingChanges =>
      pending.isNotEmpty || pendingRemovals.isNotEmpty;
  final bool busy;
  final bool loading;
  final PetPhotoFailureKind? issue;
  final int errorId;
  final bool recovered;
  PetPhotosState copy({
    List<PetPhoto>? photos,
    List<PetPhotoDraft>? pending,
    Set<String>? pendingRemovals,
    bool busy = false,
    bool loading = false,
    PetPhotoFailureKind? issue,
    int? errorId,
    bool? recovered,
  }) => PetPhotosState(
    photos: photos ?? this.photos,
    pending: pending ?? this.pending,
    pendingRemovals: pendingRemovals ?? this.pendingRemovals,
    busy: busy,
    loading: loading,
    issue: issue,
    errorId: errorId ?? this.errorId,
    recovered: recovered ?? this.recovered,
  );
}

final petPhotosViewModelProvider = NotifierProvider.autoDispose
    .family<PetPhotosViewModel, PetPhotosState, String>(PetPhotosViewModel.new);

class PetPhotosViewModel extends Notifier<PetPhotosState> {
  PetPhotosViewModel(this.petId);
  final String petId;
  int _generation = 0;
  int _errorId = 0;
  Future<void>? _initialization;
  @override
  PetPhotosState build() {
    _generation++;
    _initialization = null;
    ref.watch(petSessionProvider);
    return const PetPhotosState();
  }

  String? get _owner => ref.read(petSessionProvider).asData?.value?.userId;
  bool _valid(int generation, String owner) =>
      ref.mounted && generation == _generation && _owner == owner;
  PetPhotoFailureKind _kind(Object e) =>
      e is PetPhotoFailure ? e.kind : PetPhotoFailureKind.unavailable;
  Future<void> ensureInitialized(bool existing) =>
      _initialization ??= initialize(existing);

  Future<void> initialize(bool existing) async {
    if (state.busy || state.loading) return;
    final owner = _owner;
    if (owner == null) return;
    final generation = _generation;
    state = state.copy(loading: existing && state.photos.isEmpty);
    try {
      final useCase = ref.read(managePetPhotosProvider);
      final photos = existing ? await useCase.list(owner, petId) : <PetPhoto>[];
      final recovered = await useCase.recover(owner, petId, existing);
      if (!_valid(generation, owner)) return;
      final drafts = [...state.pending];
      final visibleCount = photos
          .where((photo) => !state.pendingRemovals.contains(photo.id))
          .length;
      if (recovered != null && visibleCount + drafts.length < 3) {
        drafts.add(PetPhotoDraft(id: newPetId(), bytes: recovered));
      }
      state = state.copy(
        photos: photos,
        pending: drafts,
        recovered: recovered != null,
      );
    } catch (e) {
      if (_valid(generation, owner)) {
        state = state.copy(issue: _kind(e), errorId: ++_errorId);
      }
    }
  }

  Future<void> choose(bool existing) async {
    if (state.busy || state.loading) return;
    final owner = _owner;
    if (owner == null) return;
    if (state.visiblePhotos.length + state.pending.length >= 3) {
      state = state.copy(issue: PetPhotoFailureKind.limit, errorId: ++_errorId);
      return;
    }
    final generation = _generation;
    final lifetime = ref.keepAlive();
    state = state.copy(busy: true);
    try {
      final bytes = await ref
          .read(managePetPhotosProvider)
          .choose(owner, petId, existing);
      if (!_valid(generation, owner)) return;
      state = state.copy(
        pending: bytes == null
            ? state.pending
            : [...state.pending, PetPhotoDraft(id: newPetId(), bytes: bytes)],
      );
    } catch (e) {
      if (_valid(generation, owner)) {
        state = state.copy(issue: _kind(e), errorId: ++_errorId);
      }
    } finally {
      lifetime.close();
    }
  }

  void discardPending() {
    if (state.busy) return;
    state = state.copy(
      pending: const [],
      pendingRemovals: const {},
      recovered: false,
    );
  }

  Future<bool> savePendingChanges() async {
    if (!state.hasPendingChanges) return true;
    if (state.busy || state.loading) return false;
    final owner = _owner;
    if (owner == null) return false;
    final generation = _generation;
    final lifetime = ref.keepAlive();
    state = state.copy(busy: true);
    try {
      final useCase = ref.read(managePetPhotosProvider);
      // Free confirmed slots only after the editor has validated and saved.
      for (final id in Set<String>.of(state.pendingRemovals)) {
        await useCase.remove(owner, petId, id);
        if (!_valid(generation, owner)) return false;
        state = state.copy(
          busy: true,
          photos: state.photos.where((photo) => photo.id != id).toList(),
          pendingRemovals: Set.unmodifiable(
            state.pendingRemovals.where((photoId) => photoId != id),
          ),
        );
        ref.invalidate(petListViewModelProvider);
        ref.invalidate(petDetailViewModelProvider(petId));
      }
      for (final draft in List<PetPhotoDraft>.of(state.pending)) {
        final photo = await useCase.upload(owner, petId, draft);
        if (!_valid(generation, owner)) return false;
        state = state.copy(
          busy: true,
          photos: [...state.photos.where((p) => p.id != photo.id), photo],
          pending: state.pending.where((p) => p.id != draft.id).toList(),
        );
      }
      if (!_valid(generation, owner)) return false;
      state = state.copy(recovered: false);
      return true;
    } catch (e) {
      if (_valid(generation, owner)) {
        state = state.copy(issue: _kind(e), errorId: ++_errorId);
      }
      return false;
    } finally {
      lifetime.close();
    }
  }

  void stageRemoval(String id) {
    if (state.busy || state.loading || _owner == null) return;
    if (state.pending.any((draft) => draft.id == id)) {
      state = state.copy(
        pending: state.pending.where((draft) => draft.id != id).toList(),
      );
    } else if (state.photos.any((photo) => photo.id == id)) {
      state = state.copy(
        pendingRemovals: Set.unmodifiable({...state.pendingRemovals, id}),
      );
    }
  }
}
