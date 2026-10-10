import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/confirmation_toast.dart';

void main() {
  testWidgets(
    'Error notices repeat by event, conflict action dismisses and disposal clears overlay',
    (tester) async {
      var active = false;
      var noticeId = 0;
      var actions = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return ConfirmationToastHost(
                  confirmed: active,
                  noticeId: noticeId,
                  isError: true,
                  message: 'La ficha cambió.',
                  actionLabel: 'Actualizar lista',
                  onAction: () => actions++,
                  child: const Text('Lista'),
                );
              },
            ),
          ),
        ),
      );
      update(() {
        active = true;
        noticeId++;
      });
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      await tester.tap(find.text('La ficha cambió.'));
      await tester.pumpAndSettle();
      expect(find.text('La ficha cambió.'), findsNothing);
      update(() => noticeId++);
      await tester.pumpAndSettle();
      expect(find.text('La ficha cambió.'), findsOneWidget);
      await tester.tap(find.text('Actualizar lista'));
      await tester.pumpAndSettle();
      expect(actions, 1);
      expect(find.text('La ficha cambió.'), findsNothing);
      update(() => noticeId++);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 8));
      expect(find.text('La ficha cambió.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  for (final reduced in [false, true]) {
    testWidgets(
      'Confirmation only appears on a new success, dismisses and disposes; reduced=$reduced',
      (tester) async {
        var confirmed = false;
        late StateSetter change;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                disableAnimations: reduced,
                size: const Size(320, 350),
                textScaler: const TextScaler.linear(2),
              ),
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, update) {
                    change = update;
                    return ConfirmationToastHost(
                      confirmed: confirmed,
                      message: 'Cambios guardados',
                      child: const Text('Contenido'),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        expect(find.text('Cambios guardados'), findsNothing);
        change(() => confirmed = true);
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsOneWidget);
        expect(find.text('Contenido'), findsOneWidget);
        change(() {});
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsOneWidget);
        await tester.tap(find.text('Cambios guardados'));
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsNothing);
        change(() {});
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsNothing);
        change(() => confirmed = false);
        await tester.pump();
        change(() => confirmed = true);
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 8));
        expect(find.text('Cambios guardados'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
