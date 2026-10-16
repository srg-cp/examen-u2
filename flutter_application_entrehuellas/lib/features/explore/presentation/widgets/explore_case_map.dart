import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';
import 'explore_case_grid.dart';

/// Renders exactly the loaded list pages; gestures never change the query.
class ExploreCaseMap extends StatefulWidget {
  const ExploreCaseMap({
    required this.items,
    required this.query,
    required this.onOpen,
    this.createTileProvider,
    super.key,
  });

  final List<ExploreCase> items;
  final ExploreQuery query;
  final void Function(ExploreCase, BuildContext)? onOpen;
  final TileProvider Function()? createTileProvider;

  @override
  State<ExploreCaseMap> createState() => _ExploreCaseMapState();
}

class _ExploreCaseMapState extends State<ExploreCaseMap> {
  (double, double)? _selected;
  int _linkFailure = 0;

  Future<void> _openAttribution() async {
    try {
      if (await launchUrl(
        Uri.parse('https://www.openstreetmap.org/copyright'),
      )) {
        return;
      }
    } catch (_) {
      // External failures remain presentation feedback, never raw exceptions.
    }
    if (mounted) setState(() => _linkFailure++);
  }

  @override
  Widget build(BuildContext context) {
    final groups = <(double, double), List<ExploreCase>>{};
    for (final item in widget.items) {
      groups.putIfAbsent((item.latitude, item.longitude), () => []).add(item);
    }
    final selected = groups[_selected] ?? const <ExploreCase>[];
    return ConfirmationToastHost(
      confirmed: _linkFailure > 0,
      noticeId: _linkFailure,
      isError: true,
      message: 'No pudimos abrir la información del mapa.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Ubicaciones aproximadas. Toca un punto para ver sus casos.',
              style: TextStyle(color: Color(0xFF6E6E73)),
            ),
          ),
          ZoneMapPicker(
            latitude: widget.query.latitude,
            longitude: widget.query.longitude,
            radiusMeters: widget.query.radiusMeters!,
            onSelect: null,
            readOnly: true,
            readOnlyNavigation: true,
            fitRadius: true,
            showCenterMarker: false,
            createTileProvider: widget.createTileProvider,
            height: 320,
            attribution: Align(
              alignment: Alignment.bottomRight,
              child: Material(
                color: Colors.white,
                child: TextButton(
                  onPressed: _openAttribution,
                  child: const Text('© OpenStreetMap contributors'),
                ),
              ),
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
                        ? '${entry.value.single.name.isEmpty ? 'Sin nombre' : entry.value.single.name}, ${entry.value.single.status == ExploreStatus.active ? 'abierto' : 'resuelto'}. Ver caso en ubicación aproximada'
                        : 'Ver ${entry.value.length} casos en esta ubicación aproximada',
                    child: IconButton.filled(
                      tooltip: entry.value.length == 1
                          ? 'Ver caso'
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
                      onPressed: widget.onOpen == null
                          ? null
                          : () => setState(() => _selected = entry.key),
                      icon: entry.value.length == 1
                          ? const Icon(Icons.pets_outlined)
                          : FittedBox(
                              child: Text(
                                '${entry.value.length}',
                                style: TextStyle(
                                  color: entry.key == _selected
                                      ? Colors.white
                                      : const Color(0xFF111111),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
          if (selected.isNotEmpty) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                selected.length == 1
                    ? 'Caso seleccionado'
                    : '${selected.length} casos en esta ubicación',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            ExploreCaseGrid(items: selected, onOpen: widget.onOpen),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '${widget.items.length} ${widget.items.length == 1 ? 'caso consultado' : 'casos consultados'}. Lista y mapa comparten los mismos resultados.',
              style: const TextStyle(color: Color(0xFF6E6E73)),
            ),
          ),
        ],
      ),
    );
  }
}
