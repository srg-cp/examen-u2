import { nextTick, readonly, shallowRef } from 'vue';

export const ORIGIN_ENTER_MS = 320;
export const ORIGIN_EXIT_MS = 260;
export type OriginSource = Readonly<{ bounds: { x:number;y:number;width:number;height:number }; radius:string; background:string; color:string; icon:Element|null; element:HTMLElement;backdrop:HTMLElement|null;backdropBounds:DOMRect|null }>;
export type OriginPlayer = (source:OriginSource, reverse:boolean) => Promise<void>;

function capture(element:HTMLElement):OriginSource {
  const rect = element.getBoundingClientRect(), style = getComputedStyle(element);
  // Capture only the decorative icon, never forms, typed data or a DOM snapshot.
  let icon = element.querySelector('svg,img')?.cloneNode(true) as Element | undefined;
  if (!icon && element.textContent?.trim()) { const label = document.createElement('span');label.textContent = element.textContent.trim();label.style.font = style.font;icon = label; }
  if (icon) {
    for (const item of [icon,...icon.querySelectorAll('*')]) {
      item.removeAttribute('id');
      for (const attr of [...item.attributes]) if (/^on/i.test(attr.name)) item.removeAttribute(attr.name);
    }
    icon.setAttribute('aria-hidden','true');
  }
  const content = document.querySelector<HTMLElement>('[data-origin-content]');
  const backdrop = content ? document.createElement('div') : null;
  if (backdrop && content) {
    for (const attr of [...content.attributes]) backdrop.setAttribute(attr.name,attr.value);
    for (const child of [...content.childNodes]) backdrop.append(child.cloneNode(true));
  }
  if (backdrop) {
    backdrop.querySelectorAll('input,textarea,select,dialog,script,iframe,[role="alert"],[role="status"]').forEach(node => node.remove());
    for (const node of [backdrop,...backdrop.querySelectorAll<HTMLElement>('*')]) {
      node.removeAttribute('id');node.removeAttribute('data-origin-content');
      for (const attr of [...node.attributes]) if (/^on/i.test(attr.name)) node.removeAttribute(attr.name);
      // Reapply through CSSOM, as with useStaggerReveal, for the strict CSP.
      const css = node.getAttribute('style');node.removeAttribute('style');if (css) node.style.cssText = css;
    }
    backdrop.setAttribute('aria-hidden','true');backdrop.inert = true;
  }
  return { bounds:{ x:rect.x,y:rect.y,width:rect.width,height:rect.height },radius:style.borderRadius,background:style.backgroundImage !== 'none' ? style.backgroundImage : style.backgroundColor,color:style.color,icon:icon || null,element,backdrop:backdrop || null,backdropBounds:content?.getBoundingClientRect() || null };
}

/** Per Nuxt app; presentation state is never serialized into the SSR payload. */
export function createOriginTransition(actor:()=>string|null = () => null) {
  const pending = shallowRef<string|null>(null), busy = shallowRef(false);
  let player:OriginPlayer|undefined;
  let record:{ source:OriginSource;from:string;to:string }|null = null;
  let local:OriginSource|null = null;
  const reduced = () => window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  return {
    pending:readonly(pending),busy:readonly(busy),
    setPlayer(value:OriginPlayer|undefined) { player = value; },
    async open(element:HTMLElement, action:()=>Promise<unknown>|unknown, options:{ from:string;to:string;current?:()=>string }) {
      if (busy.value) return false;
      if (reduced() || !player) { await action(); return true; }
      const source = capture(element),identity = actor(); busy.value = true; pending.value = options.to;
      try {
        const result = await action();
        // Navigation failures and cancelled dirty-form guards do not animate.
        if (result === false || actor() !== identity || (options.current && options.current() !== options.to)) return false;
        await nextTick();
        // Nuxt commits the route before the new page's Suspense boundary mounts.
        // Let that mount settle before attaching the surface to its shell.
        await new Promise<void>(resolve => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
        if (actor() !== identity) return false;
        if (reduced()) return true;
        await player(source,false);
        if (actor() !== identity || (options.current && options.current() !== options.to)) return false;
        const returnSource = { ...source,backdrop:null,backdropBounds:null };
        if (options.from !== options.to) record = { source:returnSource,from:options.from,to:options.to };
        else local = returnSource;
        return true;
      } finally { pending.value = null; busy.value = false; }
    },
    async closeLocal(action:()=>Promise<unknown>|unknown) {
      if (busy.value) return;
      const source = local; local = null;
      const result = await action(); if (result === false) { local = source; return; }
      if (!source || reduced() || !player) return;
      busy.value = true;
      try { await nextTick(); await player(source,true); } finally { busy.value = false; }
    },
    async routeChanged(to:string,from:string,failed:boolean) {
      if (busy.value || failed) return;
      local = null;
      if (!record || record.from !== to || record.to !== from) { record = null; return; }
      const source = record.source; record = null;
      if (reduced() || !player) return;
      busy.value = true;
      try { await nextTick(); await player(source,true); } finally { busy.value = false; }
    },
    clear() { record = null; local = null; pending.value = null; },
  };
}
