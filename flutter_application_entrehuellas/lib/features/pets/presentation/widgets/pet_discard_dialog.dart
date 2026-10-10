import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/origin_dialog_transition.dart';

Future<bool> confirmPetDiscard(BuildContext context) async =>
    await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          OriginDialogTransition(animation: animation, child: child),
      pageBuilder: (context, animation, secondaryAnimation) => Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: 'Confirmar salida sin guardar',
        explicitChildNodes: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Salir sin guardar?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Los cambios que no guardaste se perderán.',
                style: TextStyle(fontSize: 16, color: Color(0xFF6E6E73)),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked =
                      MediaQuery.textScalerOf(context).scale(14) > 18 ||
                      constraints.maxWidth < 280;
                  final width = stacked
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 8) / 2;
                  const labelStyle = TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  );
                  var height = 48.0;
                  for (final label in [
                    'Seguir editando',
                    'Salir sin guardar',
                  ]) {
                    final painter = TextPainter(
                      text: TextSpan(text: label, style: labelStyle),
                      textDirection: Directionality.of(context),
                      textScaler: MediaQuery.textScalerOf(context),
                    )..layout(maxWidth: width - 24);
                    height = (painter.height + 24).clamp(
                      height,
                      double.infinity,
                    );
                    painter.dispose();
                  }
                  final style = ButtonStyle(
                    minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
                    padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
                    textStyle: const WidgetStatePropertyAll(labelStyle),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  );
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: width,
                        height: height,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: style.copyWith(
                            foregroundColor: const WidgetStatePropertyAll(
                              Color(0xFF111111),
                            ),
                            side: const WidgetStatePropertyAll(
                              BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                          ),
                          child: const Text(
                            'Seguir editando',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        height: height,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: style.copyWith(
                            backgroundColor: const WidgetStatePropertyAll(
                              Color(0xFFF9ECEE),
                            ),
                            foregroundColor: const WidgetStatePropertyAll(
                              Color(0xFFB53F48),
                            ),
                          ),
                          child: const Text(
                            'Salir sin guardar',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ) ??
    false;
