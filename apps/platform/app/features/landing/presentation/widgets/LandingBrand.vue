<script setup lang="ts">
defineProps<{ footer?: boolean }>();
</script>
<template>
  <a :class="['brand', { 'brand-footer': footer }]" href="#inicio" aria-label="Entre Huellas, inicio">
    <img src="/brand.png" alt="" width="48" height="48" decoding="async">
    <span v-if="footer">Entre<br>Huellas</span><span v-else>Entre Huellas</span>
  </a>
</template>
