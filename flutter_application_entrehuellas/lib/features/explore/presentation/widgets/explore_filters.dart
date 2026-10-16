import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/filter_choice_group.dart';
import '../../../../core/presentation/widgets/filter_expansion.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../domain/entities/explore_query.dart';
import 'place_search_fields.dart';

class ExploreFilters extends StatefulWidget {
  const ExploreFilters({
    required this.enabled,
    this.applying = false,
    this.query = const ExploreQuery(radiusMeters: 15000),
    this.onUseCurrentLocation,
    required this.onApply,
    super.key,
  });
  final bool enabled, applying;
  final ExploreQuery query;
  final VoidCallback? onUseCurrentLocation;
  final void Function(
    ExploreKind,
    ExploreSpecies,
    ExploreStatus,
    int,
    double?,
    double?,
    int?,
  )
  onApply;
  @override
  State<ExploreFilters> createState() => _ExploreFiltersState();
}

class _ExploreFiltersState extends State<ExploreFilters> {
  late _FilterSelection _selection = _FilterSelection(
    lat: widget.query.latitude,
    lon: widget.query.longitude,
    radius: widget.query.radiusMeters ?? 15000,
    label: widget.query.latitude == null ? '' : 'Ubicación actual',
  );

  @override
  void didUpdateWidget(covariant ExploreFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query.latitude != _selection.lat ||
        widget.query.longitude != _selection.lon ||
        widget.query.radiusMeters != _selection.radius) {
      _selection = _FilterSelection(
        kind: widget.query.kind,
        species: widget.query.species,
        status: widget.query.status,
        days: _selection.days,
        lat: widget.query.latitude,
        lon: widget.query.longitude,
        radius: widget.query.radiusMeters ?? 15000,
        label: widget.query.latitude == null ? '' : 'Ubicación actual',
      );
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < 390 ||
          MediaQuery.textScalerOf(context).scale(14) > 16;
      final filters = FilterExpansion<_FilterSelection>(
        label: 'Filtrar casos',
        enabled: widget.enabled,
        applying: widget.applying,
        panelWidth: constraints.maxWidth,
        editorBuilder: (context, confirm) =>
            _ExploreFilterEditor(initial: _selection, onConfirm: confirm),
        onApply: _apply,
      );
      final zone = FilterExpansion<_FilterSelection>(
        label: 'Ubicación',
        icon: Icons.location_on_outlined,
        enabled: widget.enabled,
        applying: widget.applying,
        panelWidth: constraints.maxWidth,
        alignPanelToEnd: !stacked,
        editorBuilder: (context, confirm) => _ExploreFilterEditor(
          initial: _selection,
          zoneOnly: true,
          onUseCurrentLocation: widget.onUseCurrentLocation,
          onConfirm: confirm,
        ),
        onApply: _apply,
      );
      return stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [filters, const SizedBox(height: 10), zone],
            )
          : Row(
              children: [
                Expanded(child: filters),
                const SizedBox(width: 10),
                Expanded(child: zone),
              ],
            );
    },
  );

  void _apply(_FilterSelection value) {
    setState(() => _selection = value);
    widget.onApply(
      value.kind,
      value.species,
      value.status,
      value.days,
      value.lat,
      value.lon,
      value.radius,
    );
  }
}

class _FilterSelection {
  const _FilterSelection({
    this.kind = ExploreKind.all,
    this.species = ExploreSpecies.all,
    this.status = ExploreStatus.active,
    this.days = 0,
    this.radius = 15000,
    this.lat,
    this.lon,
    this.label = '',
  });
  final ExploreKind kind;
  final ExploreSpecies species;
  final ExploreStatus status;
  final int days, radius;
  final double? lat, lon;
  final String label;
}

class _ExploreFilterEditor extends StatefulWidget {
  const _ExploreFilterEditor({
    required this.initial,
    required this.onConfirm,
    this.zoneOnly = false,
    this.onUseCurrentLocation,
  });
  final bool zoneOnly;
  final VoidCallback? onUseCurrentLocation;
  final ValueChanged<_FilterSelection> onConfirm;
  final _FilterSelection initial;
  @override
  State<_ExploreFilterEditor> createState() => _ExploreFilterEditorState();
}

