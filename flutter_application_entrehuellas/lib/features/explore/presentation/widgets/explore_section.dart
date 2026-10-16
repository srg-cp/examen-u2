import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/collection_header.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/explore_view_model.dart';
import 'explore_filters.dart';
import 'explore_case_grid.dart';

class ExploreSection extends ConsumerWidget {
  const ExploreSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exploreViewModelProvider);
    final data = async.isLoading || async.hasError ? null : async.asData?.value;
    final vm = ref.read(exploreViewModelProvider.notifier);
    return PullToRefreshTarget(
      onRefresh: vm.refresh,
      enabled: !async.isLoading && data?.busy != true,
      child: ConfirmationToastHost(
        confirmed: async.hasError || data?.notice != null,
        isError: true,
        message: async.hasError
            ? 'No pudimos consultar los casos.'
            : data?.notice ?? '',
        noticeId: (async.error, data?.noticeId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StaggerRevealItem(
              order: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: const CollectionHeader(title: 'Explorar'),
              ),
            ),
            const SizedBox(height: 12),
            StaggerRevealItem(
              order: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (data != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ExploreFilters(
                        key: ValueKey(data.owner),
                        enabled: !data.busy,
                        applying: data.applying,
                        query: data.query,
                        onUseCurrentLocation: vm.useCurrentLocation,
                        onApply:
                            (kind, species, status, days, lat, lon, radius) =>
                                vm.apply(
                                  kind: kind,
                                  species: species,
                                  status: status,
                                  days: days,
                                  latitude: lat,
                                  longitude: lon,
                                  radiusMeters: radius,
                                ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (async.isLoading)
                    const LoadingShimmer(
                      isLoading: true,
                      loadingLabel: 'Consultando casos',
                      child: ExploreCaseGrid.skeleton(),
                    )
                  else if (async.hasError)
                    TextButton(
                      onPressed: vm.refresh,
                      child: const Text('Reintentar'),
                    )
                  else if (data != null)
                    ContentRefresh(
                      refreshing: data.refreshing,
                      label: 'Actualizando casos',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (data.needsLocation && !data.refreshing)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Elige una ubicación para ver casos cercanos.',
                              ),
                            )
                          else if (data.refreshing && data.items.isEmpty)
                            const ExploreCaseGrid.skeleton()
                          else if (data.items.isEmpty && !data.failed)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text('No hay casos con estos filtros.'),
                            ),
                          ExploreCaseGrid(
                            items: data.items,
                            onOpen: data.busy
                                ? null
                                : (item, source) async {
                                    final box =
                                        source.findRenderObject() as RenderBox?;
                                    final origin = box == null
                                        ? null
                                        : box.localToGlobal(Offset.zero) &
                                              box.size;
                                    await context.push(
                                      '/home/${item.fromPet ? 'cases' : 'found-cases'}/${item.id}',
                                      extra: origin,
                                    );
                                    if (context.mounted) {
                                      ref
                                          .read(
                                            exploreViewModelProvider.notifier,
                                          )
                                          .refresh();
                                    }
                                  },
                          ),
                          if (data.failed)
                            TextButton(
                              onPressed: data.busy
                                  ? null
                                  : (data.cursor == null
                                        ? vm.refresh
                                        : vm.more),
                              child: const Text('Reintentar'),
                            )
                          else if (data.cursor != null)
                            LoadingShimmer(
                              isLoading: data.appending,
                              loadingLabel: 'Consultando más casos',
                              child: TextButton(
                                onPressed: data.busy ? null : vm.more,
                                child: const Text('Ver más casos'),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
