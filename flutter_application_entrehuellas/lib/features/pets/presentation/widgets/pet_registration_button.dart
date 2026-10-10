import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/theme/app_theme.dart';

class PetRegistrationButton extends StatelessWidget {
  const PetRegistrationButton({this.compact = false, super.key});
  final bool compact;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (buttonContext) => Tooltip(
      message: 'Registrar mascota',
      excludeFromSemantics: true,
      child: FilledButton(
        key: compact ? const ValueKey('pet-add-compact') : null,
        style: compact
            ? FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                fixedSize: const Size.square(56),
                minimumSize: const Size.square(56),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              )
            : primaryActionButtonStyle(context).copyWith(
                minimumSize: const WidgetStatePropertyAll(Size(0, 56)),
              ),
        onPressed: () {
          final box = buttonContext.findRenderObject();
          final navigator = Navigator.of(
            buttonContext,
          ).context.findRenderObject();
          final origin = box is RenderBox && box.hasSize
              ? box.localToGlobal(Offset.zero, ancestor: navigator) & box.size
              : null;
          buttonContext.push('/home/pets/new', extra: origin);
        },
        child: compact
            ? const Icon(
                Icons.add_rounded,
                size: 26,
                semanticLabel: 'Registrar mascota',
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 22),
                  SizedBox(width: 8),
                  Flexible(child: Text('Registrar mascota')),
                ],
              ),
      ),
    ),
  );
}
