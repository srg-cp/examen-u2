<script setup lang="ts">
import LandingIcon from './LandingIcon.vue';
defineProps<{ footer?: boolean }>();
</script>
<template><a :class="['brand', { 'brand-footer': footer }]" href="#inicio" aria-label="Entre Huellas, inicio"><LandingIcon name="paw" /><span v-if="footer">Entre<br>Huellas</span><span v-else>Entre Huellas</span></a></template>
