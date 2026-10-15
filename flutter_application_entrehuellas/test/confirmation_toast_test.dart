import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/confirmation_toast.dart';

void main() {
  testWidgets(
    'Long scaled toast scrolls in bounded area and dismisses from its surface',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 350));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const message =
          'No pudimos confirmar la operación. Conservamos los datos para reintentar sin duplicar el envío.';
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 350),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: ConfirmationToastHost(
                confirmed: true,
                message: message,
                isError: true,
                child: Text('Contenido conservado'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final toast = find.byKey(const ValueKey('feedback-toast'));
      expect(tester.getRect(toast).height, lessThanOrEqualTo(110));
      final scroll = find.descendant(
        of: toast,
        matching: find.byType(SingleChildScrollView),
      );
      final controller = tester
          .widget<SingleChildScrollView>(scroll)
          .controller!;
      expect(controller.position.maxScrollExtent, greaterThan(0));
      await tester.drag(scroll, const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0));
      expect(find.text('Contenido conservado'), findsOneWidget);
      await tester.tap(toast);
      await tester.pumpAndSettle();
      expect(find.text(message), findsNothing);
    },
  );

  testWidgets(
    'A new screen notice replaces the photo notice without stacking',
    (tester) async {
      var failed = false;
      var showPhoto = true;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return ConfirmationToastHost(
                  confirmed: failed,
                  isError: true,
                  message: 'Publicación rechazada',
                  child: showPhoto
                      ? const ConfirmationToastHost(
                          confirmed: true,
                          isError: true,
                          message: 'Foto no disponible',
                          child: Icon(Icons.broken_image_outlined),
                        )
                      : const SizedBox(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Foto no disponible'), findsOneWidget);
      update(() => failed = true);
      await tester.pumpAndSettle();
      expect(find.text('Foto no disponible'), findsNothing);
      expect(find.text('Publicación rechazada'), findsOneWidget);
      update(() => showPhoto = false);
      await tester.pumpAndSettle();
      expect(find.text('Publicación rechazada'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Publicación rechazada'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
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
