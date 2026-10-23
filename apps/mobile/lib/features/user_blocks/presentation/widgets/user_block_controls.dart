import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/confirm_action_dialog.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../domain/entities/user_block.dart';
import '../view_models/user_block_view_model.dart';

const userBlockScope =
    'Impide nuevos avisos y avistamientos entre ambas cuentas con sesión y oculta el contacto y su foto entre ellas. Las fichas, denuncias, historial y avistamientos anónimos por QR siguen disponibles.';

String blockFailureLabel(Object? error) => switch (error is BlockFailure
    ? error.issue
    : error) {
  BlockIssue.forbidden =>
    'No pudimos autorizar la operación. Consulta de nuevo o vuelve a iniciar sesión.',
  BlockIssue.conflict =>
    'El bloqueo cambió. Consulta de nuevo antes de continuar.',
  BlockIssue.invalid =>
    'No pudimos identificar esta cuenta desde el contenido.',
  _ => 'No pudimos confirmar el cambio. Reintenta la misma operación.',
};

class UserBlockPanel extends ConsumerWidget {
  const UserBlockPanel({required this.target, this.onSettled, super.key});
  final BlockTarget target;
  final VoidCallback? onSettled;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userBlockViewModelProvider(target));
    final model = ref.read(userBlockViewModelProvider(target).notifier);
    final value = async.isLoading || async.hasError
        ? null
        : async.asData?.value;
    if (async.isLoading) return const SkeletonFormFields(fieldCount: 1);
    if (!async.hasError && value?.target == null) {
      return const SizedBox.shrink();
    }
    return ConfirmationToastHost(
      confirmed:
          async.hasError || value?.issue != null || value?.confirmed == true,
      noticeId: (async.error, value?.actor, value?.notice),
      isError: value?.confirmed != true,
      message: value?.confirmed == true
          ? (value!.target!.enabled
                ? 'Cuenta bloqueada'
                : 'Cuenta desbloqueada')
          : blockFailureLabel(async.error ?? value?.issue),
      child: value == null
          ? TextButton(
              onPressed: model.retry,
              child: const Text('Reintentar bloqueo'),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserBlockAction(
                  entry: value.target!,
                  busy: value.busy,
                  locked:
                      value.pending != null ||
                      value.issue == BlockIssue.conflict,
                  onChange: () async {
                    await model.change(value.target!, !value.target!.enabled);
                    onSettled?.call();
                  },
                ),
                if (value.pending != null)
                  TextButton(
                    onPressed: value.busy
                        ? null
                        : () async {
                            await model.change(
                              value.pending!.entry,
                              value.pending!.enabled,
                            );
                            onSettled?.call();
                          },
                    child: const Text('Reintentar cambio'),
                  ),
                if (value.issue == BlockIssue.conflict)
                  TextButton(
                    onPressed: model.retry,
                    child: const Text('Consultar bloqueo'),
                  ),
              ],
            ),
    );
  }
}

class UserBlockAction extends StatefulWidget {
  const UserBlockAction({
    required this.entry,
    required this.busy,
    required this.locked,
    required this.onChange,
    super.key,
  });
  final UserBlock entry;
  final bool busy, locked;
  final Future<void> Function() onChange;
  @override
  State<UserBlockAction> createState() => _UserBlockActionState();
}

class _UserBlockActionState extends State<UserBlockAction> {
  bool _confirming = false;
  @override
  Widget build(BuildContext context) => LoadingShimmer(
    isLoading: widget.busy,
    loadingLabel: 'Guardando bloqueo',
    child: TextButton.icon(
      onPressed: widget.busy || widget.locked || _confirming
          ? null
          : () async {
              final entry = widget.entry;
              setState(() => _confirming = true);
              final confirmed = await confirmActionDialog(
                context,
                title: entry.enabled
                    ? '¿Desbloquear cuenta?'
                    : '¿Bloquear cuenta?',
                description: entry.enabled
                    ? 'Se retirará tu bloqueo de ${entry.label}. La otra cuenta puede conservar un bloqueo propio.'
                    : 'Bloquearás la cuenta de ${entry.label}. $userBlockScope',
                action: entry.enabled ? 'Desbloquear' : 'Bloquear',
                destructive: !entry.enabled,
              );
              if (!mounted) return;
              setState(() => _confirming = false);
              // Do not apply a confirmation captured under another identity/state.
              if (confirmed &&
                  !widget.busy &&
                  !widget.locked &&
                  identical(entry, widget.entry)) {
                await widget.onChange();
              }
            },
      icon: Icon(
        widget.entry.enabled ? Icons.lock_open_rounded : Icons.block_rounded,
      ),
      label: Text(
        widget.entry.enabled
            ? 'Desbloquear cuenta'
            : 'Bloquear cuenta del reportante',
      ),
    ),
  );
}
