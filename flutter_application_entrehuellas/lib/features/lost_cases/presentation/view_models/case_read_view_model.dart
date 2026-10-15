import '../../../../core/presentation/state/retained_read.dart';
import '../../../pets/providers/pet_providers.dart'
    show notifyPetChangedProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lost_case.dart';
import '../../providers/lost_case_providers.dart';
import '../state/case_read_state.dart';

final myCasesViewModelProvider =
    AsyncNotifierProvider.autoDispose<MyCasesViewModel, CaseListState>(
      MyCasesViewModel.new,
      retry: (_, _) => null,
    );

class MyCasesViewModel extends AsyncNotifier<CaseListState> {
  int _generation = 0;
  @override
  Future<CaseListState> build() async {
    _generation++;
    final session = await ref.watch(caseSessionProvider.future);
    if (session == null) throw const CaseFailure(CaseFailureKind.forbidden);
    final cases = await ref.watch(listMyLostCasesProvider)(session.userId);
    return CaseListState(ownerId: session.userId, cases: cases);
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
      CaseListState(
        ownerId: current.ownerId,
        cases: current.cases,
        refreshing: true,
      ),
    );
    await retainedRead(
      request: () => ref.read(listMyLostCasesProvider)(current.ownerId),
      isCurrent: () =>
          ref.mounted && generation == _generation && !state.isLoading,
      onSuccess: (cases) {
        state = AsyncData(
          CaseListState(ownerId: current.ownerId, cases: cases),
        );
      },
      onFailure: () {
        state = AsyncData(
          CaseListState(
            ownerId: current.ownerId,
            cases: current.cases,
            refreshFailed: true,
          ),
        );
      },
    );
  }

  Future<void> delete(PublishedLostCase item) async {
    final current = state.asData?.value;
    if (current == null || current.refreshing || current.busyId != null) return;
    final generation = _generation;
    state = AsyncData(
      CaseListState(
        ownerId: current.ownerId,
        cases: current.cases,
        busyId: item.id,
        noticeId: current.noticeId,
      ),
    );
    try {
      await ref.read(deletePublishedLostCaseProvider)(current.ownerId, item);
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        CaseListState(
          ownerId: current.ownerId,
          cases: current.cases.where((c) => c.id != item.id).toList(),
          notice: 'Caso eliminado',
          noticeId: current.noticeId + 1,
        ),
      );
      ref.read(notifyPetChangedProvider)(current.ownerId, item.petId);
      ref.invalidate(publicCaseViewModelProvider(item.id));
    } catch (_) {
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        CaseListState(
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

final publicCaseViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<PublicCaseViewModel, PublicCaseState, String>(
      PublicCaseViewModel.new,
      retry: (_, _) => null,
    );

class PublicCaseViewModel extends AsyncNotifier<PublicCaseState> {
  PublicCaseViewModel(this.id);
  final String id;
  int _generation = 0;
  @override
  Future<PublicCaseState> build() async {
    _generation++;
    final session = await ref.watch(caseSessionProvider.future);
    return PublicCaseState(
      ownerId: session?.userId,
      value: await ref.watch(readPublicLostCaseProvider)(id),
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
      PublicCaseState(
        ownerId: current.ownerId,
        value: current.value,
        refreshing: true,
      ),
    );
    await retainedRead(
      request: () => ref.read(readPublicLostCaseProvider)(id),
      isCurrent: () =>
          ref.mounted && generation == _generation && !state.isLoading,
      onSuccess: (value) {
        state = AsyncData(
          PublicCaseState(ownerId: current.ownerId, value: value),
        );
      },
      onFailure: () {
        state = AsyncData(
          PublicCaseState(
            ownerId: current.ownerId,
            value: current.value,
            refreshFailed: true,
          ),
        );
      },
    );
  }
}
