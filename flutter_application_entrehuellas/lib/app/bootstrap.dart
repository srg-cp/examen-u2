import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/config/startup_state.dart';
import '../features/auth/data/data_sources/supabase_auth_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';

class AppBootstrap {
  const AppBootstrap({required this.state, required this.authRepository});

  final StartupState state;
  final AuthRepository authRepository;
}

/// Initializes the SDK once, before the provider tree and router are mounted.
Future<AppBootstrap> bootstrapApp(AppConfig config) async {
  switch (config.status) {
    case ConfigurationStatus.missing:
      return _unavailable(StartupStatus.missingConfiguration);
    case ConfigurationStatus.invalid:
      return _unavailable(StartupStatus.invalidConfiguration);
    case ConfigurationStatus.ready:
      try {
        final supabase = await Supabase.initialize(
          url: config.supabaseUrl,
          publishableKey: config.supabaseKey,
          debug: false,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
        );
        return AppBootstrap(
          state: const StartupState(StartupStatus.ready),
          authRepository: AuthRepositoryImpl(
            SupabaseAuthDataSource(supabase.client),
          ),
        );
      } catch (_) {
        // Do not expose configuration or tokens through startup errors.
        return _unavailable(StartupStatus.failed);
      }
  }
}

AppBootstrap _unavailable(StartupStatus status) => AppBootstrap(
  state: StartupState(status),
  authRepository: const UnavailableAuthRepository(),
);
