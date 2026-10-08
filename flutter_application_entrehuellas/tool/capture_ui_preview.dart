import '../test/access_test.dart' show FakeAccess;
import '../test/registration_test.dart' show FakeRegistration;
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/registration_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/registration_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/access_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/login_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/state/login_view_state.dart';
// Visual QA harness, invoked explicitly with flutter test. No golden baselines.
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import '../test/app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';

void main() {
  testWidgets('Render login and onboarding for visual inspection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    await tester.runAsync(() async {
      // Widget tests normally use Ahem. Load real SDK fonts for visual QA.
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final flutterPackage = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((package) => package['name'] == 'flutter');
      final packageRoot = configFile.uri.resolve(
        '${flutterPackage['rootUri']}/',
      );
      final fontRoot = packageRoot.resolve(
        '../../bin/cache/artifacts/material_fonts/',
      );
      for (final entry in {
        'sans-serif': [
          'roboto-regular.ttf',
          'roboto-medium.ttf',
          'roboto-bold.ttf',
        ],
        'MaterialIcons': ['materialicons-regular.otf'],
      }.entries) {
        final loader = FontLoader(entry.key);
        for (final fileName in entry.value) {
          loader.addFont(
            File.fromUri(
              fontRoot.resolve(fileName),
            ).readAsBytes().then(ByteData.sublistView),
          );
        }
        await loader.load();
      }
    });
    final auth = FakeAuthRepository();
    final onboarding = FakeOnboarding(auth);
    addTearDown(auth.controller.close);
    final container = ProviderContainer(
      overrides: [
        startupStateProvider.overrideWithValue(
          const StartupState(StartupStatus.ready),
        ),
        authRepositoryProvider.overrideWithValue(auth),
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        accessRepositoryProvider.overrideWithValue(
          FakeAccess()
            ..failure = const AccessFailure(AccessFailureKind.rejected),
        ),
        registrationRepositoryProvider.overrideWithValue(FakeRegistration()),
      ],
    );
    addTearDown(container.dispose);
    final previewKey = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: previewKey, child: const EntreHuellasApp()),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byType(EntreHuellasApp));
      await precacheImage(
        const AssetImage('assets/illustrations/community_pets.png'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/branding/app_icon.png'),
        context,
      );
      for (final asset in [
        'dog_waving.png',
        'dog_with_map.png',
        'dog_and_cat.png',
      ]) {
        await precacheImage(AssetImage('assets/onboarding/$asset'), context);
      }
      await precacheImage(
        const AssetImage('assets/branding/google_g.png'),
        context,
      );
    });
    await tester.pumpAndSettle();

    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final boundary =
            previewKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final rendered = await boundary.toImage(pixelRatio: 2);
        try {
          final pixels = await rendered.toByteData(
            format: ui.ImageByteFormat.png,
          );
          final directory = Directory('build/ui-preview');
          await directory.create(recursive: true);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(pixels!.buffer.asUint8List());
        } finally {
          rendered.dispose();
        }
      });
    }

    await capture('access');
    await container
        .read(loginViewModelProvider.notifier)
        .password('preview@example.com', 'fake-password');
    await tester.pumpAndSettle();
    await capture('access_error');
    await tester.ensureVisible(find.widgetWithText(TextButton, 'Crear cuenta'));
    await tester.tap(find.widgetWithText(TextButton, 'Crear cuenta'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await capture('register_origin_open');
    await tester.pump(const Duration(milliseconds: 340));
    await capture('register_reveal');
    await tester.pumpAndSettle();
    await capture('register');
    await container
        .read(registrationViewModelProvider.notifier)
        .submit('Ana', 'preview@example.com', 'fake-password', 'fake-password');
    await tester.pumpAndSettle();
    await capture('register_confirmation');
    container.read(routerProvider).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 130));
    await capture('register_origin_close');
    await tester.pumpAndSettle();
    container
        .read(loginViewModelProvider.notifier)
        .fieldEdited(LoginField.email);
    await tester.pumpAndSettle();
    final pendingCheck = Completer<bool>();
    onboarding.pendingRead = pendingCheck;
    auth.emit(const AuthSession(userId: 'preview-user'));
    await tester.pumpAndSettle();
    await capture('entry_check');
    pendingCheck.complete(false);
    onboarding.pendingRead = null;
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    await capture('onboarding_reveal');
    await tester.pumpAndSettle();
    await capture('onboarding_1');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await capture('onboarding_2');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await capture('onboarding_3');
    expect(tester.takeException(), isNull);
  });
}
