import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_cards.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/glass_navigation_button.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/domain/entities/case_poster.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/domain/entities/case_share.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/domain/repositories/case_share_repository.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/data/models/poster_payload.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/data/data_sources/case_share_source.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/data/repositories/case_share_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/providers/case_poster_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/presentation/view_models/case_share_view_model.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/presentation/widgets/case_share_button.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/presentation/widgets/case_share_sheet.dart';
import 'case_posters_test.dart' show CaseSourceFake, FastDocumentSource, target;
import 'alert_preferences_test.dart' show loadFonts;

class ShareSourceFake implements CaseShareSource {
  final inner = CaseSourceFake();
  bool changeOnRecheck = false;
  @override
  void checkSession(String actor) => inner.checkOwner(actor);
  @override
  Future<PosterPayload> prepare(String actor, PosterCase target) {
    if (changeOnRecheck && inner.calls > 0) inner.revision = 'changed';
    return inner.prepare(actor, target);
  }

  @override
  Future<Uint8List> photo(String actor, PosterCase target, String path) =>
      inner.photo(actor, target, path);
}

class ShareActionsFake implements CaseShareActionSource {
  final channels = <CaseShareChannel>[];
  Uri? url;
  PosterDocument? document;
  @override
  Future<CaseShareResult> handoff(
    CaseShareChannel channel,
    Uri publicUrl,
    PosterDocument? doc,
  ) async {
    channels.add(channel);
    url = publicUrl;
    document = doc;
    return CaseShareResult.opened;
  }
}

class ShareRepositoryFake implements CaseShareRepository {
  final calls = <CaseShareChannel>[];
  Completer<CaseShareResult>? pending;
  @override
  Future<CaseShareResult> execute(
    String actor,
    PosterCase target,
    CaseShareChannel channel,
  ) async {
    calls.add(channel);
    if (pending != null) return pending!.future;
    return channel == CaseShareChannel.copyLink
        ? CaseShareResult.copied
        : CaseShareResult.opened;
  }
}

