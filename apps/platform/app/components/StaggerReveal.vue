<script setup lang="ts">
import { onMounted, ref, useTemplateRef, watchEffect } from 'vue';
import { useStaggerReveal } from '~/composables/useStaggerReveal';
withDefaults(defineProps<{ as?: 'div' | 'article' | 'section' | 'form' }>(), { as: 'div' });
const root = useTemplateRef<HTMLElement>('root');
const ready = ref(false);
const { revealStyle } = useStaggerReveal();
// The QR remains readable without JavaScript; this external stylesheet is
// activated by noscript only and respects the existing style-src 'self' CSP.
useHead({ noscript: [{ key: 'stagger-no-script', innerHTML: '<link rel="stylesheet" href="/styles/stagger-no-script.css">' }] });
onMounted(() => {
  // Capture this entrance only. Later edits/refreshes/new children stay visible
  // rather than replaying the entrance on every component update.
  const elements = Array.from(root.value?.children ?? []) as HTMLElement[];
  watchEffect(() => {
    elements.forEach((element, index) => Object.assign(element.style, revealStyle(index)));
  });
  ready.value = true;
});
</script>
<template>
  <component :is="as" ref="root" class="stagger-reveal-group" :class="{ 'stagger-reveal-ready': ready }"><slot /></component>
</template>

