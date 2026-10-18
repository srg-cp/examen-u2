<script setup lang="ts">
import type { Map as LeafletMap, CircleMarker, GridLayer, Coords, DoneCallback } from 'leaflet';
import 'leaflet/dist/leaflet.css';
import type { SightingPoint } from '../../../../../shared/features/sightings/domain/sighting';
const props = defineProps<{ center: { latitude: number; longitude: number }; point: SightingPoint | null; disabled: boolean; invalid: boolean }>();
const emit = defineEmits<{ choose: [point: SightingPoint]; failed: [retry: () => void] }>();
const target = useTemplateRef('mapCanvas'); const ready = ref(false);
let map: LeafletMap | undefined; let marker: CircleMarker | undefined; let tiles: GridLayer | undefined; let disposed = false; let failed = false;
function choose(latitude: number, longitude: number) {
  if (props.disabled) return;
  emit('choose', { latitude: Math.max(-85, Math.min(85, latitude)), longitude: ((longitude + 180) % 360 + 360) % 360 - 180, source: 'manual', accuracy: null });
}
function retry() { failed = false; tiles?.redraw(); }
async function start() {
  try {
    const L = await import('leaflet');
    if (disposed || !target.value) return;
    map = L.map(target.value, { attributionControl: false, zoomControl: true, minZoom: 3, maxZoom: 18, maxBounds: [[-85, -540], [85, 540]] })
      .setView([props.point?.latitude ?? props.center.latitude, props.point?.longitude ?? props.center.longitude], 14);
    // GridLayer's public adapter avoids TileLayer's inline data-GIF cancellation,
    // keeping the existing strict CSP without allowing data: images.
    class SightingTileLayer extends L.GridLayer {
      override createTile(coords: Coords, done: DoneCallback) {
        const image = document.createElement('img'); image.alt = ''; image.referrerPolicy = 'no-referrer';
        image.onload = () => done?.(undefined, image);
        image.onerror = () => done?.(new Error('map_tile_unavailable'), image);
        image.src = `https://tile.openstreetmap.org/${coords.z}/${coords.x}/${coords.y}.png`;
        return image;
      }
    }
    tiles = new SightingTileLayer({ tileSize: 256, maxZoom: 19 });
    tiles.on('tileunload', event => { const image = event.tile as HTMLImageElement; image.onload = null; image.onerror = null; image.removeAttribute('src'); });
    tiles.on('tileerror', () => { if (!failed && !disposed) { failed = true; emit('failed', retry); } });
    tiles.addTo(map);
    map.on('click', event => choose(event.latlng.lat, event.latlng.lng));
    marker = L.circleMarker([0, 0], { radius: 9, color: '#111111', fillColor: '#111111', fillOpacity: 1, weight: 3 });
    sync(); ready.value = true;
  } catch { if (!disposed) emit('failed', start); }
}
function sync() {
  if (!map || !marker) return;
  if (props.point) { marker.setLatLng([props.point.latitude, props.point.longitude]).addTo(map); map.panTo(marker.getLatLng(), { animate: false }); }
  else marker.remove();
}
watch(() => props.point, sync);
onMounted(start);
onBeforeUnmount(() => { disposed = true; map?.remove(); });
</script>
<template>
  <div class="sighting-map-wrap" :class="{ invalid }">
    <div ref="mapCanvas" class="sighting-map" role="region" aria-label="Mapa para marcar dónde viste la mascota" :aria-invalid="invalid" />
    <div v-if="!ready" class="map-placeholder shape" role="status" aria-label="Preparando mapa" />
  </div>
  <ActionButton :disabled="disabled || !ready" @click="map && choose(map.getCenter().lat, map.getCenter().lng)">Usar centro del mapa</ActionButton>
</template>
