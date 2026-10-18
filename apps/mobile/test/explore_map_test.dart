import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_entrehuellas/app/navigation/entity_editor_page.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_filter_editor.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/state/explore_filter_selection.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_section.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/screens/explore_map_screen.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_query.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_case_map.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'explore_test.dart' show SearchFake, item;
import 'support/fake_current_location.dart';
import 'lost_cases_test.dart' show FakeCases;
import 'found_cases_test.dart' show FakeFoundCases;
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_map_pin.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_map_case_preview.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_photo.dart';
import 'package:flutter_application_entrehuellas/core/presentation/formatters/case_date_label.dart';

class _MemoryTiles extends TileProvider {
  _MemoryTiles(this.bytes);
  final Uint8List bytes;
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => Directory.systemTemp.path,
        );
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  for (final reduced in [false, true]) {
    testWidgets(
      'Map opens from its option, shares results, opens detail and returns; reduced=$reduced',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = reduced
            ? const Size(320, 350)
            : const Size(390, 844);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final photoUri = Uri.parse('https://example.com/map-preview.png');
        await tester.runAsync(() async {
          final bytes = await File(
            'assets/onboarding/dog_and_cat.png',
          ).readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          PaintingBinding.instance.imageCache.putIfAbsent(
            NetworkImage(photoUri.toString()),
            () => OneFrameImageStreamCompleter(
              Future.value(ImageInfo(image: frame.image)),
            ),
          );
          codec.dispose();
        });
        addTearDown(
          () => PaintingBinding.instance.imageCache.evict(
            NetworkImage(photoUri.toString()),
          ),
        );
        final repo = SearchFake()
          ..firstPage = [item('one', coverUri: photoUri)];
        await tester.runAsync(loadFonts);
        final boundary = GlobalKey();
        final tileBytes = await tester.runAsync(_neutralTile);
        OriginPageSource? source;
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const Scaffold(
                body: SingleChildScrollView(child: ExploreSection()),
              ),
              routes: [
                GoRoute(
                  path: 'explore-map',
                  pageBuilder: (context, state) {
                    source = state.extra as OriginPageSource;
                    return entityEditorPage(
                      context: context,
                      key: state.pageKey,
                      source: state.extra,
                      child: ExploreMapScreen(
                        createTileProvider: () => _MemoryTiles(tileBytes!),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'cases/:id',
                  builder: (context, state) => Scaffold(
                    body: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Volver al mapa ${state.pathParameters['id']}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              exploreRepositoryProvider.overrideWithValue(repo),
              lostCaseRepositoryProvider.overrideWithValue(
                FakeCases()
                  ..publicCase = PublicLostCase(
                    id: 'one',
                    status: 'active',
                    occurredAt: DateTime.utc(2026, 10, 14),
                    latitude: -12.05,
                    longitude: -77.04,
                    fields: const PetFields(
                      name: 'Luna',
                      species: PetSpecies.dog,
                      size: PetSize.medium,
                    ),
                    photos: [],
                  ),
              ),
              foundCaseRepositoryProvider.overrideWithValue(FakeFoundCases()),
              currentLocationRepositoryProvider.overrideWithValue(
                const FakeCurrentLocation(),
              ),
              exploreSessionProvider.overrideWith(
                (_) => Stream.value(const AuthSession(userId: 'a')),
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
              builder: (context, child) => RepaintBoundary(
                key: boundary,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    disableAnimations: reduced,
                    textScaler: TextScaler.linear(reduced ? 2 : 1),
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                  ),
                  child: child!,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ExploreSection)),
        );
        final initial = container.read(exploreViewModelProvider).requireValue;
        await tester.ensureVisible(find.text('Mapa'));
        await tester.pumpAndSettle();
        final option = find
            .ancestor(of: find.text('Mapa'), matching: find.byType(InkWell))
            .first;
        final bounds = tester.getRect(option);
        await tester.tap(find.text('Mapa'));
        await tester.pumpAndSettle();
        expect(find.byType(ExploreMapScreen), findsOneWidget);
        expect(source!.bounds, bounds);
        expect(
          container.read(exploreViewModelProvider).requireValue.query,
          same(initial.query),
        );
        expect(repo.calls, hasLength(1));
        expect(
          container.read(exploreViewModelProvider).requireValue.items,
          same(initial.items),
        );
        expect(
          container.read(exploreViewModelProvider).requireValue.cursor,
          initial.cursor,
        );
        if (const bool.fromEnvironment('CAPTURE_EXPLORE_MAP')) {
          await tester.runAsync(() async {
            final raster =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await raster.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final dir = Directory('build/ui-preview/explore-map')
              ..createSync(recursive: true);
            File(
              '${dir.path}/screen-${reduced ? 'small' : 'normal'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            raster.dispose();
          });
        }
        final sheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        final before = sheet.controller!.size;
        expect(sheet.minChildSize, .42);
        expect(find.text('Filtros de búsqueda'), findsNothing);
        final back = find.byTooltip('Volver a Explorar');
        double backOpacity() => tester
            .widgetList<Opacity>(
              find.ancestor(of: back, matching: find.byType(Opacity)),
            )
            .first
            .opacity;
        final backTop = tester.getTopLeft(back).dy;
        sheet.controller!.jumpTo(.9);
        await tester.pumpAndSettle();
        expect(backOpacity(), 0);
        if (!reduced) expect(tester.getTopLeft(back).dy, lessThan(backTop));
        await capturePanel(
          tester,
          boundary,
          reduced ? 'small-expanded' : 'normal-expanded',
        );
        sheet.controller!.jumpTo(.42);
        await tester.pumpAndSettle();
        expect(backOpacity(), 1);
        expect(tester.getTopLeft(back).dy, backTop);
        final surface = find.byKey(const ValueKey('map-filters-surface'));
        final normalTop = tester.getTopLeft(surface).dy;
        final drag = await tester.startGesture(
          tester.getCenter(
            find.bySemanticsLabel('Desliza para ampliar o reducir los filtros'),
          ),
        );
        await drag.moveBy(const Offset(0, 100));
        await tester.pump();
        expect(sheet.controller!.size, closeTo(.42, .001));
        if (!reduced) {
          expect(tester.getTopLeft(surface).dy, greaterThan(normalTop));
          expect(
            tester.getTopLeft(surface).dy - normalTop,
            lessThanOrEqualTo(18),
          );
        }
        await drag.up();
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(surface).dy, closeTo(normalTop, .01));
        expect(sheet.controller!.size, closeTo(.42, .001));
        await tester.drag(
          find.bySemanticsLabel('Desliza para ampliar o reducir los filtros'),
          Offset(0, -tester.view.physicalSize.height * .5),
        );
        await tester.pumpAndSettle();
        expect(sheet.controller!.size, greaterThan(before));
        expect(find.text('Abrir caso'), findsNothing);
        await Scrollable.ensureVisible(
          tester.element(find.text('Perdidas')),
          alignment: .5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Perdidas'));
        await tester.pumpAndSettle();
        expect(repo.calls, hasLength(1));
        await tester.tap(find.text('Aplicar filtros'));
        await tester.pumpAndSettle();
        expect(repo.calls, hasLength(2));
        expect(repo.calls.last.$2.kind, ExploreKind.lost);
        final applied = container
            .read(exploreViewModelProvider)
            .requireValue
            .query;
        sheet.controller!.jumpTo(.42);
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Seleccionar caso'));
        await tester.pumpAndSettle();
        expect(find.text('Abrir caso'), findsNothing);
        expect(find.text('Mediano'), findsOneWidget);
        expect(find.text('Raza no registrada'), findsOneWidget);
        final dateLabel =
            'Desaparición: ${caseDateOnlyLabel(DateTime.utc(2026, 10, 14))}';
        expect(find.text(dateLabel), findsOneWidget);
        expect(find.byType(CasePhotoView), findsOneWidget);
        expect(
          tester
              .getBottomLeft(find.byKey(const ValueKey('map-preview-photo')))
              .dy,
          lessThan(
            tester
                .getTopLeft(find.byKey(const ValueKey('map-preview-facts')))
                .dy,
          ),
        );
        final sizeIcon = tester.getCenter(
          find.byIcon(Icons.straighten_rounded),
        );
        final dateIcon = tester.getCenter(
          find.byIcon(Icons.calendar_today_outlined),
        );
        expect(sizeIcon.dy, closeTo(dateIcon.dy, .01));
        expect(sizeIcon.dx, lessThan(dateIcon.dx));
        expect(
          tester.getBottomLeft(find.byType(ExploreMapPreviewContent)).dy,
          lessThanOrEqualTo(
            tester
                .getTopLeft(find.byKey(const ValueKey('map-filters-surface')))
                .dy,
          ),
        );
        await Scrollable.ensureVisible(tester.element(find.text(dateLabel)));
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.text(dateLabel)).dy,
          lessThanOrEqualTo(
            tester.getBottomLeft(find.byType(ExploreMapPreviewContent)).dy,
          ),
        );
        await Scrollable.ensureVisible(tester.element(find.text('Luna')));
        await tester.pumpAndSettle();
        expect(find.byType(ExploreMapPin), findsOneWidget);
        await capturePanel(
          tester,
          boundary,
          reduced ? 'small-preview-photo' : 'normal-preview-photo',
        );
        await tester.tap(find.text('Luna'));
        await tester.pumpAndSettle();
        expect(find.text('Volver al mapa one'), findsOneWidget);
        await tester.tap(find.text('Volver al mapa one'));
        await tester.pumpAndSettle();
        expect(find.byType(ExploreMapScreen), findsOneWidget);
        expect(repo.calls, hasLength(3));
        await tester.tap(find.byTooltip('Volver a Explorar'));
        await tester.pumpAndSettle();
        expect(find.byType(ExploreMapScreen), findsNothing);
        expect(find.text('Explorar'), findsOneWidget);
        expect(repo.calls, hasLength(3));
        expect(
          container.read(exploreViewModelProvider).requireValue.query,
          same(applied),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final small in [false, true]) {
    testWidgets(
      'Public map groups coincident origins, opens each card, and permits navigation without editing; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        late Uint8List tileBytes;
        await tester.runAsync(() async {
          await loadFonts();
          final recorder = ui.PictureRecorder();
          Canvas(recorder).drawColor(const Color(0xFFF5F5F7), BlendMode.src);
          final picture = recorder.endRecording();
          final image = await picture.toImage(256, 256);
          tileBytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
          image.dispose();
          picture.dispose();
        });
        final boundary = GlobalKey();
        final opened = <String>[];
        const query = ExploreQuery(
          latitude: -12.05,
          longitude: -77.04,
          radiusMeters: 15000,
        );
        final items = [
          item('same', name: 'Luna'),
          item('same', fromPet: false, name: 'Sol'),
        ];
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: tester.view.physicalSize,
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: small,
              ),
              child: Scaffold(
                body: RepaintBoundary(
                  key: boundary,
                  child: ColoredBox(
                    color: Colors.white,
                    child: ExploreCaseMap(
                      items: items,
                      query: query,
                      createTileProvider: () => _MemoryTiles(tileBytes),
                      filterBuilder: (_, scroll, handle, _) =>
                          ExploreFilterEditor(
                            initial: ExploreFilterSelection.fromQuery(query),
                            allFilters: true,
                            showMap: false,
                            scrollController: scroll,
                            headerSliver: handle,
                            onConfirm: (_) {},
                          ),
                      onOpen: (value, _) => opened.add(value.key),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final picker = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
        expect(picker.readOnly, true);
        expect(picker.readOnlyNavigation, true);
        expect(picker.onSelect, isNull);
        expect(picker.markers, hasLength(1));
        expect(picker.markers.single.point.latitude, items.first.latitude);
        expect(picker.markers.single.point.longitude, items.first.longitude);
        expect(
          tester.getSize(find.byType(FlutterMap)),
          tester.view.physicalSize,
        );
        await tester.ensureVisible(find.byTooltip('Ver 2 casos'));
        await tester.tap(find.byTooltip('Ver 2 casos'));
        await tester.pumpAndSettle();
        final sheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        expect(sheet.controller!.size, closeTo(.42, .01));
        await capturePanel(
          tester,
          boundary,
          small ? 'small-preview-selected' : 'normal-preview-selected',
        );
        for (final name in ['Luna', 'Sol']) {
          if (name == 'Sol') {
            await Scrollable.ensureVisible(
              tester.element(find.byTooltip('Caso siguiente')),
              alignment: .5,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.byTooltip('Caso siguiente'));
            await tester.pumpAndSettle();
            expect(find.text('Luna'), findsNothing);
          } else {
            expect(find.text('Sol'), findsNothing);
          }
          expect(find.text(name), findsOneWidget);
          expect(find.text('Abrir caso'), findsNothing);
          await tester.pumpAndSettle();
          await Scrollable.ensureVisible(tester.element(find.text(name)));
          await tester.pumpAndSettle();
          await tester.tap(find.text(name));
        }
        expect(opened, ['lost:same', 'found:same']);
        sheet.controller!.jumpTo(.42);
        await tester.pumpAndSettle();
        if (const bool.fromEnvironment('CAPTURE_EXPLORE_MAP')) {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final dir = Directory('build/ui-preview/explore-map')
              ..createSync(recursive: true);
            File(
              '${dir.path}/${small ? 'small' : 'normal'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        final center = MapController.of(
          tester.element(find.byType(TileLayer)),
        ).camera.center;
        sheet.controller!.jumpTo(.42);
        await tester.pumpAndSettle();
        await tester.dragFrom(const Offset(100, 80), const Offset(60, 0));
        await tester.pumpAndSettle();
        expect(
          MapController.of(
            tester.element(find.byType(TileLayer)),
          ).camera.center,
          isNot(center),
        );
        expect(picker.latitude, query.latitude);
        expect(picker.longitude, query.longitude);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}

Future<Uint8List> _neutralTile() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawColor(const Color(0xFFF5F5F7), BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(256, 256);
  final bytes = (await image.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return bytes;
}

Future<void> capturePanel(
  WidgetTester tester,
  GlobalKey boundary,
  String name,
) async {
  if (!const bool.fromEnvironment('CAPTURE_EXPLORE_MAP')) return;
  await tester.runAsync(() async {
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/ui-preview/explore-map')
      ..createSync(recursive: true);
    await File(
      '${dir.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
