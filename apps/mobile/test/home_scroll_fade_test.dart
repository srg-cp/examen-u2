import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_scroll_fade.dart';

void main() {
  testWidgets(
    'Fade has soft extensions with clear openings and preserves opaque content',
    (tester) async {
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: RepaintBoundary(
                key: boundary,
                child: const ColoredBox(
                  color: Colors.white,
                  child: HomeScrollFade(
                    child: SingleChildScrollView(
                      child: RepaintBoundary(
                        child: SizedBox(
                          height: 1200,
                          child: ColoredBox(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();
      (boundary.currentContext!.findRenderObject() as RenderRepaintBoundary)
          .markNeedsPaint();
      await tester.pump();
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final pixels = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        int red(int x, int y) => pixels.getUint8((y * image.width + x) * 4);
        final samples = [for (var x = 10; x < 230; x += 10) red(x, 28)];
        final ordered = [...samples]..sort();
        expect(
          ordered.first,
          lessThan(35),
          reason: 'Openings must reveal the content between soft extensions',
        );
        expect(ordered.last, greaterThan(110));
        final peaks = [
          for (var i = 1; i < samples.length - 1; i++)
            if (samples[i] > samples[i - 1] && samples[i] > samples[i + 1]) i,
        ];
        expect(peaks.length, greaterThanOrEqualTo(3));
        expect(red(120, 0), greaterThan(245));
        expect(red(120, 100), 0);
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    },
  );
}
