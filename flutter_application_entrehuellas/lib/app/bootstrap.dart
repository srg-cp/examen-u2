import '../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../features/onboarding/data/data_sources/supabase_onboarding_data_source.dart';
import '../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../features/onboarding/data/repositories/unavailable_onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';
import '../core/config/startup_state.dart';
import '../features/auth/data/data_sources/supabase_auth_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/repositories/access_repository.dart';
import '../features/auth/data/repositories/access_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_access_repository.dart';
import '../features/auth/domain/repositories/registration_repository.dart';
import '../features/auth/data/data_sources/supabase_registration_data_source.dart';
import '../features/auth/data/repositories/registration_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_registration_repository.dart';
import '../features/auth/domain/repositories/password_recovery_repository.dart';
import '../features/auth/data/data_sources/supabase_password_recovery_data_source.dart';
import '../features/auth/data/repositories/password_recovery_repository_impl.dart';
import '../features/auth/data/repositories/unavailable_password_recovery_repository.dart';

class AppBootstrap {
  const AppBootstrap({
    required this.state,
    required this.authRepository,
    required this.accessRepository,
    required this.onboardingRepository,
    required this.registrationRepository,
    required this.passwordRecoveryRepository,
  });

  final StartupState state;
  final AuthRepository authRepository;
  final AccessRepository accessRepository;
  final OnboardingRepository onboardingRepository;
  final RegistrationRepository registrationRepository;
  final PasswordRecoveryRepository passwordRecoveryRepository;
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
        final source = SupabaseAuthDataSource(
          supabase.client,
          redirectUri: kIsWeb ? null : AppConfig.authRedirectUri,
        );
        return AppBootstrap(
          state: const StartupState(StartupStatus.ready),
          authRepository: AuthRepositoryImpl(source),
          accessRepository: AccessRepositoryImpl(source),
          passwordRecoveryRepository: PasswordRecoveryRepositoryImpl(
            SupabasePasswordRecoveryDataSource(
              supabase.client,
              redirectUri: kIsWeb ? null : AppConfig.authRedirectUri,
            ),
          ),
          registrationRepository: RegistrationRepositoryImpl(
            SupabaseRegistrationDataSource(
              supabase.client,
              redirectUri: kIsWeb ? null : AppConfig.authRedirectUri,
            ),
          ),
          onboardingRepository: OnboardingRepositoryImpl(
            SupabaseOnboardingDataSource(supabase.client),
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
  accessRepository: const UnavailableAccessRepository(),
  registrationRepository: const UnavailableRegistrationRepository(),
  passwordRecoveryRepository: const UnavailablePasswordRecoveryRepository(),
  onboardingRepository: const UnavailableOnboardingRepository(),
);
