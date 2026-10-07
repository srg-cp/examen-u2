import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/use_cases/watch_auth_session.dart';

/// The app composition root supplies the concrete repository.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw StateError('AuthRepository must be injected at app startup.'),
);

final watchAuthSessionProvider = Provider<WatchAuthSession>(
  (ref) => WatchAuthSession(ref.watch(authRepositoryProvider)),
);
