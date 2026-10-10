import '../features/lost_cases/domain/repositories/lost_case_repository.dart';
import '../features/lost_cases/data/data_sources/supabase_lost_case_data_source.dart';
import '../features/lost_cases/data/repositories/lost_case_repository_impl.dart';
import '../features/lost_cases/data/repositories/unavailable_lost_case_repository.dart';
import '../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../features/onboarding/data/data_sources/supabase_onboarding_data_source.dart';
import '../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../features/onboarding/data/repositories/unavailable_onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/data/data_sources/supabase_profile_data_source.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/data/repositories/unavailable_profile_repository.dart';
import 'package:image_picker/image_picker.dart';
import '../features/profile/domain/repositories/profile_photo_repository.dart';
import '../features/profile/data/repositories/profile_photo_repository_impl.dart';
import '../features/profile/data/repositories/unavailable_profile_photo_repository.dart';
import '../features/profile/data/data_sources/gallery_profile_photo_source.dart';
import '../features/pets/domain/repositories/pet_repository.dart';
import '../features/pets/data/data_sources/supabase_pet_data_source.dart';
import '../features/pets/data/repositories/pet_repository_impl.dart';
import '../features/pets/data/repositories/unavailable_pet_repository.dart';
import '../features/pets/domain/repositories/pet_photo_repository.dart';
import '../features/pets/data/data_sources/pet_gallery_source.dart';
import '../features/pets/data/data_sources/supabase_pet_photo_source.dart';
import '../features/pets/data/repositories/pet_photo_repository_impl.dart';
import '../features/pets/data/repositories/unavailable_pet_photo_repository.dart';
import '../features/interest_zones/domain/repositories/interest_zone_repository.dart';
import '../features/alert_preferences/domain/repositories/alert_preference_repository.dart';
import '../features/alert_preferences/data/data_sources/supabase_alert_preference_data_source.dart';
import '../features/alert_preferences/data/repositories/alert_preference_repository_impl.dart';
import '../features/alert_preferences/data/repositories/unavailable_alert_preference_repository.dart';
import '../features/interest_zones/data/data_sources/supabase_interest_zone_data_source.dart';
import '../features/interest_zones/data/repositories/interest_zone_repository_impl.dart';
import '../features/interest_zones/data/repositories/unavailable_interest_zone_repository.dart';

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
    required this.profileRepository,
    required this.profilePhotoRepository,
    required this.petRepository,
    required this.petPhotoRepository,
    required this.interestZoneRepository,
    required this.alertPreferenceRepository,
    required this.lostCaseRepository,
  });

  final StartupState state;
  final AuthRepository authRepository;
  final AccessRepository accessRepository;
  final OnboardingRepository onboardingRepository;
  final RegistrationRepository registrationRepository;
  final PasswordRecoveryRepository passwordRecoveryRepository;
  final ProfileRepository profileRepository;
  final ProfilePhotoRepository profilePhotoRepository;
  final PetRepository petRepository;
  final PetPhotoRepository petPhotoRepository;
  final InterestZoneRepository interestZoneRepository;
  final AlertPreferenceRepository alertPreferenceRepository;
  final LostCaseRepository lostCaseRepository;
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
          lostCaseRepository: LostCaseRepositoryImpl(
            SupabaseLostCaseDataSource(supabase.client),
          ),
          alertPreferenceRepository: AlertPreferenceRepositoryImpl(
            SupabaseAlertPreferenceDataSource(supabase.client),
          ),
          interestZoneRepository: InterestZoneRepositoryImpl(
            SupabaseInterestZoneDataSource(supabase.client),
          ),
          petPhotoRepository: PetPhotoRepositoryImpl(
            NativePetGallerySource(ImagePicker()),
            SupabasePetPhotoSource(supabase.client),
          ),
          petRepository: PetRepositoryImpl(
            SupabasePetDataSource(supabase.client),
          ),
          state: const StartupState(StartupStatus.ready),
          profilePhotoRepository: ProfilePhotoRepositoryImpl(
            GalleryProfilePhotoSource(ImagePicker()),
            SupabaseProfileDataSource(supabase.client),
          ),
          authRepository: AuthRepositoryImpl(source),
          accessRepository: AccessRepositoryImpl(source),
          profileRepository: ProfileRepositoryImpl(
            SupabaseProfileDataSource(supabase.client),
          ),
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
  lostCaseRepository: const UnavailableLostCaseRepository(),
  alertPreferenceRepository: const UnavailableAlertPreferenceRepository(),
  interestZoneRepository: const UnavailableInterestZoneRepository(),
  petPhotoRepository: const UnavailablePetPhotoRepository(),
  petRepository: const UnavailablePetRepository(),
  state: StartupState(status),
  authRepository: const UnavailableAuthRepository(),
  accessRepository: const UnavailableAccessRepository(),
  registrationRepository: const UnavailableRegistrationRepository(),
  passwordRecoveryRepository: const UnavailablePasswordRecoveryRepository(),
  onboardingRepository: const UnavailableOnboardingRepository(),
  profileRepository: const UnavailableProfileRepository(),
  profilePhotoRepository: const UnavailableProfilePhotoRepository(),
);
