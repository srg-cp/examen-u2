import 'dart:async';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_list_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pets_section.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_skeleton.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_pets.dart';

void main() {
  for (final small in [false, true]) {
    testWidgets(
      'Initial skeleton becomes error then confirmed empty, without visible loading text; small=$small',
      (tester) async {
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final pets = FakePets()..pendingList = Completer<void>();
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            petRepositoryProvider.overrideWithValue(pets),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await auth.controller.close();
        });
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
                  size: small ? const Size(320, 350) : const Size(390, 844),
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: small,
                ),
                child: const Scaffold(
                  body: SingleChildScrollView(
                    child: StaggerReveal(count: 2, child: PetsSection()),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(PetSkeleton), findsOneWidget);
        expect(find.textContaining('Cargando'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Aún no tienes mascotas'), findsNothing);
        pets.fail = true;
        pets.pendingList!.complete();
        await tester.pumpAndSettle();
        expect(find.text('No se pudo cargar la información.'), findsOneWidget);
        expect(find.byType(PetSkeleton), findsNothing);
        pets.fail = false;
        pets.pendingList = null;
        await tester.ensureVisible(find.text('Reintentar'));
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();
        expect(find.text('Aún no tienes mascotas'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Refresh keeps own cards, account switch immediately masks them with skeleton',
    (tester) async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final pets = FakePets();
      pets.pets['pet'] = const Pet(
        id: 'pet',
        ownerId: 'one',
        fields: PetFields(name: 'Luna', species: PetSpecies.dog),
        version: 1,
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          petRepositoryProvider.overrideWithValue(pets),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: StaggerReveal(count: 2, child: PetsSection()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Luna'), findsOneWidget);
      pets.pendingList = Completer<void>();
      container.read(petListViewModelProvider.notifier).reload();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Luna'), findsOneWidget);
      expect(find.byType(PetSkeleton), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      auth.emit(const AuthSession(userId: 'two'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Luna'), findsNothing);
      expect(find.byType(PetSkeleton), findsOneWidget);
      pets.pendingList!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Aún no tienes mascotas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
