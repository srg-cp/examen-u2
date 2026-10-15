import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/content_refresh.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'Refresh retains geometry, content semantics and actions; reduced=$reduced',
      (tester) async {
        var refreshing = false;
        var taps = 0;
        late StateSetter update;
        final contentKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: StatefulBuilder(
                builder: (context, change) {
                  update = change;
                  return ContentRefresh(
                    refreshing: refreshing,
                    label: 'Actualizando casos',
                    child: SizedBox(
                      key: contentKey,
                      width: 240,
                      height: 100,
                      child: TextButton(
                        onPressed: () => taps++,
                        child: const Text('Abrir ficha'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        final before = tester.getRect(find.byKey(contentKey));
        update(() => refreshing = true);
        await tester.pump();
        expect(tester.getRect(find.byKey(contentKey)), before);
        expect(find.text('Abrir ficha'), findsOneWidget);
        final semantics = tester.ensureSemantics();
        expect(find.bySemanticsLabel('Actualizando casos'), findsOneWidget);
        expect(find.bySemanticsLabel('Abrir ficha'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 1500));
        expect(tester.getRect(find.byKey(contentKey)), before);
        expect(tester.hasRunningAnimations, !reduced);
        await tester.tap(find.text('Abrir ficha'));
        expect(taps, 1);
        update(() => refreshing = false);
        await tester.pumpAndSettle();
        expect(tester.hasRunningAnimations, isFalse);
        semantics.dispose();
      },
    );
  }
}
