import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';
import '../../../places/domain/entities/search_place.dart';

typedef MapFilterBuilder =
    Widget Function(
      BuildContext,
      ScrollController,
      Widget,
      SearchPlace Function()?,
    );

/// Full viewport map: filters in its sheet, selected case beside its public pin.
class ExploreCaseMap extends StatefulWidget {
  const ExploreCaseMap({
    required this.items,
    required this.query,
    required this.onOpen,
    required this.filterBuilder,
    this.createTileProvider,
    super.key,
  });
  final List<ExploreCase> items;
  final ExploreQuery query;
  final void Function(ExploreCase, BuildContext)? onOpen;
  final MapFilterBuilder filterBuilder;
  final TileProvider Function()? createTileProvider;
  @override
  State<ExploreCaseMap> createState() => _ExploreCaseMapState();
}

class _ExploreCaseMapState extends State<ExploreCaseMap> {
  final _sheet = DraggableScrollableController();
  final _map = MapController();
  (double, double)? _selected;
  String? _selectedCaseKey;
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
    final bubbleHeight =
        math.max(
          72.0,
          media.textScaler.scale(14) * 1.2 +
              media.textScaler.scale(12) * 1.2 +
              20,
        ) +
        (selected.length > 1 ? 48 : 0);
    return LayoutBuilder(
      builder: (context, constraints) {
        void select((double, double) point, List<ExploreCase> values) {
          setState(() {
            _selected = point;
            _selectedCaseKey = values.first.key;
          });
          _moveSheet(.14);
          final height =
              math.max(
                72.0,
                media.textScaler.scale(14) * 1.2 +
                    media.textScaler.scale(12) * 1.2 +
                    20,
              ) +
              (values.length > 1 ? 48 : 0);
          _map.fitCamera(
            CameraFit.coordinates(
              coordinates: [LatLng(point.$1, point.$2)],
              padding: EdgeInsets.fromLTRB(
                24,
                media.padding.top + 72,
                24,
                constraints.maxHeight * .14 + height + 32,
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
                          child: IconButton.filled(
                            tooltip: entry.value.length == 1
                                ? 'Seleccionar caso'
                                : 'Ver ${entry.value.length} casos',
                            style: IconButton.styleFrom(
                              backgroundColor: entry.key == _selected
                                  ? const Color(0xFF111111)
                                  : Colors.white,
                              foregroundColor: entry.key == _selected
                                  ? Colors.white
                                  : const Color(0xFF111111),
                              side: const BorderSide(color: Color(0xFF111111)),
                            ),
                            onPressed: () => select(entry.key, entry.value),
                            icon: entry.value.length == 1
                                ? const Icon(Icons.pets_outlined)
                                : Text(
                                    '${entry.value.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: entry.key == _selected
                                          ? Colors.white
                                          : const Color(0xFF111111),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    if (item != null)
                      Marker(
                        key: ValueKey(('callout', item.key)),
                        point: LatLng(item.latitude, item.longitude),
                        width: math.min(280, constraints.maxWidth - 32),
                        height: bubbleHeight + 32,
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            elevation: 3,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Builder(
                                    builder: (source) => Semantics(
                                      button: true,
                                      label:
                                          'Abrir caso ${item.name.isEmpty ? 'Sin nombre' : item.name}',
                                      child: EntityCardSurface(
                                        onTap: widget.onOpen == null
                                            ? null
                                            : () =>
                                                  widget.onOpen!(item, source),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name.isEmpty
                                                          ? 'Sin nombre'
                                                          : item.name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        height: 1.2,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF111111,
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Abrir caso',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        height: 1.2,
                                                        color: Color(
                                                          0xFF6E6E73,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (selected.length > 1)
                                  SizedBox(
                                    height: 48,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          tooltip: 'Caso anterior',
                                          onPressed: index == 0
                                              ? null
                                              : () => setState(
                                                  () => _selectedCaseKey =
                                                      selected[index - 1].key,
                                                ),
                                          icon: const Icon(
                                            Icons.chevron_left_rounded,
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            '${index + 1} de ${selected.length}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Caso siguiente',
                                          onPressed:
                                              index == selected.length - 1
                                              ? null
                                              : () => setState(
                                                  () => _selectedCaseKey =
                                                      selected[index + 1].key,
                                                ),
                                          icon: const Icon(
                                            Icons.chevron_right_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
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
              minChildSize: .14,
              maxChildSize: .9,
              snap: !media.disableAnimations,
              snapSizes: const [.14, .42, .9],
              shouldCloseOnMinExtent: false,
              builder: (context, scroll) => Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.filterBuilder(
                  context,
                  scroll,
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _MapSheetHandle(
                      onExpand: () => _moveSheet(.9),
                      onCollapse: () => _moveSheet(.14),
                    ),
                  ),
                  widget.query.latitude == null ||
                          widget.query.longitude == null
                      ? null
                      : () => SearchPlace(
                          label: '',
                          latitude: _map.camera.center.latitude,
                          longitude: _map.camera.center.longitude,
                        ),
                ),
              ),
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
      label: 'Desliza para ampliar o reducir los filtros',
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