void main() {
  testWidgets('Narrow header keeps title below the three glass controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CasePublicScreenShell(
          loading: false,
          onBack: () {},
          trailingAction: GlassNavigationButton(
            tooltip: 'Guardar caso',
            onPressed: () {},
          ),
          shareAction: CaseShareButton(
            target: target,
            title: 'Bruno',
            eventLabel: 'Mascota perdida',
            onReport: () {},
          ),
          child: const SizedBox(height: 100),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final titleRect = tester.getRect(find.text('Ficha pública'));
    final shareRect = tester.getRect(find.byTooltip('Compartir ficha'));
    expect(titleRect.top, greaterThan(shareRect.bottom));
    expect(tester.takeException(), isNull);
  });
  test(
    'Sharing uses only the opaque public URL; PDF and handoff revalidate current revision',
    () async {
      for (final channel in CaseShareChannel.values) {
        final source = ShareSourceFake();
        final actions = ShareActionsFake();
        final repo = CaseShareRepositoryImpl(
          source,
          FastDocumentSource(),
          actions,
          webBaseUrl: 'https://example.com/project/',
          publicWebReady: true,
        );
        await repo.execute('a', target, channel);
        expect(source.inner.calls, 2);
        expect(
          actions.url.toString(),
          'https://example.com/project/c/${'a' * 64}',
        );
        expect(actions.url!.query, isEmpty);
        expect(actions.channels, [channel]);
        expect(actions.document != null, channel == CaseShareChannel.download);
      }
      final source = ShareSourceFake()..changeOnRecheck = true;
      final actions = ShareActionsFake();
      final repo = CaseShareRepositoryImpl(
        source,
        FastDocumentSource(),
        actions,
        webBaseUrl: 'https://example.com',
        publicWebReady: true,
      );
      await expectLater(
        repo.execute('a', target, CaseShareChannel.copyLink),
        throwsA(isA<PosterFailure>()),
      );
      expect(actions.channels, isEmpty);
    },
  );

  test(
    'Unready web and changed identity cannot create links or hand off data',
    () async {
      final source = ShareSourceFake();
      final actions = ShareActionsFake();
      final unready = CaseShareRepositoryImpl(
        source,
        FastDocumentSource(),
        actions,
        webBaseUrl: 'https://example.com',
        publicWebReady: false,
      );
      await expectLater(
        unready.execute('a', target, CaseShareChannel.whatsapp),
        throwsA(isA<PosterFailure>()),
      );
      expect(source.inner.calls, 0);
      final live = CaseShareRepositoryImpl(
        source,
        FastDocumentSource(),
        actions,
        webBaseUrl: 'https://example.com',
        publicWebReady: true,
      );
      source.inner.pending = Completer<PosterPayload>();
      final pending = live.execute('a', target, CaseShareChannel.facebook);
      source.inner.owner = 'b';
      source.inner.pending!.complete(
        PosterPayload({
          'id': target.id,
          'source': 'lost',
          'public_slug': 'a' * 64,
          'revision': 'r',
        }),
      );
      await expectLater(pending, throwsA(isA<PosterFailure>()));
      expect(actions.channels, isEmpty);
    },
  );

  test(
    'Sharing locks duplicate actions and drops completion from another account',
    () async {
      final repo = ShareRepositoryFake()
        ..pending = Completer<CaseShareResult>();
      final session = StreamController<AuthSession?>();
      final scope = ProviderContainer(
        overrides: [
          caseShareRepositoryProvider.overrideWithValue(repo),
          posterSessionProvider.overrideWith((ref) => session.stream),
        ],
      );
      final sub = scope.listen(caseShareViewModelProvider(target), (_, _) {});
      addTearDown(() async {
        sub.close();
        scope.dispose();
        await session.close();
      });
      session.add(const AuthSession(userId: 'a'));
      await scope.read(caseShareViewModelProvider(target).future);
      final vm = scope.read(caseShareViewModelProvider(target).notifier);
      final pending = vm.execute(CaseShareChannel.copyLink);
      await vm.execute(CaseShareChannel.download);
      expect(repo.calls, [CaseShareChannel.copyLink]);
      session.add(const AuthSession(userId: 'b'));
      await Future<void>.delayed(Duration.zero);
      await scope.read(caseShareViewModelProvider(target).future);
      repo.pending!.complete(CaseShareResult.copied);
      await pending;
      expect(
        scope.read(caseShareViewModelProvider(target)).requireValue.actor,
        'b',
      );
      expect(
        scope.read(caseShareViewModelProvider(target)).requireValue.notice,
        isNull,
      );
    },
  );

  for (final small in [false, true]) {
    for (final reduced in [false, true]) {
      testWidgets(
        'White sharing panel without X; actions/dismissal/accessibility small=$small reduced=$reduced',
        (tester) async {
          await tester.runAsync(() async {
            await loadFonts();
            final font = FontLoader('Poppins')
              ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
            await font.load();
          });
          tester.view.physicalSize = small
              ? const Size(320, 350)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final repo = ShareRepositoryFake();
          var reports = 0;
          var saves = 0;
          final boundary = GlobalKey();
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                caseShareRepositoryProvider.overrideWithValue(repo),
                posterSessionProvider.overrideWith(
                  (ref) => Stream.value(const AuthSession(userId: 'a')),
                ),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(small ? 2 : 1),
                    disableAnimations: reduced,
                  ),
                  child: RepaintBoundary(key: boundary, child: child!),
                ),
                home: CasePublicScreenShell(
                  loading: false,
                  onBack: () {},
                  trailingAction: GlassNavigationButton(
                    tooltip: 'Guardar caso',
                    icon: Icons.bookmark_border_rounded,
                    onPressed: () => saves++,
                  ),
                  shareAction: CaseShareButton(
                    target: target,
                    title: 'Bruno',
                    eventLabel: 'Mascota perdida',
                    onReport: () => reports++,
                  ),
                  child: CasePublicCards(
                    name: 'Bruno',
                    eventLabel: 'Perdido',
                    photos: [
                      Image.asset(
                        'assets/illustrations/community_pets.png',
                        fit: BoxFit.cover,
                      ),
                    ],
                    facts: const [
                      CasePublicFact('Especie', 'Perro'),
                      CasePublicFact('Tamaño', 'Mediano'),
                    ],
                    description: 'Pelaje dorado y collar azul.',
                    occurredAt: '20/10/2026',
                    locationLabel: 'Ubicación de desaparición',
                    latitude: -12,
                    longitude: -77,
                    privacy: 'Ubicación aproximada.',
                    createMapTileProvider: () => NetworkTileProvider(
                      httpClient: MockClient(
                        (request) async => http.Response.bytes(
                          TileProvider.transparentImage,
                          200,
                        ),
                      ),
                      cachingProvider: const DisabledMapCachingProvider(),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/illustrations/community_pets.png'),
              boundary.currentContext!,
            ),
          );
          await tester.pumpAndSettle();
          final saveRect = tester.getRect(find.byTooltip('Guardar caso'));
          final shareRect = tester.getRect(find.byTooltip('Compartir ficha'));
          expect(shareRect.right, lessThan(saveRect.left));
          await tester.tap(find.byTooltip('Compartir ficha'));
          await tester.pumpAndSettle();
          expect(find.byType(CaseShareSheet), findsOneWidget);
          expect(
            tester
                .widget<BottomSheet>(find.byType(BottomSheet))
                .backgroundColor,
            Colors.white,
          );
          expect(find.byIcon(Icons.close), findsNothing);
          expect(find.text('Descargar'), findsNothing);
          expect(find.text('Denunciar'), findsNothing);
          await tester.ensureVisible(find.byTooltip('Copiar enlace'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Copiar enlace'));
          await tester.pumpAndSettle();
          expect(repo.calls, [CaseShareChannel.copyLink]);
          expect(find.text('Enlace copiado'), findsOneWidget);
          await tester.pump(const Duration(seconds: 7));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byTooltip('Descargar ficha en PDF'));
          await tester.pumpAndSettle();
          final download = tester.getRect(
            find.byTooltip('Descargar ficha en PDF'),
          );
          expect(
            download.bottom,
            lessThanOrEqualTo(tester.view.physicalSize.height),
          );
          final report = tester.getRect(find.byTooltip('Denunciar contenido'));
          expect(download.center.dy, closeTo(report.center.dy, .1));
          expect(download.right, lessThan(report.left));
          repo.pending = Completer<CaseShareResult>();
          await tester.tap(find.byTooltip('Descargar ficha en PDF'));
          await tester.pump();
          expect(repo.calls.last, CaseShareChannel.download);
          repo.pending!.complete(CaseShareResult.cancelled);
          await tester.pumpAndSettle();
          expect(
            find.text('Acción cancelada. Puedes reintentar.'),
            findsOneWidget,
          );
          await tester.pump(const Duration(seconds: 7));
          await tester.pumpAndSettle();
          await _capture(
            tester,
            boundary,
            '${small ? 'small' : 'normal'}-${reduced ? 'reduced' : 'motion'}',
          );
          await tester.tap(find.byTooltip('Denunciar contenido'));
          await tester.pumpAndSettle();
          expect(reports, 1);
          expect(find.byType(CaseShareSheet), findsNothing);
          await tester.tap(find.byTooltip('Compartir ficha'));
          await tester.pumpAndSettle();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(CaseShareSheet), findsNothing);
          await tester.tap(find.byTooltip('Compartir ficha'));
          await tester.pumpAndSettle();
          final outsideTop = tester.getRect(find.byType(BottomSheet)).top;
          await tester.tapAt(Offset(10, outsideTop / 2));
          await tester.pumpAndSettle();
          expect(find.byType(CaseShareSheet), findsNothing);
          await tester.tap(find.byTooltip('Compartir ficha'));
          await tester.pumpAndSettle();
          final sheet = tester.getRect(find.byType(BottomSheet));
          await tester.dragFrom(
            Offset(sheet.center.dx, sheet.top + 12),
            Offset(0, small ? 350 : 600),
          );
          await tester.pumpAndSettle();
          expect(find.byType(CaseShareSheet), findsNothing);
          await tester.tap(find.byTooltip('Guardar caso'));
          expect(saves, 1);
          expect(tester.getRect(find.byTooltip('Guardar caso')), saveRect);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (Platform.environment['CAPTURE_CASE_SHARING'] != '1') return;
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final folder = Directory('build/ui-preview/case-sharing')
      ..createSync(recursive: true);
    await File(
      '${folder.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
