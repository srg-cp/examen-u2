/// Presentation-only map service configuration; contains no credentials or location.
class MapConfig {
  const MapConfig._();
  static const tileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );
  static const attribution = String.fromEnvironment(
    'MAP_ATTRIBUTION',
    defaultValue: '© OpenStreetMap contributors',
  );
  static const attributionUrl = String.fromEnvironment(
    'MAP_ATTRIBUTION_URL',
    defaultValue: 'https://www.openstreetmap.org/copyright',
  );
}
