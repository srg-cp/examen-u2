<script setup lang="ts">
withDefaults(defineProps<{ withBack?: boolean; wide?: boolean; minimal?: boolean }>(), { withBack: false, wide: false, minimal: false });
</script>
<template>
  <div class="reader-shell" :class="{ 'with-back': withBack, wide }">
  <a class="skip-link" href="#view">Saltar al contenido</a>
  <header v-if="!minimal" class="brand"><a href="/" aria-label="entre huellas · Inicio"><img src="/brand.png" width="46" height="46" alt=""><span>entre huellas</span></a></header>
  <slot />
  <footer v-if="!minimal">Un encuentro puede cambiarlo todo.<br><strong>Entre Huellas</strong></footer>
  </div>
</template>
