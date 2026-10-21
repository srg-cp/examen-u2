<script setup lang="ts">
import type { OriginSource } from '~/utils/origin_transition';
import { ORIGIN_ENTER_MS,ORIGIN_EXIT_MS } from '~/utils/origin_transition';
const app = useNuxtApp(),motion = app.$originTransition;
const router = useRouter();
const container = shallowRef<HTMLElement|null>(null);
const surface = useTemplateRef('surface'), icon = useTemplateRef('sourceIcon'), background = useTemplateRef('background');
const previous = useTemplateRef('previousContent');
const active = ref(false);
let animations:Animation[] = [],disposed = false,release:(()=>void)|undefined;
function cancel() { animations.forEach(a => a.cancel()); animations = []; release?.(); release = undefined; active.value = false;previous.value?.replaceChildren(); }
async function play(source:OriginSource,reverse:boolean) {
  cancel(); if (disposed) return;
  container.value = document.querySelector<HTMLElement>('.reader-shell:not(.user-navigation-host)');
  active.value = true; await nextTick();
  const node = surface.value, iconNode = icon.value, backdrop = background.value;
  if (!node || !iconNode || !backdrop || disposed) { active.value = false; return; }
  const target = document.querySelector<HTMLElement>('[data-origin-content]');
  if (!reverse && source.backdrop && source.backdropBounds && previous.value) {
    const rect = source.backdropBounds;
    Object.assign(source.backdrop.style,{position:'absolute',left:`${rect.x}px`,top:`${rect.y}px`,width:`${rect.width}px`,height:`${rect.height}px`,maxWidth:'none',margin:'0'});
    previous.value.append(source.backdrop);
  }
  const header = document.querySelector<HTMLElement>('.account-header');
  const top = Math.max(0,Math.min(innerHeight,header?.getBoundingClientRect().bottom || 0));
  const rect = source.element.isConnected ? source.element.getBoundingClientRect() : source.bounds;
  const start = { left:`${Math.max(0,Math.min(innerWidth-24,rect.x))}px`,top:`${Math.max(top,Math.min(innerHeight-24,rect.y))}px`,width:`${rect.width}px`,height:`${rect.height}px`,borderRadius:source.radius };
  const end = { left:'0px',top:`${top}px`,width:`${innerWidth}px`,height:`${Math.max(1,innerHeight-top)}px`,borderRadius:'0px' };
  Object.assign(node.style,{ background:source.background,color:source.color });
  Object.assign(backdrop.style,{ background:getComputedStyle(document.querySelector('.reader-shell') || document.documentElement).getPropertyValue('--page-background') || '#f5f7fa' });
  iconNode.replaceChildren(); if (source.icon) iconNode.append(source.icon.cloneNode(true));
  const duration = reverse ? ORIGIN_EXIT_MS : ORIGIN_ENTER_MS;
  const options:KeyframeAnimationOptions = { duration,easing:'cubic-bezier(.645,.045,.355,1)',fill:'both' };
  animations.push(node.animate(reverse ? [end,start] : [start,end],options));
  animations.push(backdrop.animate(reverse ? [{opacity:1},{opacity:0}] : [{opacity:0},{opacity:1}],options));
  animations.push(iconNode.animate(reverse ? [{opacity:0,offset:0},{opacity:0,offset:.55},{opacity:1,offset:1}] : [{opacity:1,offset:0},{opacity:0,offset:.45},{opacity:0,offset:1}],{...options,easing:'ease-in-out'}));
  if (target && !reverse) {
    // Reveal only the destination content, leaving brand/header and bar stable.
    animations.push(target.animate([{opacity:0,transform:'scale(.98)',offset:0},{opacity:0,transform:'scale(.98)',offset:.65},{opacity:1,transform:'scale(1)',offset:1}],{...options,easing:'ease-out'}));
    target.classList.add('origin-content-playing');
  }
  // Accessibility settings, resizing, rotation and unmount finish without a
  // stranded mask or an invisible/inert destination.
  const preference = matchMedia('(prefers-reduced-motion: reduce)');
  const interrupt = () => cancel();
  window.addEventListener('resize',interrupt,{once:true});preference.addEventListener('change',interrupt,{once:true});
  try { await Promise.race([Promise.all(animations.map(a => a.finished.catch(() => {}))),new Promise<void>(resolve => { release = resolve; })]); }
  finally {
    window.removeEventListener('resize',interrupt);preference.removeEventListener('change',interrupt);
    target?.classList.remove('origin-content-playing');
    cancel();
  }
}
onMounted(() => motion.setPlayer(play));
watch(() => router.currentRoute.value.path,() => { if (active.value) cancel(); });
watch(() => app.$navigationActor.value,() => { if (active.value) cancel(); });
onBeforeUnmount(() => { disposed = true; motion.setPlayer(undefined); cancel(); });
</script>
<template>
  <Teleport :to="container || 'body'" :disabled="!container">
  <div class="origin-transition-host" :class="{ 'origin-transition-active':active }" aria-hidden="true" inert>
    <div ref="previousContent" class="origin-transition-previous" />
    <div ref="surface" class="origin-transition-surface"><div ref="background" class="origin-transition-background" /><div ref="sourceIcon" class="origin-transition-icon" /></div>
  </div>
  </Teleport>
</template>
<style>
.origin-transition-host{position:fixed;inset:0;z-index:8;pointer-events:none;visibility:hidden;overflow:hidden}
.origin-transition-host.origin-transition-active{visibility:visible}
.origin-transition-surface{position:absolute;overflow:hidden;box-shadow:0 0 24px #00000020}
.origin-transition-previous{position:absolute;inset:0;overflow:hidden;pointer-events:none}
.origin-transition-background{position:absolute;inset:0}
.origin-transition-icon{position:absolute;inset:0;display:grid;place-items:center}
.origin-transition-icon :is(svg,img){display:block;width:24px;height:24px}
.origin-content-pending:not(.origin-content-playing){opacity:0}
.origin-content-playing{position:relative;z-index:9;transform-origin:top left}
@media(prefers-reduced-motion:reduce){.origin-transition-host{display:none}.origin-content-pending:not(.origin-content-playing){opacity:1}}
</style>
