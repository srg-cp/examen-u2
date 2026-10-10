import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'support/fake_password_recovery.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/repositories/lost_case_repository.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/use_cases/publish_lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/view_models/case_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/view_models/case_read_view_model.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/state/case_editor_state.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/screens/case_editor_screen.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/screens/case_detail_screen.dart';
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;

const fields = PetFields(
  name: 'Luna',
  species: PetSpecies.dog,
  size: PetSize.small,
  ageMonths: 12,
  traits: 'Blanca con manchas negras',
);

class FakeCases implements LostCaseRepository {
  final attempts = <LostCaseDraft>[];
  bool loseResponse = false, failRead = false, wrongOwner = false;
  Completer<void>? pending;
  Completer<void>? pendingRead;
  PublicLostCase? publicCase;
  @override
  Future<PublishedLostCase> publish(String owner, LostCaseDraft draft) async {
    attempts.add(draft);
    await pending?.future;
    if (loseResponse) {
      loseResponse = false;
      throw const CaseFailure(CaseFailureKind.unavailable);
    }
    return PublishedLostCase(
      id: draft.id,
      ownerId: wrongOwner ? 'foreign' : owner,
      petId: draft.petId,
      status: 'active',
    );
  }

  @override
  Future<PublicLostCase?> readPublic(String id) async {
    await pendingRead?.future;
    if (failRead) throw const CaseFailure(CaseFailureKind.unavailable);
    return publicCase;
  }

  @override
  Future<List<PublishedLostCase>> listMine(String owner) async => [];
}

