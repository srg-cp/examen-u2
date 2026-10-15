import '../../../../core/presentation/state/retained_read.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/found_case.dart';
import '../../providers/found_case_providers.dart';
import '../state/found_read_state.dart';

final myFoundCasesViewModelProvider =
    AsyncNotifierProvider.autoDispose<MyFoundCasesViewModel, FoundListState>(
      MyFoundCasesViewModel.new,
      retry: (_, _) => null,
    );

class MyFoundCasesViewModel extends AsyncNotifier<FoundListState> {
  int _generation = 0;
  @override
  Future<FoundListState> build() async {
    _generation++;
    final session = await ref.watch(foundSessionProvider.future);
    if (session == null) throw const FoundFailure(FoundFailureKind.forbidden);
    final cases = await ref.watch(listMyFoundCasesProvider)(session.userId);
    return FoundListState(ownerId: session.userId, cases: cases);
  }

  Future<void> discard(String id) async {
    final current = state.asData?.value;
    if (current == null ||
        current.busyId != null ||
        current.refreshing ||
        !current.cases.any(
          (c) => c.id == id && {'draft', 'discarded'}.contains(c.status),
        )) {
      return;
    }
    final generation = _generation;
    state = AsyncData(
      FoundListState(
        ownerId: current.ownerId,
        cases: current.cases,
        refreshing: true,
      ),
    );
    try {
      await ref.read(discardFoundDraftProvider)(current.ownerId, id);
      final cases = await ref.read(listMyFoundCasesProvider)(current.ownerId);
      if (ref.mounted && generation == _generation && !state.isLoading) {
        state = AsyncData(
          FoundListState(ownerId: current.ownerId, cases: cases),
        );
      }
    } catch (_) {
      if (ref.mounted && generation == _generation && !state.isLoading) {
        state = AsyncData(
          FoundListState(
            ownerId: current.ownerId,
            cases: current.cases,
            refreshFailed: true,
          ),
        );
      }
    }
  }

  Future<void> retry() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    if (current.refreshing || current.busyId != null) return;
    final generation = _generation;
    state = AsyncData(
      FoundListState(
        ownerId: current.ownerId,
        cases: current.cases,
        refreshing: true,
      ),
    );
    await retainedRead(
      request: () => ref.read(listMyFoundCasesProvider)(current.ownerId),
      isCurrent: () =>
          ref.mounted && generation == _generation && !state.isLoading,
      onSuccess: (cases) {
        state = AsyncData(
          FoundListState(ownerId: current.ownerId, cases: cases),
        );
      },
      onFailure: () {
        state = AsyncData(
          FoundListState(
            ownerId: current.ownerId,
            cases: current.cases,
            refreshFailed: true,
          ),
        );
      },
    );
  }

  Future<void> delete(FoundPublication item) async {
    final current = state.asData?.value;
    if (current == null || current.refreshing || current.busyId != null) return;
    final generation = _generation;
    state = AsyncData(
      FoundListState(
        ownerId: current.ownerId,
        cases: current.cases,
        busyId: item.id,
        noticeId: current.noticeId,
      ),
    );
    try {
      await ref.read(deleteFoundPublicationProvider)(current.ownerId, item);
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        FoundListState(
          ownerId: current.ownerId,
          cases: current.cases.where((c) => c.id != item.id).toList(),
          notice: 'Caso eliminado',
          noticeId: current.noticeId + 1,
        ),
      );
      ref.invalidate(publicFoundViewModelProvider(item.id));
    } catch (_) {
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        FoundListState(
          ownerId: current.ownerId,
          cases: current.cases,
          notice: 'No se pudo eliminar el caso. Desliza para reintentar.',
          noticeIsError: true,
          noticeId: current.noticeId + 1,
        ),
      );
    }
  }
}

final publicFoundViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<PublicFoundViewModel, PublicFoundState, String>(
      PublicFoundViewModel.new,
      retry: (_, _) => null,
    );

class PublicFoundViewModel extends AsyncNotifier<PublicFoundState> {
  PublicFoundViewModel(this.id);
  final String id;
  int _generation = 0;
  @override
  Future<PublicFoundState> build() async {
    _generation++;
    final session = await ref.watch(foundSessionProvider.future);
    return PublicFoundState(
      ownerId: session?.userId,
      value: await ref.watch(readPublicFoundCaseProvider)(id),
    );
  }

  Future<void> retry() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    if (current.refreshing) return;
    final generation = _generation;
    state = AsyncData(
      PublicFoundState(
        ownerId: current.ownerId,
        value: current.value,
        refreshing: true,
      ),
    );
    await retainedRead(
      request: () => ref.read(readPublicFoundCaseProvider)(id),
      isCurrent: () =>
          ref.mounted && generation == _generation && !state.isLoading,
      onSuccess: (value) {
        state = AsyncData(
          PublicFoundState(ownerId: current.ownerId, value: value),
        );
      },
      onFailure: () {
        state = AsyncData(
          PublicFoundState(
            ownerId: current.ownerId,
            value: current.value,
            refreshFailed: true,
          ),
        );
      },
    );
  }
}
