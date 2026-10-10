import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/origin_dialog_transition.dart';

Future<bool> confirmPetDeletion(
  BuildContext context,
  String name, {
  Rect? origin,
  Widget? source,
}) async =>
    await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          OriginDialogTransition(
            animation: animation,
            origin: origin,
            source: source,
            child: child,
          ),
      pageBuilder: (context, animation, secondaryAnimation) => Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: 'Confirmar eliminación de mascota',
        explicitChildNodes: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _DeletionHeader(),
                const SizedBox(height: 16),
                Text(
                  'Se eliminarán la ficha de $name y sus fotos de forma permanente. Esta acción no se puede deshacer.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6E6E73),
                  ),
                ),
                const SizedBox(height: 24),
                const _DeletionActions(key: ValueKey('pet-deletion-actions')),
              ],
            ),
          ),
        ),
      ),
    ) ??
    false;

class _DeletionHeader extends StatelessWidget {
  const _DeletionHeader();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const style = TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111111),
      );
      final painter = TextPainter(
        text: const TextSpan(text: '¿Eliminar', style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final stacked = painter.width + 48 > constraints.maxWidth;
      painter.dispose();
      const title = Text('¿Eliminar mascota?', style: style);
      final close = IconButton(
        tooltip: 'Cerrar confirmación',
        onPressed: () => Navigator.pop(context, false),
        icon: const Icon(Icons.close_rounded, color: Color(0xFF6E6E73)),
      );
      return stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerRight, child: close),
                title,
              ],
            )
          : Row(
              children: [
                const Expanded(child: title),
                close,
              ],
            );
    },
  );
}

class _DeletionActions extends StatelessWidget {
  const _DeletionActions({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const textStyle = TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
      );
      final scaler = MediaQuery.textScalerOf(context);
      final direction = Directionality.of(context);
      final painter = TextPainter(
        text: const TextSpan(text: 'Eliminar mascota', style: textStyle),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      final preferredWidth = painter.width + 16;
      final sideBySide = preferredWidth * 2 + 8 <= constraints.maxWidth;
      final width = preferredWidth.clamp(0.0, constraints.maxWidth);
      painter.layout(maxWidth: width - 16);
      final height = (painter.height + 16).clamp(48.0, double.infinity);
      painter.dispose();
      final style = ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        textStyle: const WidgetStatePropertyAll(textStyle),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      );
      final cancel = SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: style.copyWith(
            foregroundColor: const WidgetStatePropertyAll(Color(0xFF111111)),
            side: const WidgetStatePropertyAll(
              BorderSide(color: Color(0xFFE5E5EA)),
            ),
          ),
          child: const Text('Cancelar'),
        ),
      );
      final delete = SizedBox(
        width: width,
        height: height,
        child: FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: style.copyWith(
            backgroundColor: const WidgetStatePropertyAll(Color(0xFFF9ECEE)),
            foregroundColor: const WidgetStatePropertyAll(Color(0xFFB53F48)),
          ),
          child: const Text('Eliminar mascota'),
        ),
      );
      return Align(
        alignment: Alignment.bottomRight,
        child: sideBySide
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [cancel, const SizedBox(width: 8), delete],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [cancel, const SizedBox(height: 8), delete],
              ),
      );
    },
  );
}
