import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import '../../domain/entities/pet_photo.dart';
import '../../providers/pet_providers.dart';
import 'pet_list_view_model.dart';

class PetPhotosState {
  const PetPhotosState({
    this.photos = const [],
    this.pending = const [],
    this.busy = false,
    this.loading = false,
    this.issue,
    this.recovered = false,
  });
  final List<PetPhoto> photos;
  final List<PetPhotoDraft> pending;
  final bool busy;
  final bool loading;
  final PetPhotoFailureKind? issue;
  final bool recovered;
  PetPhotosState copy({
    List<PetPhoto>? photos,
    List<PetPhotoDraft>? pending,
    bool busy = false,
    bool loading = false,
    PetPhotoFailureKind? issue,
    bool? recovered,
  }) => PetPhotosState(
    photos: photos ?? this.photos,
    pending: pending ?? this.pending,
    busy: busy,
    loading: loading,
    issue: issue,
    recovered: recovered ?? this.recovered,
  );
}

final petPhotosViewModelProvider = NotifierProvider.autoDispose
    .family<PetPhotosViewModel, PetPhotosState, String>(PetPhotosViewModel.new);

class PetPhotosViewModel extends Notifier<PetPhotosState> {
  PetPhotosViewModel(this.petId);
  final String petId;
  int _generation = 0;
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
      if (recovered != null && photos.length + drafts.length < 3) {
        drafts.add(PetPhotoDraft(id: newPetId(), bytes: recovered));
      }
      state = state.copy(
        photos: photos,
        pending: drafts,
        recovered: recovered != null,
      );
    } catch (e) {
      if (_valid(generation, owner)) state = state.copy(issue: _kind(e));
    }
  }

  Future<void> choose(bool existing) async {
    if (state.busy || state.loading) return;
    final owner = _owner;
    if (owner == null) return;
    if (state.photos.length + state.pending.length >= 3) {
      state = state.copy(issue: PetPhotoFailureKind.limit);
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
      if (_valid(generation, owner)) state = state.copy(issue: _kind(e));
    } finally {
      lifetime.close();
    }
  }

  void discardPending() {
    if (state.busy) return;
    state = state.copy(pending: const [], recovered: false);
  }

  Future<bool> uploadPending() async {
    if (state.pending.isEmpty) return true;
    if (state.busy || state.loading) return false;
    final owner = _owner;
    if (owner == null) return false;
    final generation = _generation;
    final lifetime = ref.keepAlive();
    state = state.copy(busy: true);
    try {
      final useCase = ref.read(managePetPhotosProvider);
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
      if (_valid(generation, owner)) state = state.copy(issue: _kind(e));
      return false;
    } finally {
      lifetime.close();
    }
  }

  Future<void> remove(String id, bool existing) async {
    if (state.busy) return;
    final owner = _owner;
    if (owner == null) return;
    final generation = _generation;
    final lifetime = ref.keepAlive();
    state = state.copy(busy: true);
    try {
      if (existing) {
        await ref.read(managePetPhotosProvider).remove(owner, petId, id);
      }
      if (_valid(generation, owner)) {
        state = state.copy(
          photos: state.photos.where((p) => p.id != id).toList(),
          pending: state.pending.where((p) => p.id != id).toList(),
        );
        if (existing) {
          ref.invalidate(petListViewModelProvider);
          ref.invalidate(petDetailViewModelProvider(petId));
        }
      }
    } catch (e) {
      if (_valid(generation, owner)) state = state.copy(issue: _kind(e));
    } finally {
      lifetime.close();
    }
  }
}
