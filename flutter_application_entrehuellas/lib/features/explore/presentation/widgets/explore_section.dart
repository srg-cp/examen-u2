import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/collection_header.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/origin_page_transition.dart';
import '../../../../core/presentation/widgets/two_option_filter.dart';
import '../../domain/entities/explore_page.dart';
import '../view_models/explore_view_model.dart';
import 'explore_case_map.dart';
import 'explore_filters.dart';
import 'explore_case_grid.dart';

class ExploreSection extends ConsumerWidget {
  const ExploreSection({this.locationSearchBuilder, super.key});
  final LocationSearchBuilder? locationSearchBuilder;
  Widget _layout(Widget content) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: CollectionHeader(
          title: 'Explorar',
          keepActionInline: true,
          action: Builder(
            builder: (source) => IconButton(
              tooltip: 'Ver casos guardados',
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              iconSize: 24,
              color: const Color(0xFF111111),
              icon: const Icon(Icons.bookmark_border_rounded),
              onPressed: () {
                final box = source.findRenderObject();
                final navigator = Navigator.of(
                  source,
                ).context.findRenderObject();
                final bounds = box is RenderBox && box.hasSize
                    ? box.localToGlobal(Offset.zero, ancestor: navigator) &
                          box.size
                    : null;
                source.push(
                  '/home/saved-cases',
                  extra: bounds == null
                      ? null
                      : OriginPageSource(
                          bounds: bounds,
                          color: Colors.white,
                          radius: 24,
                          child: const Center(
                            child: Icon(
                              Icons.bookmark_border_rounded,
                              size: 24,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      AuthStageTransition(
        stage: 'content',
        builder: (play) => StaggerReveal(
          count: 1,
          play: play,
          child: StaggerRevealItem(order: 0, child: content),
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exploreViewModelProvider);
    final data = async.isLoading || async.hasError ? null : async.asData?.value;
    final vm = ref.read(exploreViewModelProvider.notifier);
    Future<void> openCase(ExploreCase item, BuildContext source) async {
      final box = source.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      await context.push(
        '/home/${item.fromPet ? 'cases' : 'found-cases'}/${item.id}',
        extra: origin,
      );
      if (context.mounted) {
        ref.read(exploreViewModelProvider.notifier).refresh();
      }
    }

    final Widget results;
    if (data == null ||
        (data.mapSelected &&
            (data.needsLocation || (data.failed && data.items.isEmpty)))) {
      results = const SizedBox.shrink();
    } else if (!data.mapSelected) {
      results = ExploreCaseGrid(
        items: data.items,
        onOpen: data.busy ? null : openCase,
      );
    } else if (data.refreshing && data.items.isEmpty) {
      results = const SizedBox(
        height: 320,
        child: ColoredBox(color: Color(0xFFE5E5EA)),
      );
    } else {
      results = ExploreCaseMap(
        key: ValueKey((data.owner, data.query)),
        items: data.items,
        query: data.query,
        onOpen: data.busy ? null : openCase,
      );
    }

    return _layout(
      PullToRefreshTarget(
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
              Column(
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
                        locationSearchBuilder: locationSearchBuilder,
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
                  if (data != null) ...[
                    TwoOptionFilter(
                      secondSelected: data.mapSelected,
                      onChanged: data.busy ? null : vm.selectMap,
                      firstLabel: 'Lista',
                      secondLabel: 'Mapa',
                      indicatorKey: const ValueKey('explore-view-indicator'),
                    ),
                    const SizedBox(height: 16),
                  ],
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
                          else if (data.refreshing &&
                              data.items.isEmpty &&
                              !data.mapSelected)
                            const ExploreCaseGrid.skeleton()
                          else if (data.items.isEmpty &&
                              !data.failed &&
                              !data.refreshing)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text('No hay casos con estos filtros.'),
                            ),
                          AuthStageTransition(
                            stage: data.mapSelected,
                            builder: (play) => StaggerReveal(
                              count: 1,
                              play: play,
                              child: StaggerRevealItem(
                                order: 0,
                                child: results,
                              ),
                            ),
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
            ],
          ),
        ),
      ),
    );
  }
}
