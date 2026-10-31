import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/collection_empty_state.dart';
import '../../../../core/presentation/widgets/map_case_sheet.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';
import '../../domain/entities/current_location.dart';
import 'explore_map_pins.dart';
import 'explore_map_case_preview.dart';

class ExploreCaseMap extends StatefulWidget {
  const ExploreCaseMap({
    required this.items,
    required this.query,
    required this.onOpen,
    this.trailing = const [],
    this.emptyMessage,
    this.createTileProvider,
    this.previewBuilder,
    this.currentLocation,
    this.locationUnavailable = false,
    this.onManualLocationSelected,
    super.key,
  });
  final List<ExploreCase> items;
  final ExploreQuery query;
  final CurrentLocation? currentLocation;
  final bool locationUnavailable;
  final void Function(double latitude, double longitude)?
  onManualLocationSelected;
  final void Function(ExploreCase, BuildContext)? onOpen;
  final List<Widget> trailing;
  final String? emptyMessage;
  final TileProvider Function()? createTileProvider;
  final Widget Function(ExploreCase, ValueChanged<double>)? previewBuilder;
  @override
  State<ExploreCaseMap> createState() => _ExploreCaseMapState();
}

class _ExploreCaseMapState extends State<ExploreCaseMap> {
  final _sheet = GlobalKey<MapCaseSheetState>();
  final _map = MapController();
  String? _selectedCaseKey;
  LatLng? _manualPoint;
  @override
  void didUpdateWidget(covariant ExploreCaseMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.locationUnavailable) _manualPoint = null;
    if (!identical(oldWidget.query, widget.query)) {
      _selectedCaseKey = null;
      final query = widget.query;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && identical(widget.query, query)) {
          _sheet.currentState?.showSummary(resetScroll: false);
        }
      });
    }
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items
        .where((item) => item.key == _selectedCaseKey)
        .firstOrNull;
    final media = MediaQuery.of(context);
    // A failed GPS reading must not be replaced by an older device location.
    final location = widget.locationUnavailable ? null : widget.currentLocation;
    final center =
        _manualPoint ??
        (location == null
            ? null
            : LatLng(location.latitude, location.longitude));
    return MapCaseSheet(
      key: _sheet,
      hasSelection: item != null,
      showAttribution: true,
      mapBuilder: (constraints, summaryHeight) {
        void select(ExploreCase selected) {
          final selectedExtent = math.max(
            .5,
            ((32 + summaryHeight + media.padding.bottom + 12) /
                    constraints.maxHeight)
                .clamp(.18, .85),
          );
          setState(() => _selectedCaseKey = selected.key);
          _sheet.currentState?.showSummary();
          _map.fitCamera(
            CameraFit.coordinates(
              coordinates: [LatLng(selected.latitude, selected.longitude)],
              padding: EdgeInsets.fromLTRB(
                24,
                media.padding.top + 24,
                24,
                math.min(
                  constraints.maxHeight - media.padding.top - 24,
                  constraints.maxHeight * selectedExtent + 72,
                ),
              ),
              maxZoom: math.max(_map.camera.zoom, 15),
            ),
          );
        }

        return ZoneMapPicker(
          controller: _map,
          latitude: center?.latitude ?? widget.query.latitude,
          longitude: center?.longitude ?? widget.query.longitude,
          radiusMeters:
              widget.query.radiusMeters ??
              (location == null
                  ? 15000
                  : math.max(75, location.accuracyMeters.ceil())),
          onSelect:
              widget.locationUnavailable &&
                  widget.onManualLocationSelected != null
              ? (latitude, longitude) {
                  setState(() => _manualPoint = LatLng(latitude, longitude));
                  widget.onManualLocationSelected?.call(latitude, longitude);
                }
              : null,
          onMapTap: () => setState(() => _selectedCaseKey = null),
          readOnly: !widget.locationUnavailable,
          readOnlyNavigation: true,
          fitRadius: true,
          showCenterMarker: _manualPoint != null,
          showRadius: false,
          showAttribution: false,
          circles: [
            if (location != null)
              CircleMarker(
                point: LatLng(location.latitude, location.longitude),
                radius: location.accuracyMeters,
                useRadiusInMeter: true,
                color: const Color(0x223B82F6),
                borderColor: const Color(0xFF3B82F6),
                borderStrokeWidth: 2,
              ),
          ],
          createTileProvider: widget.createTileProvider,
          height: constraints.maxHeight,
          borderRadius: 0,
          cameraPadding: EdgeInsets.fromLTRB(
            24,
            media.padding.top + 76,
            24,
            constraints.maxHeight * .5 + 16,
          ),
          markerLayer: ExploreMapPins(
            items: widget.items,
            selectedKey: _selectedCaseKey,
            onSelect: select,
          ),
        );
      },
      panelBuilder: (onSummaryHeight) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (location != null && item == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación GPS\n'
                    'Latitud: ${location.latitude.toStringAsFixed(6)}\n'
                    'Longitud: ${location.longitude.toStringAsFixed(6)}',
                  ),
                  Text('Precisión ± ${location.accuracyMeters.ceil()} m'),
                ],
              ),
            ),
          if (widget.locationUnavailable && item == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Text(
                _manualPoint == null
                    ? 'Toca el mapa para elegir tu ubicación.'
                    : 'Ubicación elegida en el mapa\n'
                          'Latitud: ${_manualPoint!.latitude.toStringAsFixed(6)}\n'
                          'Longitud: ${_manualPoint!.longitude.toStringAsFixed(6)}',
              ),
            ),
          if (item == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CollectionEmptyState(
                title: widget.items.isNotEmpty
                    ? 'Selecciona un pin'
                    : widget.emptyMessage != null
                    ? 'Explora los casos cercanos'
                    : 'No encontramos casos',
                description: widget.items.isNotEmpty
                    ? 'Selecciona un pin para ver el resumen del caso.'
                    : widget.emptyMessage ??
                          'Prueba con otra ubicación o ajusta los filtros de búsqueda.',
              ),
            )
          else
            widget.previewBuilder?.call(item, onSummaryHeight) ??
                ExploreMapPreviewContent(
                  item: item,
                  scrollable: false,
                  onSummaryHeight: onSummaryHeight,
                  onOpen: widget.onOpen == null
                      ? null
                      : (source) => widget.onOpen!(item, source),
                ),
          ...widget.trailing,
        ],
      ),
    );
  }
}
