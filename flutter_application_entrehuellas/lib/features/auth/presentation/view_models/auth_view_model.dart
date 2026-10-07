import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/startup_state_provider.dart';
import '../../domain/entities/auth_session.dart';
import '../../providers/auth_providers.dart';
import '../state/auth_view_state.dart';

final authViewModelProvider =
    NotifierProvider.autoDispose<AuthViewModel, AuthViewState>(
      AuthViewModel.new,
    );

final _authSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (retryCount, error) => null,
);

class AuthViewModel extends Notifier<AuthViewState> {
  @override
  AuthViewState build() {
    final startup = ref.watch(startupStateProvider);
    return AuthViewState(
      startup: startup,
      session: startup.isReady
          ? ref.watch(_authSessionProvider)
          : const AsyncData(null),
    );
  }
}
