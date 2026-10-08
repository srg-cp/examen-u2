import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../../providers/onboarding_providers.dart';
import '../state/entry_destination.dart';

final entryViewModelProvider =
    AsyncNotifierProvider.autoDispose<EntryViewModel, EntryDestination>(
      EntryViewModel.new,
    );

class EntryViewModel extends AsyncNotifier<EntryDestination> {
  @override
  Future<EntryDestination> build() async {
    final auth = ref.watch(authViewModelProvider);
    if (!auth.startup.isReady) return EntryDestination.login;
    if (auth.session.hasError) throw StateError('Session unavailable');
    if (auth.session.isLoading) return EntryDestination.checking;
    final user = auth.session.asData?.value;
    if (user == null) return EntryDestination.login;
    final completed = await ref.watch(checkOnboardingProvider)(user.userId);
    return completed ? EntryDestination.home : EntryDestination.onboarding;
  }

  void retry() => ref.invalidateSelf();
}
