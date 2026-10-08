import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';

void main() {
  testWidgets(
    'Surface grows from the trigger and reverses without stretching page layout',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 480),
      );
      addTearDown(controller.dispose);
      const origin = Rect.fromLTWH(250, 700, 120, 48);
      await tester.pumpWidget(
        MaterialApp(
          home: OriginPageTransition(
            animation: controller,
            origin: origin,
            child: const SizedBox.expand(key: ValueKey('page-layout')),
          ),
        ),
      );
      final surface = find.byKey(const ValueKey('origin-surface'));
      expect(tester.getRect(surface), origin);
      expect(
        tester.getSize(find.byKey(const ValueKey('page-layout'))),
        const Size(400, 800),
      );
      controller.value = .5;
      await tester.pump();
      final middle = tester.getRect(surface);
      expect(middle.width, greaterThan(origin.width));
      expect(middle.width, lessThan(400));
      controller.value = 1;
      await tester.pump();
      expect(tester.getRect(surface), const Rect.fromLTWH(0, 0, 400, 800));
      controller.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));
      expect(tester.getRect(surface).width, closeTo(middle.width, .1));
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), origin);
    },
  );
  testWidgets('Reduced motion displays the full page directly', (tester) async {
    final controller = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 480),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OriginPageTransition(
            animation: controller,
            origin: const Rect.fromLTWH(100, 300, 100, 48),
            child: const Text('Full page'),
          ),
        ),
      ),
    );
    expect(find.text('Full page'), findsOneWidget);
    expect(find.byKey(const ValueKey('origin-surface')), findsNothing);
  });
}
