import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_page.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_query.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_case_map.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'explore_test.dart' show SearchFake, item;
import 'support/fake_current_location.dart';

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

  test(
    'View changes preserve exact query/pages without new requests; map survives retries and filters',
    () async {
      final repo = SearchFake();
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(repo),
          currentLocationRepositoryProvider.overrideWithValue(
            const FakeCurrentLocation(),
          ),
          exploreSessionProvider.overrideWith(
            (_) => Stream.value(const AuthSession(userId: 'a')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        exploreViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      final initial = await container.read(exploreViewModelProvider.future);
      final vm = container.read(exploreViewModelProvider.notifier);
      vm.selectMap(true);
      var state = container.read(exploreViewModelProvider).requireValue;
      expect(state.mapSelected, true);
      expect(state.query, same(initial.query));
      expect(state.items.map((e) => e.key), initial.items.map((e) => e.key));
      expect(state.cursor, initial.cursor);
      expect(repo.calls, hasLength(1));
      repo.fail = true;
      await vm.more();
      expect(
        container.read(exploreViewModelProvider).requireValue.mapSelected,
        true,
      );
      repo.fail = false;
      repo.pending = Completer<ExplorePage>();
      final loading = vm.more();
      vm.selectMap(false);
      expect(
        container.read(exploreViewModelProvider).requireValue.mapSelected,
        true,
      );
      repo.pending!.complete(
        ExplorePage(items: [item('one', fromPet: false), item('two')]),
      );
      await loading;
      state = container.read(exploreViewModelProvider).requireValue;
      expect(state.items.map((e) => e.key), [
        'lost:one',
        'found:one',
        'lost:two',
      ]);
      vm.selectMap(false);
      expect(
        container.read(exploreViewModelProvider).requireValue.items,
        state.items,
      );
      expect(repo.calls, hasLength(3));
      vm.selectMap(true);
      repo.pending = null;
      await vm.apply(
        kind: ExploreKind.found,
        species: ExploreSpecies.cat,
        status: ExploreStatus.active,
        days: 7,
        latitude: -12.1,
        longitude: -77.1,
        radiusMeters: 1000,
      );
      state = container.read(exploreViewModelProvider).requireValue;
      expect(state.mapSelected, true);
      expect(state.query.kind, ExploreKind.found);
      expect(state.query.radiusMeters, 1000);
      expect(repo.calls.last.$3, isNull);
    },
  );

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
                    child: SingleChildScrollView(
                      child: ExploreCaseMap(
                        items: items,
                        query: query,
                        createTileProvider: () => _MemoryTiles(tileBytes),
                        onOpen: (value, _) => opened.add(value.key),
                      ),
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
        await tester.ensureVisible(find.byTooltip('Ver 2 casos'));
        await tester.tap(find.byTooltip('Ver 2 casos'));
        await tester.pumpAndSettle();
        for (final name in ['Luna', 'Sol']) {
          await tester.ensureVisible(find.text(name));
          await tester.pumpAndSettle();
          await tester.tap(find.text(name));
        }
        expect(opened, ['lost:same', 'found:same']);
        await tester.ensureVisible(find.byType(FlutterMap));
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
        await tester.drag(find.byType(FlutterMap), const Offset(60, 0));
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
