<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router';
defineOptions({ inheritAttrs: false });
const props = defineProps<{ to: RouteLocationRaw; origin?:boolean }>();
const app = useNuxtApp(),router = useRouter();
const working = ref(false);
async function follow(event: MouseEvent, navigate: (event?: MouseEvent) => Promise<unknown>) {
  if (working.value || app.$originTransition.busy.value) { event.preventDefault(); return; }
  // Preserve browser conventions: new tab/window and modified clicks.
  if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey ||
      (event.currentTarget as HTMLAnchorElement).target === '_blank') return;
  working.value = true;
  try {
    if (props.origin) {
      const source = event.currentTarget as HTMLElement;
      // Prevent default synchronously; router callbacks still run all guards.
      event.preventDefault();
      const to = router.resolve(props.to).path;
      await app.$originTransition.open(source,() => router.push(props.to),{from:router.currentRoute.value.path,to,current:() => router.currentRoute.value.path});
    } else await navigate(event);
  }
  finally { working.value = false; }
}
</script>
<template>
  <NuxtLink :to="to" custom v-slot="{ href, navigate, isExactActive }">
    <a :href="href ?? undefined" v-bind="$attrs" class="navigation-link" :class="{ working }" :aria-busy="working" :aria-disabled="working || undefined" :aria-current="isExactActive ? 'page' : undefined" @click="follow($event, navigate)"><slot /></a>
  </NuxtLink>
</template>
