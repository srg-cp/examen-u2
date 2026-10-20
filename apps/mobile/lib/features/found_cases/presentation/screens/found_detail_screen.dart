import 'package:go_router/go_router.dart';
import '../widgets/recovery_case_actions.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/case_public_cards_skeleton.dart';
import '../view_models/found_read_view_model.dart';
import '../../../../core/presentation/widgets/case_public_screen_shell.dart';
import '../widgets/found_public_content.dart';

class FoundDetailScreen extends ConsumerWidget {
  const FoundDetailScreen({
    required this.id,
    this.savedAction,
    this.contact,
    this.posterAction,
    this.timelineAction,
    this.followAction,
    this.reportAction,
    super.key,
  });
  final Widget? savedAction;
  final Widget? contact;
  final Widget? posterAction;
  final Widget? timelineAction;
  final Widget? followAction;
  final Widget? reportAction;
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(publicFoundViewModelProvider(id));
    final model = ref.read(publicFoundViewModelProvider(id).notifier);
    return CasePublicScreenShell(
      trailingAction:
          !state.isLoading &&
              !state.hasError &&
              state.asData?.value.value != null
          ? savedAction
          : null,
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
          ? const CasePublicCardsSkeleton()
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
          ? const SizedBox.shrink()
          : ContentRefresh(
              refreshing: state.requireValue.refreshing,
              label: 'Actualizando caso',
              child: FoundPublicContent(
                value: state.requireValue.value!,
                contact: contact,
                actions: Column(
                  children: [
                    if (timelineAction != null) timelineAction!,
                    if (state.requireValue.value!.reportKind ==
                            'possible_loss' &&
                        state.requireValue.value!.status == 'active') ...[
                      CollectionAddButton(
                        label: 'Reportar avistamiento',
                        icon: Icons.visibility_outlined,
                        accented: true,
                        route: '/home/sightings/found/$id',
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (followAction != null &&
                        [
                          'possible_loss',
                          'legacy_found',
                        ].contains(state.requireValue.value!.reportKind))
                      followAction!,
                    if (reportAction != null) reportAction!,
                    if ((state.requireValue.value!.canGeneratePoster ||
                            state.requireValue.value!.canResolve) &&
                        posterAction != null)
                      posterAction!,
                    state.requireValue.value!.reportKind == 'possible_loss'
                        ? RecoveryCaseActions(
                            showSightingAction: false,
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
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
    );
  }
}
