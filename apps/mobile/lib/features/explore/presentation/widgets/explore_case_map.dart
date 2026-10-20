import 'dart:math' as math;
import 'explore_map_pin.dart';
import 'explore_map_case_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';

/// Full viewport map with the selected public case in its bottom sheet.
class ExploreCaseMap extends StatefulWidget {
  const ExploreCaseMap({
    required this.items,
    required this.query,
    required this.onOpen,
    this.trailing = const [],
    this.emptyMessage,
    this.createTileProvider,
    this.previewBuilder,
    super.key,
  });
  final List<ExploreCase> items;
  final ExploreQuery query;
  final void Function(ExploreCase, BuildContext)? onOpen;
  final List<Widget> trailing;
  final String? emptyMessage;
  final TileProvider Function()? createTileProvider;
  final Widget Function(ExploreCase)? previewBuilder;
  @override
  State<ExploreCaseMap> createState() => _ExploreCaseMapState();
}

class _ExploreCaseMapState extends State<ExploreCaseMap>
    with SingleTickerProviderStateMixin {
  late final _pullOffset = AnimationController.unbounded(vsync: this);

  bool _handleScroll(ScrollNotification notification) {
    if (MediaQuery.disableAnimationsOf(context)) return false;
    if (notification is OverscrollNotification &&
        notification.dragDetails != null &&
        notification.overscroll < 0 &&
        _sheet.isAttached &&
        _sheet.size <= .4201) {
      _pullOffset.stop();
      _pullOffset.value = (_pullOffset.value - notification.overscroll * .2)
          .clamp(0.0, 18.0);
    } else if (notification is ScrollEndNotification && _pullOffset.value > 0) {
      _pullOffset.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
    return false;
  }

  final _sheet = DraggableScrollableController();
  final _map = MapController();
  (double, double)? _selected;
  String? _selectedCaseKey;
  ScrollController? _summaryScroll;

  void _resetSummaryScroll() {
    final scroll = _summaryScroll;
    if (scroll != null && scroll.hasClients) scroll.jumpTo(0);
  }

  void _showCase(ExploreCase item) {
    setState(() => _selectedCaseKey = item.key);
    _resetSummaryScroll();
  }

  void _moveSheet(double size) {
    if (!_sheet.isAttached) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _sheet.jumpTo(size);
    } else {
      _sheet.animateTo(
        size,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void didUpdateWidget(covariant ExploreCaseMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.query, widget.query)) {
      _selected = null;
      _selectedCaseKey = null;
      final query = widget.query;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && identical(widget.query, query)) _moveSheet(.42);
      });
    }
  }

  @override
  void dispose() {
    _pullOffset.dispose();
    _sheet.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = <(double, double), List<ExploreCase>>{};
    for (final item in widget.items) {
      groups.putIfAbsent((item.latitude, item.longitude), () => []).add(item);
    }
    final selected = groups[_selected] ?? const <ExploreCase>[];
    final foundIndex = selected.indexWhere(
      (item) => item.key == _selectedCaseKey,
    );
    final index = foundIndex < 0 ? 0 : foundIndex;
    final item = selected.isEmpty ? null : selected[index];
    final media = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        void select((double, double) point, List<ExploreCase> values) {
          setState(() {
            _selected = point;
            _selectedCaseKey = values.first.key;
          });
          _resetSummaryScroll();
          _moveSheet(.42);
          _map.fitCamera(
            CameraFit.coordinates(
              coordinates: [LatLng(point.$1, point.$2)],
              padding: EdgeInsets.fromLTRB(
                24,
                media.padding.top + 24,
                24,
                math.min(
                  constraints.maxHeight - media.padding.top - 24,
                  constraints.maxHeight * .42 + 32,
                ),
              ),
              maxZoom: _map.camera.zoom,
            ),
          );
        }

        return Stack(
          children: [
            if (widget.query.latitude != null && widget.query.longitude != null)
              Positioned.fill(
                child: ZoneMapPicker(
                  controller: _map,
                  latitude: widget.query.latitude,
                  longitude: widget.query.longitude,
                  radiusMeters: widget.query.radiusMeters ?? 15000,
                  onSelect: null,
                  onMapTap: () => setState(() => _selected = null),
                  readOnly: true,
                  readOnlyNavigation: true,
                  fitRadius: true,
                  showCenterMarker: false,
                  createTileProvider: widget.createTileProvider,
                  height: constraints.maxHeight,
                  borderRadius: 0,
                  cameraPadding: EdgeInsets.fromLTRB(
                    24,
                    media.padding.top + 76,
                    24,
                    constraints.maxHeight * .42 + 16,
                  ),
                  markers: [
                    for (final entry in groups.entries)
                      Marker(
                        key: ValueKey(entry.key),
                        point: LatLng(entry.key.$1, entry.key.$2),
                        width: 48,
                        height: 48,
                        child: Semantics(
                          button: true,
                          selected: entry.key == _selected,
                          label: entry.value.length == 1
                              ? '${entry.value.single.name.isEmpty ? 'Sin nombre' : entry.value.single.name}. Seleccionar caso en ubicación aproximada'
                              : 'Ver ${entry.value.length} casos en esta ubicación aproximada',
                          child: Tooltip(
                            message: entry.value.length == 1
                                ? 'Seleccionar caso'
                                : 'Ver ${entry.value.length} casos',
                            child: ExploreMapPin(
                              count: entry.value.length,
                              selected: entry.key == _selected,
                              onTap: () => select(entry.key, entry.value),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFF5F5F7)),
              ),
            DraggableScrollableSheet(
              controller: _sheet,
              initialChildSize: .42,
              minChildSize: .42,
              maxChildSize: .9,
              snap: !media.disableAnimations,
              snapSizes: const [.42, .9],
              shouldCloseOnMinExtent: false,
              builder: (context, scroll) {
                _summaryScroll = scroll;
                return AnimatedBuilder(
                  animation: _pullOffset,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _pullOffset.value),
                    child: child,
                  ),
                  child: Material(
                    key: const ValueKey('map-case-surface'),
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _handleScroll,
                      child: LayoutBuilder(
                        builder: (context, sheetConstraints) {
                          final sticky =
                              item != null &&
                              sheetConstraints.maxHeight >
                                  media.textScaler.scale(18) * 1.5 +
                                      36 +
                                      media.padding.bottom +
                                      12 +
                                      96;
                          final action = item == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    media.padding.bottom + 12,
                                  ),
                                  child: Builder(
                                    builder: (source) => FilledButton(
                                      style: primaryActionButtonStyle(context),
                                      onPressed: widget.onOpen == null
                                          ? null
                                          : () => widget.onOpen!(item, source),
                                      child: const Text('Ver ficha'),
                                    ),
                                  ),
                                );
                          return Column(
                            children: [
                              Expanded(
                                child: CustomScrollView(
                                  controller: scroll,
                                  slivers: [
                                    SliverPersistentHeader(
                                      pinned: true,
                                      delegate: _MapSheetHandle(
                                        onExpand: () => _moveSheet(.9),
                                        onCollapse: () => _moveSheet(.42),
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (item == null)
                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Text(
                                                widget.items.isEmpty
                                                    ? widget.emptyMessage ??
                                                          'No hay casos para mostrar en el mapa. Ajusta la búsqueda desde Explorar.'
                                                    : 'Selecciona un pin para ver el resumen del caso.',
                                              ),
                                            )
                                          else ...[
                                            if (selected.length > 1)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    tooltip: 'Caso anterior',
                                                    onPressed: index == 0
                                                        ? null
                                                        : () => _showCase(
                                                            selected[index - 1],
                                                          ),
                                                    icon: const Icon(
                                                      Icons
                                                          .chevron_left_rounded,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      '${index + 1} de ${selected.length}',
                                                    ),
                                                  ),
                                                  IconButton(
                                                    tooltip: 'Caso siguiente',
                                                    onPressed:
                                                        index ==
                                                            selected.length - 1
                                                        ? null
                                                        : () => _showCase(
                                                            selected[index + 1],
                                                          ),
                                                    icon: const Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            widget.previewBuilder?.call(item) ??
                                                ExploreMapPreviewContent(
                                                  item: item,
                                                  scrollable: false,
                                                ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              child: Text(
                                                item.status ==
                                                        ExploreStatus.resolved
                                                    ? 'Resuelto'
                                                    : 'Abierto',
                                              ),
                                            ),
                                            if (!sticky) action,
                                          ],
                                          ...widget.trailing,
                                          SizedBox(
                                            height: media.padding.bottom + 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (sticky) action,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _MapSheetHandle extends SliverPersistentHeaderDelegate {
  _MapSheetHandle({required this.onExpand, required this.onCollapse});
  final VoidCallback onExpand, onCollapse;
  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Material(
    color: Colors.white,
    child: Semantics(
      label: 'Desliza para ampliar o reducir el resumen',
      onIncrease: onExpand,
      onDecrease: onCollapse,
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5EA),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ),
  );
  @override
  bool shouldRebuild(covariant _MapSheetHandle oldDelegate) => true;
}
