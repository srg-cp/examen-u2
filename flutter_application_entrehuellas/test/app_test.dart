import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/state/auth_view_state.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';

class FakeAuthRepository implements AuthRepository {
  final controller = StreamController<AuthSession?>();

  @override
  Stream<AuthSession?> watchSession() => controller.stream;
}

void main() {
  testWidgets('Shell works without credentials and supports back navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EntreHuellasApp()));
    await tester.pumpAndSettle();
    expect(find.text('Cada huella cuenta'), findsOneWidget);
    await tester.tap(find.text('Acceso y cuenta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Falta configurar'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Cada huella cuenta'), findsOneWidget);
  });

  testWidgets('Session changes from the repository update the screen', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    addTearDown(repository.controller.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const EntreHuellasApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acceso y cuenta'));
    await tester.pump();
    repository.controller.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Sin sesión activa.'), findsOneWidget);
    repository.controller.add(const AuthSession(userId: 'user-1'));
    await tester.pumpAndSettle();
    expect(find.text('Sesión activa.'), findsOneWidget);
    repository.controller.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Sin sesión activa.'), findsOneWidget);
    repository.controller.addError(StateError('private details'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo recuperar el estado de la sesión.'),
      findsOneWidget,
    );
    expect(find.textContaining('private details'), findsNothing);
    repository.controller.addError(StateError('another SDK failure'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo recuperar el estado de la sesión.'),
      findsOneWidget,
    );
    repository.controller.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Sin sesión activa.'), findsOneWidget);
  });

  testWidgets('Invalid and failed startup states are explicit', (tester) async {
    for (final status in [
      StartupStatus.invalidConfiguration,
      StartupStatus.failed,
    ]) {
      final container = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(StartupState(status)),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acceso y cuenta'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          AuthViewState(
            startup: StartupState(status),
            session: const AsyncData(null),
          ).startupMessage,
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    }
  });

  testWidgets('Unknown route allows returning home without exposing its URL', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EntreHuellasApp(),
      ),
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/unknown?code=private');
    await tester.pumpAndSettle();
    expect(find.textContaining('private'), findsNothing);
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Cada huella cuenta'), findsOneWidget);
  });

  testWidgets('Access screen scrolls with a small viewport and large text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.binding.setSurfaceSize(const Size(320, 350));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EntreHuellasApp(),
      ),
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/access');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