LostCaseDraft draft({
  double lat = -12.0464,
  List<String> photos = const ['photo'],
  DateTime? time,
}) => LostCaseDraft(
  id: 'case',
  petId: 'pet',
  petVersion: 1,
  occurredAt: time ?? DateTime.utc(2026, 10, 9),
  latitude: lat,
  longitude: -77.0428,
  placeReference: 'Referencia privada',
  photoIds: photos,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        );
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });
  test(
    'Publication rejects invalid coordinates, future time, duplicate/absent photos, and untrusted success',
    () async {
      final repo = FakeCases();
      final usecase = PublishLostCase(repo);
      for (final invalid in [
        draft(lat: double.nan),
        draft(lat: 86),
        draft(photos: []),
        draft(photos: ['photo', 'photo']),
        draft(time: DateTime.now().add(const Duration(days: 1))),
      ]) {
        await expectLater(usecase('one', invalid), throwsA(isA<CaseFailure>()));
      }
      expect(repo.attempts, isEmpty);
      repo.wrongOwner = true;
      await expectLater(
        PublishLostCase(repo)('one', draft()),
        throwsA(isA<CaseFailure>()),
      );
    },
  );
  late FakeAuthRepository auth;
  late FakePets pets;
  late FakePetPhotos photos;
  late FakeCases cases;
  late ProviderContainer container;
  setUp(() {
    auth = FakeAuthRepository()..current = const AuthSession(userId: 'one');
    pets = FakePets()
      ..pets['pet'] = const Pet(
        id: 'pet',
        ownerId: 'one',
        fields: fields,
        version: 1,
      );
    photos = FakePetPhotos()
      ..photos['photo'] = const PetPhoto(
        id: 'photo',
        petId: 'pet',
        ownerId: 'one',
        ready: true,
        isPrimary: true,
      );
    cases = FakeCases();
    container = ProviderContainer(
      overrides: [
        startupStateProvider.overrideWithValue(
          const StartupState(StartupStatus.ready),
        ),
        onboardingRepositoryProvider.overrideWithValue(
          FakeOnboarding(auth)..completed.add('one'),
        ),
        passwordRecoveryRepositoryProvider.overrideWithValue(
          FakePasswordRecovery(),
        ),
        authRepositoryProvider.overrideWithValue(auth),
        petRepositoryProvider.overrideWithValue(pets),
        petPhotoRepositoryProvider.overrideWithValue(photos),
        lostCaseRepositoryProvider.overrideWithValue(cases),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });
  Future<void> init() async {
    container.listen(caseEditorViewModelProvider, (_, _) {});
    await container.read(caseEditorViewModelProvider.future);
    final model = container.read(caseEditorViewModelProvider.notifier);
    await model.selectPet('pet');
    model.togglePhoto('photo');
    model.edit(
      occurredAt: DateTime.utc(2026, 10, 9),
      latitude: -12.0464,
      longitude: -77.0428,
      placeReference: 'Referencia privada',
    );
  }

  Future<void> tick() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  testWidgets(
    'Report entry opens protected editor; dirty exit cancels or discards; signed out routes redirect',
    (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Reportar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mascota perdida'));
      await tester.pumpAndSettle();
      expect(find.byType(CaseEditorScreen), findsOneWidget);
      container
          .read(caseEditorViewModelProvider.notifier)
          .edit(placeReference: 'Borrador privado');
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      expect(find.text('¿Salir del reporte?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(
        container.read(caseEditorViewModelProvider).requireValue.placeReference,
        'Borrador privado',
      );
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Salir'));
      await tester.pumpAndSettle();
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/home',
      );
      auth.emit(null);
      await tester.pumpAndSettle();
      for (final path in [
        '/home/lost-cases/new',
        '/home/my-cases',
        '/home/cases/case',
      ]) {
        container.read(routerProvider).go(path);
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'Explicit refresh retains content on failure and ignores results after account changes',
    () async {
      cases.publicCase = PublicLostCase(
        id: 'case',
        status: 'active',
        occurredAt: DateTime.utc(2026, 10, 9),
        latitude: -12.045,
        longitude: -77.045,
        fields: fields,
        photos: [],
      );
      final sub = container.listen(
        publicCaseViewModelProvider('case'),
        (_, _) {},
      );
      final original = (await container.read(
        publicCaseViewModelProvider('case').future,
      )).value;
      final vm = container.read(publicCaseViewModelProvider('case').notifier);
      cases.pendingRead = Completer<void>();
      final refreshing = vm.retry();
      expect(
        container
            .read(publicCaseViewModelProvider('case'))
            .requireValue
            .refreshing,
        true,
      );
      expect(
        container.read(publicCaseViewModelProvider('case')).requireValue.value,
        same(original),
      );
      cases.failRead = true;
      cases.pendingRead!.complete();
      await refreshing;
      expect(
        container
            .read(publicCaseViewModelProvider('case'))
            .requireValue
            .refreshFailed,
        true,
      );
      expect(
        container.read(publicCaseViewModelProvider('case')).requireValue.value,
        same(original),
      );
      cases.failRead = false;
      cases.pendingRead = Completer<void>();
      final late = vm.retry();
      auth.emit(const AuthSession(userId: 'two'));
      await tick();
      expect(
        container.read(publicCaseViewModelProvider('case')).isLoading,
        true,
      );
      cases.pendingRead!.complete();
      await late;
      expect(
        (await container.read(
          publicCaseViewModelProvider('case').future,
        )).ownerId,
        'two',
      );
      sub.close();
    },
  );

  test(
    'Lost response freezes exact command; duplicate taps blocked; retry confirms once',
    () async {
      await init();
      final model = container.read(caseEditorViewModelProvider.notifier);
      model.preview();
      cases.loseResponse = true;
      await model.publish();
      final saved = container.read(caseEditorViewModelProvider).requireValue;
      expect(saved.stage, CaseEditorStage.preview);
      expect(saved.lockedDraft, isNotNull);
      model.edit(placeReference: 'Changed');
      model.backToForm();
      expect(
        container.read(caseEditorViewModelProvider).requireValue.placeReference,
        'Referencia privada',
      );
      cases.pending = Completer<void>();
      final writing = model.publish();
      await model.publish();
      expect(cases.attempts.length, 2);
      cases.pending!.complete();
      await writing;
      expect(identical(cases.attempts[0], cases.attempts[1]), true);
      expect(
        container.read(caseEditorViewModelProvider).requireValue.stage,
        CaseEditorStage.confirmed,
      );
      expect(
        container.read(caseEditorViewModelProvider).requireValue.dirty,
        false,
      );
      expect(
        container
            .read(caseEditorViewModelProvider)
            .requireValue
            .published!
            .ownerId,
        'one',
      );
    },
  );
  test(
    'Session change discards draft and late publication; same account recovers after stream failure',
    () async {
      await init();
      final model = container.read(caseEditorViewModelProvider.notifier);
      model.preview();
      cases.pending = Completer<void>();
      final writing = model.publish();
      auth.emit(const AuthSession(userId: 'two'));
      await tick();
      expect(
        (await container.read(caseEditorViewModelProvider.future)).ownerId,
        'two',
      );
      cases.pending!.complete();
      await writing;
      expect(
        container.read(caseEditorViewModelProvider).requireValue.published,
        isNull,
      );
      auth.controller.addError(StateError('stream failed'));
      await tick();
      expect(container.read(caseEditorViewModelProvider).hasError, true);
      auth.emit(const AuthSession(userId: 'two'));
      await tick();
      expect(
        (await container.read(caseEditorViewModelProvider.future)).ownerId,
        'two',
      );
    },
  );
  test(
    'Invalid form never writes; explicit pet reread updates version; public failure remains distinct from absence',
    () async {
      await init();
      final model = container.read(caseEditorViewModelProvider.notifier);
      model.togglePhoto('photo');
      model.preview();
      await model.publish();
      expect(cases.attempts, isEmpty);
      pets.pets['pet'] = const Pet(
        id: 'pet',
        ownerId: 'one',
        fields: fields,
        version: 2,
      );
      await model.selectPet('pet');
      expect(
        container.read(caseEditorViewModelProvider).requireValue.pet!.version,
        2,
      );
      cases.failRead = true;
      final sub = container.listen(
        publicCaseViewModelProvider('case'),
        (_, _) {},
      );
      await expectLater(
        container.read(publicCaseViewModelProvider('case').future),
        throwsA(isA<CaseFailure>()),
      );
      cases.failRead = false;
      container.read(publicCaseViewModelProvider('case').notifier).retry();
      expect(
        (await container.read(
          publicCaseViewModelProvider('case').future,
        )).value,
        null,
      );
      sub.close();
    },
  );

  for (final (size, scale) in [
    (const Size(390, 844), 1.0),
    (const Size(320, 350), 2.0),
  ]) {
    testWidgets(
      'Form, preview, error and confirmed public content fit $size with text $scale',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final capture = Platform.environment['CAPTURE_CASES'] == '1';
        if (capture) {
          await tester.runAsync(() async {
            final configFile = File('.dart_tool/package_config.json').absolute;
            final config =
                jsonDecode(await configFile.readAsString())
                    as Map<String, dynamic>;
            final flutter = (config['packages'] as List)
                .cast<Map<String, dynamic>>()
                .firstWhere((p) => p['name'] == 'flutter');
            final root = configFile.uri
                .resolve('${flutter['rootUri']}/')
                .resolve('../../bin/cache/artifacts/material_fonts/');
            for (final entry in {
              'sans-serif': [
                'roboto-regular.ttf',
                'roboto-medium.ttf',
                'roboto-bold.ttf',
              ],
              'MaterialIcons': ['materialicons-regular.otf'],
            }.entries) {
              final loader = FontLoader(entry.key);
              for (final file in entry.value) {
                loader.addFont(
                  File.fromUri(
                    root.resolve(file),
                  ).readAsBytes().then(ByteData.sublistView),
                );
              }
              await loader.load();
            }
          });
        }
        final boundary = GlobalKey();
        Future<void> shot(String name) async {
          if (!capture) return;
          await tester.pump();
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            final img = await render.toImage();
            final data = await img.toByteData(format: ui.ImageByteFormat.png);
            final folder = Directory('build/ui-preview/cases')
              ..createSync(recursive: true);
            await File(
              '${folder.path}/${size.width.toInt()}-$name.png',
            ).writeAsBytes(data!.buffer.asUint8List());
            img.dispose();
          });
        }

        pets.pendingList = Completer<void>();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: RepaintBoundary(
                key: boundary,
                child: const CaseEditorScreen(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        await shot('loading');
        pets.fail = true;
        pets.pendingList!.complete();
        await tester.pumpAndSettle();
        expect(find.text('Reintentar'), findsOneWidget);
        await shot('query-error');
        pets.fail = false;
        pets.pendingList = null;
        pets.pets.clear();
        container.read(caseEditorViewModelProvider.notifier).retry();
        await tester.pumpAndSettle();
        expect(find.text('Registrar mascota'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Mascota perdida')).dy,
          greaterThanOrEqualTo(0),
        );
        await shot('empty');
        pets.pets['pet'] = const Pet(
          id: 'pet',
          ownerId: 'one',
          fields: fields,
          version: 1,
        );
        container.read(caseEditorViewModelProvider.notifier).retry();
        await tester.pumpAndSettle();
        await tester.runAsync(init);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await shot('form');
        final model = container.read(caseEditorViewModelProvider.notifier);
        model.preview();
        await tester.pumpAndSettle();
        expect(find.text('Vista previa pública'), findsOneWidget);
        expect(find.text('Referencia privada'), findsNothing);
        await shot('preview');
        cases.loseResponse = true;
        await tester.runAsync(model.publish);
        await tester.pumpAndSettle();
        await shot('error');
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -2000),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final publishButton = find.widgetWithText(
          FilledButton,
          'Publicar caso',
        );
        await tester.ensureVisible(publishButton);
        await tester.pumpAndSettle();
        expect(
          tester.getRect(publishButton).bottom,
          lessThanOrEqualTo(size.height),
        );
        await shot('actions');
        await tester.runAsync(model.publish);
        await tester.pumpAndSettle();
        expect(find.text('Caso publicado'), findsOneWidget);
        await shot('confirmed');
        cases.publicCase = PublicLostCase(
          id: 'case',
          status: 'active',
          occurredAt: DateTime.utc(2026, 10, 9),
          latitude: -12.045,
          longitude: -77.045,
          fields: fields,
          photos: [],
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: RepaintBoundary(
                key: boundary,
                child: const CaseDetailScreen(id: 'case'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Luna'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await shot('public');
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
