<script setup lang="ts">
import { landingArtwork, type LandingArtworkName } from './landing_artwork';
const props = defineProps<{ name: LandingArtworkName; label?: string; eager?: boolean }>();
const artwork = computed(() => landingArtwork[props.name]);
</script>
<template>
  <div :class="['art', `art-${name}`]" :role="label ? 'img' : undefined" :aria-label="label" :aria-hidden="label ? undefined : true">
    <img :src="artwork.src" alt="" :width="artwork.width" :height="artwork.height" :loading="eager || name.startsWith('hero-') ? 'eager' : 'lazy'" decoding="async" draggable="false">
  </div>
</template>
