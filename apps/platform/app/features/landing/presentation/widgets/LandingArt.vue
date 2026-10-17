<script setup lang="ts">
defineProps<{ name: 'hero-dog' | 'hero-cat' | 'return' | 'search' | 'found' | 'help' | 'step-search' | 'step-found' | 'step-help' | 'step-return' | 'home' | 'map' | 'report' | 'share' | 'collaborate' | 'footer-dog' | 'footer-cat'; label?: string }>();
</script>
<template>
  <div :class="['art', `art-${name}`]" :role="label ? 'img' : undefined" :aria-label="label" :aria-hidden="label ? undefined : true">
    <img src="/images/landing-reference.png" alt="" width="731" height="2152" decoding="async" draggable="false">
  </div>
</template>
