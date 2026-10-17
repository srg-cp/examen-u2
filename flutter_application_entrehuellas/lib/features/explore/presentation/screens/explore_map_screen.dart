import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../view_models/explore_view_model.dart';
import '../widgets/explore_case_map.dart';
import '../../domain/entities/explore_page.dart';
import '../state/explore_filter_selection.dart';
import '../widgets/explore_filter_editor.dart';

class ExploreMapScreen extends ConsumerWidget {
  const ExploreMapScreen({
    this.createTileProvider,
    this.locationSearchBuilder,
    super.key,
  });
  final LocationSearchBuilder? locationSearchBuilder;
  final TileProvider Function()? createTileProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(exploreViewModelProvider);
    final data = value.isLoading || value.hasError ? null : value.asData?.value;
    final vm = ref.read(exploreViewModelProvider.notifier);
    Future<void> openCase(ExploreCase item, BuildContext source) async {
      final box = source.findRenderObject() as RenderBox?;
      final navigator = Navigator.of(source).context.findRenderObject();
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero, ancestor: navigator) & box.size;
      await context.push(
        '/home/${item.fromPet ? 'cases' : 'found-cases'}/${item.id}',
        extra: origin,
      );
      if (context.mounted) {
        await ref.read(exploreViewModelProvider.notifier).refresh();
      }
    }

    return Scaffold(
      body: ConfirmationToastHost(
        confirmed: value.hasError || data?.notice != null,
        isError: true,
        message: value.hasError
            ? 'No pudimos consultar los casos.'
            : data?.notice ?? '',
        noticeId: (value.error, data?.noticeId),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (data == null)
              value.hasError
                  ? Center(
                      child: TextButton(
                        onPressed: vm.refresh,
                        child: const Text('Reintentar'),
                      ),
                    )
                  : const LoadingShimmer(
                      isLoading: true,
                      loadingLabel: 'Consultando casos',
                      child: ColoredBox(color: Color(0xFFE5E5EA)),
                    )
            else
              ContentRefresh(
                refreshing: data.refreshing,
                label: 'Actualizando casos',
                child: ExploreCaseMap(
                  key: ValueKey(data.owner),
                  items: data.items,
                  query: data.query,
                  onOpen: data.busy ? null : openCase,
                  createTileProvider: createTileProvider,
                  filterBuilder: (context, scroll, handle, readCenter) =>
                      ExploreFilterEditor(
                        key: ValueKey((data.owner, data.query)),
                        initial: ExploreFilterSelection.fromQuery(
                          data.query,
                          label: data.locationLabel,
                          centerName: data.centerName,
                        ),
                        allFilters: true,
                        showMap: false,
                        busy: data.busy,
                        applying: data.applying,
                        scrollController: scroll,
                        headerSliver: handle,
                        locationSearchBuilder: locationSearchBuilder,
                        onUseCurrentLocation: vm.locateForFilter,
                        onUseMapCenter: readCenter,
                        onConfirm: vm.applySelection,
                        trailing: [
                          const SizedBox(height: 16),
                          if (!data.failed && !data.busy)
                            Text(
                              data.needsLocation
                                  ? 'Elige una ubicación para ver casos cercanos.'
                                  : '${data.items.length} casos consultados · Ubicaciones aproximadas',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6E6E73),
                              ),
                            ),
                          if (data.failed || data.cursor != null)
                            LoadingShimmer(
                              isLoading: data.appending,
                              loadingLabel: 'Consultando más casos',
                              child: TextButton(
                                onPressed: data.busy
                                    ? null
                                    : data.failed && data.cursor == null
                                    ? vm.refresh
                                    : vm.more,
                                child: Text(
                                  data.failed ? 'Reintentar' : 'Ver más casos',
                                ),
                              ),
                            ),
                        ],
                      ),
                ),
              ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 16,
              child: GlassNavigationButton(
                tooltip: 'Volver a Explorar',
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
