import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_entrehuellas/app/navigation/entity_editor_page.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/state/home_view_state.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_header.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_banner_surface.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/liquid_navigation.dart';

Future<void> reveal(WidgetTester tester, Finder target) async {
  await Scrollable.ensureVisible(tester.element(target), alignment: .25);
  await tester.pumpAndSettle();
}

void main() {
  for (final reduced in [false, true]) {
    for (final entry in [
      ('Mis reportes', '/home/my-reports'),
      ('Reportar pérdida', '/home/lost-cases/new'),
      ('Encontré una mascota', '/home/found-cases/new?independent=true'),
      ('Buscar con una foto', '/home/coincidencias'),
    ]) {
      testWidgets(
        'Home ${entry.$1} keeps destination and return; reduced=$reduced',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          OriginPageSource? captured;
          Uri? destination;
          final router = GoRouter(
            initialLocation: '/home',
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomeScreen(
                  profileAvatar: CircleAvatar(child: Text('A')),
                ),
                routes: [
                  for (final path in [
                    'my-reports',
                    'lost-cases/new',
                    'found-cases/new',
                    'coincidencias',
                  ])
                    GoRoute(
                      path: path,
                      pageBuilder: (context, state) {
                        destination = state.uri;
                        captured = state.extra as OriginPageSource?;
                        return entityEditorPage(
                          context: context,
                          key: state.pageKey,
                          source: state.extra,
                          child: const Scaffold(
                            body: Text('Destino existente'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp.router(
                theme: AppTheme.light,
                routerConfig: router,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: reduced),
                  child: child!,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final label = find.text(entry.$1);
          await reveal(tester, label);
          final target = entry.$1 == 'Buscar con una foto'
              ? find.byKey(const ValueKey('home-photo-search'))
              : entry.$1 == 'Mis reportes'
              ? find.ancestor(of: label, matching: find.byType(TextButton))
              : find.ancestor(of: label, matching: find.byType(FilledButton));
          final sourceBounds = tester.getRect(target);
          await tester.tap(label);
          await tester.pump();
          expect(destination.toString(), entry.$2);
          if (entry.$1 != 'Mis reportes') {
            expect(captured!.bounds, sourceBounds);
            expect((captured!.child as Icon).icon, Icons.arrow_forward_rounded);
            expect(
              (captured!.child as Icon).size,
              entry.$1 == 'Buscar con una foto' ? 26 : 24,
            );
            expect(
              captured!.color,
              entry.$1 == 'Buscar con una foto'
                  ? HomeBannerSurface.originColor
                  : const Color(0xFF111111),
            );
            if (!reduced) {
              await tester.pump(const Duration(milliseconds: 160));
              final transition = tester.widget<OriginPageTransition>(
                find.byType(OriginPageTransition),
              );
              expect(transition.animation.value, inExclusiveRange(0, 1));
            }
          }
          await tester.pumpAndSettle();
          expect(find.text('Destino existente'), findsOneWidget);
          router.pop();
          await tester.pump();
          if (!reduced && entry.$1 != 'Mis reportes') {
            await tester.pump(const Duration(milliseconds: 130));
            final transition = tester.widget<OriginPageTransition>(
              find.byType(OriginPageTransition),
            );
            expect(transition.animation.value, inExclusiveRange(0, 1));
          }
          await tester.pumpAndSettle();
          expect(label, findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final config in [
    (const Size(390, 844), 1.0),
    (const Size(320, 600), 2.0),
    (const Size(320, 350), 2.0),
  ]) {
    testWidgets('Home scroll, chrome and actions stay usable $config', (
      tester,
    ) async {
      tester.view.physicalSize = config.$1;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: config.$1,
                textScaler: TextScaler.linear(config.$2),
                disableAnimations: true,
                padding: const EdgeInsets.only(top: 24, bottom: 24),
              ),
              child: const HomeScreen(
                profileAvatar: CircleAvatar(child: Text('A')),
                exploreContent: Text('Explorar real'),
                petsContent: Text('Mis mascotas reales'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final header = tester.getRect(find.byType(HomeHeader));
      final navigation = tester.getRect(find.byType(LiquidNavigation));
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(
        scrollable.position.maxScrollExtent,
        greaterThan(config.$1.height / 2),
      );
      for (final label in [
        'Encontré una mascota',
        'Buscar con una foto',
        'Explorar',
      ]) {
        final text = find.text(label);
        await reveal(tester, text);
        expect(tester.getRect(find.byType(HomeHeader)), header);
        expect(tester.getRect(find.byType(LiquidNavigation)), navigation);
        final target = label == 'Buscar con una foto'
            ? find.byKey(const ValueKey('home-photo-search'))
            : find.ancestor(of: text, matching: find.byType(FilledButton));
        final rect = tester.getRect(target);
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
        // Each actionable label can be brought above the floating navigation.
        expect(tester.getRect(text).center.dy, lessThan(navigation.top));
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.text('Explorar'));
      await tester.pumpAndSettle();
      expect(find.text('Explorar real'), findsOneWidget);
      expect(
        tester.widget<LiquidNavigation>(find.byType(LiquidNavigation)).selected,
        HomeSection.explore,
      );
      await tester.tap(find.byTooltip('Mis mascotas'));
      await tester.pumpAndSettle();
      expect(find.text('Mis mascotas reales'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
