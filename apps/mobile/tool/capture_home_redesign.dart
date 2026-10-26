// flutter test --dart-define=AMBIENT_BACKGROUND_MOTION=false tool/capture_home_redesign.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_explore_banner.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_found_banner.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_photo_search_card.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_report_banner.dart';

void main() {
  testWidgets('Capture approved Home with real assets, fonts and scrolling', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (final family in ['Poppins', 'sans-serif']) {
        final loader = FontLoader(family);
        for (final name
            in family == 'Poppins'
                ? ['Poppins-Regular', 'Poppins-SemiBold']
                : ['Roboto-Regular', 'Roboto-Bold']) {
          loader.addFont(
            File(
              'assets/fonts/$name.ttf',
            ).readAsBytes().then(ByteData.sublistView),
          );
        }
        await loader.load();
      }
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final flutter = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((entry) => entry['name'] == 'flutter');
      final root = configFile.uri.resolve('${flutter['rootUri']}/');
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          File.fromUri(
            root.resolve(
              '../../bin/cache/artifacts/material_fonts/materialicons-regular.otf',
            ),
          ).readAsBytes().then(ByteData.sublistView),
        );
      await icons.load();
    });
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final directory = Directory('build/ui-preview/home-redesign')
      ..createSync(recursive: true);
    for (final config in [
      ('normal', const Size(390, 844), 1.0),
      ('small', const Size(320, 600), 2.0),
      ('short', const Size(320, 350), 2.0),
    ]) {
      tester.view.physicalSize = config.$2;
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(config.$1),
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: config.$2,
                textScaler: TextScaler.linear(config.$3),
                disableAnimations: config.$1 != 'normal',
                padding: const EdgeInsets.only(top: 24, bottom: 24),
              ),
              child: RepaintBoundary(
                key: boundaryKey,
                child: HomeScreen(
                  profileAvatar: const CircleAvatar(
                    backgroundColor: Color(0xFFF5F5F7),
                    foregroundColor: Color(0xFF111111),
                    child: Text('A'),
                  ),
                  onAlerts: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final asset in [
          'assets/branding/app_icon.png',
          HomeReportBanner.artwork,
          HomeFoundBanner.artwork,
          HomePhotoSearchCard.artwork,
          HomeExploreBanner.artwork,
        ]) {
          await precacheImage(AssetImage(asset), boundaryKey.currentContext!);
        }
      });

      Future<void> capture(String name) async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        boundary.markNeedsPaint();
        await tester.pump();
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final pixels = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(pixels!.buffer.asUint8List());
          image.dispose();
        });
        expect(tester.takeException(), isNull);
      }

      if (config.$1 == 'normal') {
        await tester.pump(const Duration(milliseconds: 200));
        await capture('normal-entry-200ms');
      }
      await tester.pumpAndSettle();
      await capture('${config.$1}-top');
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('home-found-banner'))),
      );
      await tester.pumpAndSettle();
      await capture('${config.$1}-scroll');
      await Scrollable.ensureVisible(
        tester.element(find.text('Explorar')),
        alignment: .35,
      );
      await tester.pumpAndSettle();
      await capture('${config.$1}-bottom');
    }
  });
}
