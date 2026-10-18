<script setup lang="ts">
withDefaults(defineProps<{ working?: boolean; disabled?: boolean; variant?: string }>(), { working: false, disabled: false, variant: 'secondary' });
</script>
<template><button type="button" :class="[variant, { working }]" :disabled="working || disabled" :aria-busy="working"><slot /></button></template>
