<script setup lang="ts">
withDefaults(defineProps<{ working?: boolean; variant?: string }>(), { working: false, variant: 'secondary' });
</script>
<template><button type="button" :class="[variant, { working }]" :disabled="working" :aria-busy="working"><slot /></button></template>
