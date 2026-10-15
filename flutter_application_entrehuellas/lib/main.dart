import 'features/found_cases/providers/found_case_providers.dart';
import 'features/lost_cases/providers/lost_case_providers.dart';
import 'features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap.dart';
import 'app/entre_huellas_app.dart';
import 'core/config/app_config.dart';
import 'core/config/startup_state_provider.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/auth/providers/registration_providers.dart';
import 'features/auth/providers/password_recovery_providers.dart';
import 'features/profile/providers/profile_providers.dart';
import 'features/pets/providers/pet_providers.dart';
import 'features/interest_zones/providers/interest_zone_providers.dart';
import 'features/alert_preferences/providers/alert_preference_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await bootstrapApp(const AppConfig.fromEnvironment());
  runApp(
    ProviderScope(
      overrides: [
        foundCaseRepositoryProvider.overrideWithValue(
          bootstrap.foundCaseRepository,
        ),
        lostCaseRepositoryProvider.overrideWithValue(
          bootstrap.lostCaseRepository,
        ),
        alertPreferenceRepositoryProvider.overrideWithValue(
          bootstrap.alertPreferenceRepository,
        ),
        interestZoneRepositoryProvider.overrideWithValue(
          bootstrap.interestZoneRepository,
        ),
        petRepositoryProvider.overrideWithValue(bootstrap.petRepository),
        petPhotoRepositoryProvider.overrideWithValue(
          bootstrap.petPhotoRepository,
        ),
        profilePhotoRepositoryProvider.overrideWithValue(
          bootstrap.profilePhotoRepository,
        ),
        profileRepositoryProvider.overrideWithValue(
          bootstrap.profileRepository,
        ),
        startupStateProvider.overrideWithValue(bootstrap.state),
        authRepositoryProvider.overrideWithValue(bootstrap.authRepository),
        passwordRecoveryRepositoryProvider.overrideWithValue(
          bootstrap.passwordRecoveryRepository,
        ),
        accessRepositoryProvider.overrideWithValue(bootstrap.accessRepository),
        registrationRepositoryProvider.overrideWithValue(
          bootstrap.registrationRepository,
        ),
        onboardingRepositoryProvider.overrideWithValue(
          bootstrap.onboardingRepository,
        ),
      ],
      child: const EntreHuellasApp(),
    ),
  );
}
