import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap.dart';
import 'app/entre_huellas_app.dart';
import 'core/config/app_config.dart';
import 'core/config/startup_state_provider.dart';
import 'features/auth/providers/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await bootstrapApp(const AppConfig.fromEnvironment());
  runApp(
    ProviderScope(
      overrides: [
        startupStateProvider.overrideWithValue(bootstrap.state),
        authRepositoryProvider.overrideWithValue(bootstrap.authRepository),
      ],
      child: const EntreHuellasApp(),
    ),
  );
}
