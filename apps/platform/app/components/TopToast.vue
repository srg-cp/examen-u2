<script setup lang="ts">
const message = ref(''); const visible = ref(false); const danger = ref(true);
const retry = shallowRef<(() => void) | null>(null);
let timer: ReturnType<typeof setTimeout> | undefined;
function close() { visible.value = false; clearTimeout(timer); }
function show(text: string, action: (() => void) | null = null, error = true) {
  close(); message.value = text; retry.value = action; danger.value = error; visible.value = true;
  timer = setTimeout(close, 6500);
}
onBeforeUnmount(close); defineExpose({ show });
</script>
<template>
  <aside id="notice" class="notice" :hidden="!visible" :role="danger ? 'alert' : 'status'">
    <span id="notice-message">{{ message }}</span>
    <button v-if="retry" id="notice-retry" type="button" @click="retry()">Reintentar</button>
    <button id="notice-close" type="button" aria-label="Cerrar aviso" @click="close">×</button>
  </aside>
</template>
