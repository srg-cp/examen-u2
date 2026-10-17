import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/entities/account_profile.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/failures/profile_failure.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/use_cases/update_profile.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/widgets/profile_editor.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_profile.dart';

void main() {
  late FakeProfile repo;
  late FakeAuthRepository auth;
  late ProviderContainer container;
  setUp(() {
    repo = FakeProfile();
    auth = FakeAuthRepository()..current = const AuthSession(userId: 'one');
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repo),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    final sub = container.listen(profileViewModelProvider, (_, _) {});
    addTearDown(sub.close);
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });

  test(
    'Update validates code points, trims and clears optional values before persistence',
    () async {
      final update = UpdateProfile(repo);
      await expectLater(
        update('one', displayName: 'x' * 121, city: '', citySelected: true),
        throwsA(
          isA<ProfileFailure>().having(
            (e) => e.kind,
            'kind',
            ProfileFailureKind.invalidName,
          ),
        ),
      );
      await expectLater(
        update('one', displayName: '', city: 'x' * 121, citySelected: true),
        throwsA(
          isA<ProfileFailure>().having(
            (e) => e.kind,
            'kind',
            ProfileFailureKind.invalidCity,
          ),
        ),
      );
      expect(repo.updates, 0);
      final unicode = await update(
        'one',
        displayName: '🐾' * 120,
        city: ' Lima ',
        citySelected: true,
      );
      expect(unicode.city, 'Lima');
      expect(unicode.displayName!.runes.length, 120);
      final clear = await update(
        'one',
        displayName: ' ',
        city: '',
        citySelected: true,
      );
      expect(clear.displayName, isNull);
      expect(clear.city, isNull);
    },
  );

  test(
    'Save only confirms acknowledgement, blocks duplicates and preserves draft on failure',
    () async {
      await container.read(profileViewModelProvider.future);
      final model = container.read(profileViewModelProvider.notifier);
      model.edit(displayName: ' Ana María ', city: 'Cusco');
      model.selectCity('Cusco');
      repo.pendingUpdate = Completer<void>();
      repo.failUpdate = true;
      final saving = model.save();
      await model.save();
      model.edit(city: 'Ignored');
      expect(repo.updates, 1);
      expect(
        container.read(profileViewModelProvider).requireValue.isBusy,
        true,
      );
      expect(
        container.read(profileViewModelProvider).requireValue.saved,
        false,
      );
      repo.pendingUpdate!.complete();
      await saving;
      final failed = container.read(profileViewModelProvider).requireValue;
      expect(failed.city, 'Cusco');
      expect(failed.displayName, ' Ana María ');
      expect(failed.issue, ProfileFailureKind.unavailable);
      repo.failUpdate = false;
      await model.save();
      expect(container.read(profileViewModelProvider).requireValue.saved, true);
      expect(
        container.read(profileViewModelProvider).requireValue.displayName,
        'Ana María',
      );
      container.invalidate(profileViewModelProvider);
      expect(
        (await container.read(profileViewModelProvider.future)).city,
        'Cusco',
      );
    },
  );

  test(
    'Validation errors recover on edit and discard restores persisted fields',
    () async {
      await container.read(profileViewModelProvider.future);
      final model = container.read(profileViewModelProvider.notifier);
      model.edit(displayName: 'x' * 121);
      await model.save();
      expect(repo.updates, 0);
      expect(
        container.read(profileViewModelProvider).requireValue.issue,
        ProfileFailureKind.invalidName,
      );
      model.edit(city: 'Tacna');
      expect(
        container.read(profileViewModelProvider).requireValue.issue,
        ProfileFailureKind.invalidName,
      );
      model.edit(displayName: 'Valid');
      expect(
        container.read(profileViewModelProvider).requireValue.issue,
        isNull,
      );
      model.discard();
      expect(
        container.read(profileViewModelProvider).requireValue.displayName,
        'Ana',
      );
      expect(
        container.read(profileViewModelProvider).requireValue.isDirty,
        false,
      );
    },
  );

  test(
    'Read failure can retry; stream error recovers even for the same identity',
    () async {
      repo.failRead = true;
      await expectLater(
        container.read(profileViewModelProvider.future),
        throwsA(isA<ProfileFailure>()),
      );
      repo.failRead = false;
      container.read(profileViewModelProvider.notifier).retry();
      expect(
        (await container.read(profileViewModelProvider.future)).profile.userId,
        'one',
      );
      auth.controller.addError(StateError('private token'));
      await Future<void>.delayed(Duration.zero);
      expect(container.read(profileViewModelProvider).hasError, true);
      auth.emit(const AuthSession(userId: 'one'));
      await Future<void>.delayed(Duration.zero);
      expect(
        (await container.read(profileViewModelProvider.future)).profile.userId,
        'one',
      );
    },
  );

  test(
    'Late save from previous account cannot replace the new account profile',
    () async {
      repo.profiles['two'] = const AccountProfile(
        userId: 'two',
        displayName: 'Bea',
      );
      await container.read(profileViewModelProvider.future);
      final model = container.read(profileViewModelProvider.notifier);
      model.edit(displayName: 'Old account');
      repo.pendingUpdate = Completer<void>();
      final saving = model.save();
      auth.emit(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      expect(
        (await container.read(profileViewModelProvider.future)).profile.userId,
        'two',
      );
      repo.pendingUpdate!.complete();
      await saving;
      expect(
        container.read(profileViewModelProvider).requireValue.displayName,
        'Bea',
      );
    },
  );

  test('Disposal during save does not write to a disposed notifier', () async {
    await container.read(profileViewModelProvider.future);
    final model = container.read(profileViewModelProvider.notifier);
    model.edit(city: 'Tacna');
    repo.pendingUpdate = Completer<void>();
    final saving = model.save();
    container.dispose();
    repo.pendingUpdate!.complete();
    await saving;
  });

  for (final small in [false, true]) {
    testWidgets(
      'Profile fields persist through save error and remain reachable; small=$small',
      (tester) async {
        await tester.runAsync(
          () => container.read(profileViewModelProvider.future),
        );
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(small ? 2 : 1),
                ),
                child: const Scaffold(
                  body: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: ProfileEditor(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNWidgets(2));
        expect(
          tester.widget<SelectableText>(find.byType(SelectableText)).data,
          'ana@example.invalid',
        );
        await tester.enterText(find.byType(TextField).first, 'María');
        await tester.pump();
        repo.failUpdate = true;
        await tester.ensureVisible(find.text('Guardar cambios'));
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();
        expect(
          container.read(profileViewModelProvider).requireValue.displayName,
          'María',
        );
        expect(find.textContaining('Conservamos tus cambios'), findsOneWidget);
        repo.failUpdate = false;
        await tester.ensureVisible(find.text('Guardar cambios'));
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsOneWidget);
        await tester.pump(const Duration(seconds: 4));
        expect(find.text('Cambios guardados'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
