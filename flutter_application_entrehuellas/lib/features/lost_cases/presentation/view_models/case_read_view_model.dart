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
    if (current.refreshing) return;
    final generation = _generation;
    state = AsyncData(
      CaseListState(
        ownerId: current.ownerId,
        cases: current.cases,
        refreshing: true,
      ),
    );
    try {
      final cases = await ref.read(listMyLostCasesProvider)(current.ownerId);
      if (ref.mounted && generation == _generation && !state.isLoading) {
        state = AsyncData(
          CaseListState(ownerId: current.ownerId, cases: cases),
        );
      }
    } catch (_) {
      if (ref.mounted && generation == _generation && !state.isLoading) {
        state = AsyncData(
          CaseListState(
            ownerId: current.ownerId,
            cases: current.cases,
            refreshFailed: true,
          ),
        );
      }
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
    try {
      final value = await ref.read(readPublicLostCaseProvider)(id);
      if (ref.mounted && generation == _generation && !state.isLoading) {
        state = AsyncData(
          PublicCaseState(ownerId: current.ownerId, value: value),
        );
      }
    } catch (_) {
      if (ref.mounted && generation == _generation && !state.isLoading) {
        state = AsyncData(
          PublicCaseState(
            ownerId: current.ownerId,
            value: current.value,
            refreshFailed: true,
          ),
        );
      }
    }
  }
}
