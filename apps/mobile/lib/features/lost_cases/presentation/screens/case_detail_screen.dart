import '../../domain/entities/lost_case.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/case_public_skeleton.dart';
import '../view_models/case_read_view_model.dart';
import '../widgets/case_screen_shell.dart';
import '../widgets/case_public_content.dart';

class CaseDetailScreen extends ConsumerWidget {
  const CaseDetailScreen({
    required this.id,
    this.recoveryActions,
    this.savedAction,
    this.posterAction,
    this.timelineAction,
    this.followAction,
    this.reportAction,
    super.key,
  });
  final Widget? savedAction;
  final Widget? posterAction;
  final Widget? timelineAction;
  final Widget? followAction;
  final Widget? reportAction;
  final String id;
  final Widget Function(PublicLostCase, VoidCallback)? recoveryActions;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(publicCaseViewModelProvider(id));
    final model = ref.read(publicCaseViewModelProvider(id).notifier);
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
              child: CasePublicContent(
                value: state.requireValue.value!,
                actions: Column(
                  children: [
                    if (followAction != null) followAction!,
                    if (timelineAction != null) timelineAction!,
                    if (state.requireValue.value!.canResolve &&
                        posterAction != null)
                      posterAction!,
                    if (recoveryActions != null)
                      recoveryActions!(state.requireValue.value!, model.retry),
                    if (reportAction != null) reportAction!,
                    if (state.requireValue.refreshFailed)
                      TextButton(
                        onPressed: state.requireValue.refreshing
                            ? null
                            : model.retry,
                        child: const Text('Reintentar'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
