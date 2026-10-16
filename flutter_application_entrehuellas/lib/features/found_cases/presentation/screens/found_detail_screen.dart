import 'package:go_router/go_router.dart';
import '../widgets/recovery_case_actions.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/case_public_skeleton.dart';
import '../view_models/found_read_view_model.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../widgets/found_public_content.dart';

class FoundDetailScreen extends ConsumerWidget {
  const FoundDetailScreen({required this.id, this.savedAction, super.key});
  final Widget? savedAction;
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(publicFoundViewModelProvider(id));
    final model = ref.read(publicFoundViewModelProvider(id).notifier);
    return CaseScreenShell(
      title: 'Ficha pública',
      trailingAction:
          !state.isLoading &&
              !state.hasError &&
              state.asData?.value.value != null
          ? savedAction
          : null,
      immersive: state.isLoading || state.asData?.value.value != null,
      loading: state.isLoading,
      notice: state.hasError
          ? 'No pudimos consultar el caso.'
          : state.asData?.value.refreshFailed == true
          ? 'No pudimos actualizar. Se conserva la última consulta.'
          : !state.isLoading && state.asData?.value.value == null
          ? 'Este caso no está disponible públicamente.'
          : null,
      noticeId: state.error ?? state.asData?.value,
      child: state.isLoading
          ? const CasePublicSkeleton()
          : state.hasError
          ? Column(
              children: [
                TextButton(
                  onPressed: model.retry,
                  child: const Text('Reintentar'),
                ),
              ],
            )
          : state.requireValue.value == null
          ? const Text('Este caso no está disponible públicamente.')
          : ContentRefresh(
              refreshing: state.requireValue.refreshing,
              label: 'Actualizando caso',
              child: FoundPublicContent(
                value: state.requireValue.value!,
                actions: state.requireValue.value!.reportKind == 'possible_loss'
                    ? RecoveryCaseActions(
                        id: id,
                        community: true,
                        canResolve: state.requireValue.value!.canResolve,
                        open: state.requireValue.value!.status == 'active',
                        onChanged: model.retry,
                      )
                    : state.requireValue.value!.targetId != null &&
                          state.requireValue.value!.status == 'active'
                    ? TextButton(
                        onPressed: () => context.push(
                          state.requireValue.value!.communityTarget
                              ? '/home/found-cases/${state.requireValue.value!.targetId}'
                              : '/home/cases/${state.requireValue.value!.targetId}',
                        ),
                        child: const Text('Ver búsqueda'),
                      )
                    : state.requireValue.refreshFailed
                    ? TextButton(
                        onPressed: state.requireValue.refreshing
                            ? null
                            : model.retry,
                        child: const Text('Reintentar'),
                      )
                    : null,
              ),
            ),
    );
  }
}
