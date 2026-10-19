<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router';
defineOptions({ inheritAttrs: false });
defineProps<{ to: RouteLocationRaw }>();
const working = ref(false);
async function follow(event: MouseEvent, navigate: (event?: MouseEvent) => Promise<unknown>) {
  if (working.value) { event.preventDefault(); return; }
  // Preserve browser conventions: new tab/window and modified clicks.
  if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey ||
      (event.currentTarget as HTMLAnchorElement).target === '_blank') return;
  working.value = true;
  try { await navigate(event); }
  finally { working.value = false; }
}
</script>
<template>
  <NuxtLink :to="to" custom v-slot="{ href, navigate, isExactActive }">
    <a :href="href ?? undefined" v-bind="$attrs" class="navigation-link" :class="{ working }" :aria-busy="working" :aria-disabled="working || undefined" :aria-current="isExactActive ? 'page' : undefined" @click="follow($event, navigate)"><slot /></a>
  </NuxtLink>
</template>
