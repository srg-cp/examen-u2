import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/map_config.dart';

/// Visual map adapter only. The ViewModel owns the selected product coordinates.
class ZoneMapPicker extends StatefulWidget {
  const ZoneMapPicker({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.onSelect,
    this.createTileProvider,
    super.key,
  });
  final double? latitude;
  final double? longitude;
  final int radiusMeters;
  final void Function(double latitude, double longitude)? onSelect;
  final TileProvider Function()? createTileProvider;
  @override
  State<ZoneMapPicker> createState() => _ZoneMapPickerState();
}

class _ZoneMapPickerState extends State<ZoneMapPicker> {
  final _controller = MapController();
  late TileProvider _tiles;
  TileProvider _createTiles() =>
      widget.createTileProvider?.call() ?? NetworkTileProvider();
  @override
  void initState() {
    super.initState();
    _tiles = _createTiles();
  }

  @override
  void didUpdateWidget(ZoneMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != null &&
        widget.longitude != null &&
        (widget.latitude != oldWidget.latitude ||
            widget.longitude != oldWidget.longitude)) {
      _controller.move(
        LatLng(widget.latitude!, widget.longitude!),
        _controller.camera.zoom,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _failed = false;
  int _attempt = 0;
  void _failure(int attempt) {
    if (_failed || attempt != _attempt) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_failed && attempt == _attempt) {
        setState(() => _failed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attempt = _attempt;
    final point = widget.latitude == null || widget.longitude == null
        ? null
        : LatLng(widget.latitude!, widget.longitude!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 280,
            child: FlutterMap(
              mapController: _controller,
              key: ValueKey(_attempt),
              options: MapOptions(
                initialCenter: point ?? const LatLng(-12.0464, -77.0428),
                initialZoom: 12,
                minZoom: 3,
                maxZoom: 18,
                backgroundColor: const Color(0xFFF5F5F7),
                onTap: (_, location) {
                  if (!_failed) {
                    widget.onSelect?.call(
                      location.latitude,
                      location.longitude,
                    );
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: MapConfig.tileUrl,
                  tileProvider: _tiles,
                  userAgentPackageName:
                      'com.example.flutter_application_entrehuellas',
                  panBuffer: 0,
                  errorTileCallback: (_, _, _) => _failure(attempt),
                ),
                if (point != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: point,
                        radius: widget.radiusMeters.toDouble(),
                        useRadiusInMeter: true,
                        color: const Color(0x22111111),
                        borderColor: const Color(0xFF111111),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                if (point != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF111111),
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        // Outside the map: attribution stays visible at large text scales.
        TextButton(
          onPressed: () => launchUrl(Uri.parse(MapConfig.attributionUrl)),
          child: const Text(MapConfig.attribution, textAlign: TextAlign.center),
        ),
        if (_failed) ...[
          const Text(
            'No se pudo mostrar el mapa. Reintenta o indica las coordenadas.',
            style: TextStyle(color: Color(0xFFB53F48)),
          ),
          TextButton(
            onPressed: () => setState(() {
              _failed = false;
              _attempt++;
              _tiles = _createTiles();
            }),
            child: const Text('Reintentar mapa'),
          ),
        ],
      ],
    );
  }
}
