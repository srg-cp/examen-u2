<script setup lang="ts">
const message = ref(''); const visible = ref(false); const danger = ref(true);
const noticeId = ref(0);
const retry = shallowRef<(() => void) | null>(null);
let timer: ReturnType<typeof setTimeout> | undefined;
function close() { visible.value = false; clearTimeout(timer); }
function show(text: string, action: (() => void) | null = null, error = true) {
  close(); message.value = text; retry.value = action; danger.value = error; noticeId.value++; visible.value = true;
  timer = setTimeout(close, 6500);
}
function retryAndClose() { const action = retry.value; close(); action?.(); }
onBeforeUnmount(close); defineExpose({ show, close });
</script>
<template>
  <aside id="notice" :key="noticeId" class="notice" :class="{ 'notice-danger': danger }" :hidden="!visible" :role="danger ? 'alert' : 'status'" @click="close">
    <span class="notice-icon"><AppIcon :name="danger ? 'error-outline' : 'check'" /></span>
    <div class="notice-content">
      <button id="notice-close" type="button" aria-label="Cerrar aviso" @click.stop="close"><span id="notice-message">{{ message }}</span></button>
      <button v-if="retry" id="notice-retry" type="button" @click.stop="retryAndClose">Reintentar</button>
    </div>
  </aside>
</template>
<style>
.reader-shell .notice{
  position:fixed;z-index:10;top:calc(env(safe-area-inset-top,0px) + 12px);left:50%;
  transform:translateX(-50%);width:max-content;max-width:min(360px,calc(100vw - 48px));
  max-height:clamp(48px,30svh,220px);overflow:auto;overscroll-behavior:contain;
  display:flex;align-items:flex-start;gap:10px;min-height:48px;margin:0;padding:8px 16px;
  border-radius:28px;border:1px solid #ffffffb3;background:#f5f5f7e6;color:#111111;
  backdrop-filter:blur(18px);box-shadow:0 6px 20px #24282a1a;cursor:pointer;
  animation:toast-fade 180ms linear both,toast-slide 180ms cubic-bezier(.215,.61,.355,1) both;
}
.reader-shell .notice-icon{
  display:grid;place-items:center;flex:0 0 32px;width:32px;height:32px;
  border-radius:50%;background:#24282a0d;color:#111111;
}
.reader-shell .notice-danger .notice-icon{color:#b53f48}
.reader-shell .notice-icon .app-icon{width:20px;height:20px;display:block}
.reader-shell .notice-content{min-width:0;flex:1}
.reader-shell .notice button{
  display:block;min-width:0;min-height:32px;width:100%;padding:0;border:0;
  border-radius:12px;background:transparent;color:#111111;text-align:left;
  font-family:inherit;font-size:.875rem;font-weight:400;line-height:1.4;overflow-wrap:anywhere;
}
.reader-shell .notice #notice-retry{min-height:44px;width:auto;padding:8px 0;text-decoration:underline;text-underline-offset:3px}
@keyframes toast-fade{from{opacity:0}to{opacity:1}}
@keyframes toast-slide{from{transform:translate(-50%,-12%)}to{transform:translate(-50%,0)}}
</style>
