<script setup lang="ts">
const route = useRoute(),app = useNuxtApp();
const accountRoute = computed(() => ['/inicio','/explorar','/mis-mascotas','/reportar'].includes(route.path));
</script>
<template>
  <NuxtPage :page-key="route => route.path" />
  <div v-if="app.$navigationActor.value" v-show="accountRoute" class="reader-shell user-navigation-host"><UserNavigation /></div>
  <OriginTransitionHost />
</template>
<style>.reader-shell.user-navigation-host{min-height:0;background:none}</style>