class _ExploreFilterEditorState extends State<_ExploreFilterEditor> {
  late ExploreKind _kind = widget.initial.kind;
  late ExploreSpecies _species = widget.initial.species;
  late ExploreStatus _status = widget.initial.status;
  late int _days = widget.initial.days, _radius = widget.initial.radius;
  int _shake = 0;
  late String _label = widget.initial.label;
  late double? _lat = widget.initial.lat, _lon = widget.initial.lon;
  bool _invalid = false, _submitted = false;
  FilterChoice<T> option<T>(T value, String label) =>
      FilterChoice(value, label);
  @override
  Widget build(BuildContext context) => ConfirmationToastHost(
    confirmed: _invalid,
    isError: true,
    noticeId: _shake,
    message: 'Selecciona una ubicación en el mapa para filtrar por distancia.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.zoneOnly) ...[
          FilterChoiceGroup<ExploreKind>(
            label: 'Tipo',
            value: _kind,
            options: [
              option(ExploreKind.all, 'Todos'),
              option(ExploreKind.lost, 'Perdidas'),
              option(ExploreKind.found, 'Encontradas'),
              option(ExploreKind.sighting, 'Avistamientos'),
            ],
            onChanged: !_submitted ? (v) => setState(() => _kind = v) : null,
          ),
          const SizedBox(height: 12),
          FilterChoiceGroup<ExploreSpecies>(
            label: 'Especie',
            value: _species,
            options: [
              option(ExploreSpecies.all, 'Todas'),
              option(ExploreSpecies.dog, 'Perro'),
              option(ExploreSpecies.cat, 'Gato'),
              option(ExploreSpecies.other, 'Otra especie'),
            ],
            onChanged: !_submitted ? (v) => setState(() => _species = v) : null,
          ),
          const SizedBox(height: 12),
          FilterChoiceGroup<ExploreStatus>(
            label: 'Estado',
            value: _status,
            options: [
              option(ExploreStatus.active, 'Abiertos'),
              option(ExploreStatus.resolved, 'Resueltos'),
              option(ExploreStatus.all, 'Todos'),
            ],
            onChanged: !_submitted ? (v) => setState(() => _status = v) : null,
          ),
          const SizedBox(height: 8),
          const Text(
            'Solo ves los casos resueltos de tu cuenta.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
          ),
          const SizedBox(height: 20),
          FilterChoiceGroup<int>(
            label: 'Fecha del suceso',
            value: _days,
            options: [
              option(0, 'Cualquier fecha'),
              option(1, 'Últimas 24 horas'),
              option(7, 'Últimos 7 días'),
              option(30, 'Últimos 30 días'),
              option(90, 'Últimos 90 días'),
            ],
            onChanged: !_submitted ? (v) => setState(() => _days = v) : null,
          ),
        ],
        if (widget.zoneOnly) ...[
          const Text(
            'Ubicación de búsqueda',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (widget.onUseCurrentLocation != null)
            TextButton.icon(
              onPressed: _submitted ? null : widget.onUseCurrentLocation,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Usar mi ubicación actual'),
            ),
          const SizedBox(height: 16),
          PlaceSearchFields(
            initialLabel: _label,
            onSelect: (place) => setState(() {
              _lat = place.latitude;
              _lon = place.longitude;
              _label = place.label;
              _invalid = false;
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Radio: ${(_radius / 1000).round()} km',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Slider(
            value: (_radius / 1000).clamp(1, 50).toDouble(),
            min: 1,
            max: 50,
            divisions: 49,
            label: '${(_radius / 1000).round()} km',
            semanticFormatterCallback: (value) =>
                'Radio de búsqueda de ${value.round()} kilómetros',
            onChanged: _submitted
                ? null
                : (value) => setState(() => _radius = value.round() * 1000),
          ),
          if (_label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Centro: $_label',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
              ),
            ),
          const Text(
            'Selecciona un lugar o toca el mapa para ajustar el centro. El círculo muestra el radio de búsqueda.',
          ),
          const SizedBox(height: 12),
          ShakeField(
            errorId: _shake,
            hasError: _invalid,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _invalid
                      ? const Color(0xFFB53F48)
                      : Colors.transparent,
                  width: 3.5,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: IgnorePointer(
                ignoring: _submitted,
                child: ZoneMapPicker(
                  latitude: _lat,
                  longitude: _lon,
                  radiusMeters: _radius,
                  fitRadius: true,
                  onSelect: (lat, lon) => setState(() {
                    _lat = lat;
                    _lon = lon;
                    _label = 'Punto elegido en el mapa';
                    _invalid = false;
                  }),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          style: primaryActionButtonStyle(context),
          onPressed: _submitted
              ? null
              : () {
                  if (_lat == null || _lon == null) {
                    setState(() {
                      _invalid = true;
                      _shake++;
                    });
                    return;
                  }
                  setState(() => _submitted = true);
                  widget.onConfirm(
                    _FilterSelection(
                      kind: _kind,
                      species: _species,
                      status: _status,
                      days: _days,
                      radius: _radius,
                      lat: _lat,
                      lon: _lon,
                      label: _label,
                    ),
                  );
                },
          child: Text(
            widget.zoneOnly ? 'Aplicar ubicación' : 'Aplicar filtros',
          ),
        ),
      ],
    ),
  );
}
