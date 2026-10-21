<script setup lang="ts">
</script>

<template>
  <nav class="user-navigation" aria-label="Navegación de usuario">
    <div class="user-navigation-capsule">
      <NavigationLink to="/inicio" class="user-navigation-item" title="Inicio">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="m3 10 9-7 9 7v10a1 1 0 0 1-1 1h-5v-7H9v7H4a1 1 0 0 1-1-1Z" stroke-linejoin="round" /></svg>
        <span>Inicio</span>
      </NavigationLink>
      <NavigationLink to="/explorar" class="user-navigation-item" title="Explorar">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><circle cx="12" cy="12" r="9" /><path d="m16 8-3 5-5 3 3-5Z" stroke-linejoin="round" /></svg>
        <span>Explorar</span>
      </NavigationLink>
      <NavigationLink to="/mis-mascotas" class="user-navigation-item" title="Mis mascotas">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><ellipse cx="6" cy="8" rx="2" ry="3" transform="rotate(-25 6 8)" /><ellipse cx="18" cy="8" rx="2" ry="3" transform="rotate(25 18 8)" /><ellipse cx="10" cy="5" rx="1.5" ry="2.5" /><ellipse cx="14" cy="5" rx="1.5" ry="2.5" /><path d="M12 12c-3 0-7 5-5 7 1 2 3 0 5 0s4 2 5 0c2-2-2-7-5-7Z" /></svg>
        <span>Mis mascotas</span>
      </NavigationLink>
    </div>
    <NavigationLink to="/reportar" class="user-navigation-report" aria-label="Reportar" title="Reportar">
      <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><circle v-for="n in 9" :key="n" :cx="4 + ((n - 1) % 3) * 8" :cy="4 + Math.floor((n - 1) / 3) * 8" r="2.2" /></svg>
    </NavigationLink>
  </nav>
</template>

<style scoped>
.user-navigation{position:fixed;z-index:10;inset-inline:16px;bottom:calc(16px + env(safe-area-inset-bottom,0px));width:max-content;max-width:calc(100% - 32px);margin-inline:auto;display:flex;align-items:center;gap:12px}
.user-navigation-capsule{display:flex;min-width:0;padding:6px;border:1px solid #fff;border-radius:999px;background:#ffffffeb;box-shadow:inset 0 1px 2px #fff,0 6px 24px #3c537b14}
.user-navigation-item{display:flex;flex:1;flex-direction:column;align-items:center;justify-content:center;gap:3px;min-width:88px;min-height:52px;padding:8px 18px;border-radius:999px;text-decoration:none;color:#65656c;transition:background .2s ease,color .2s ease,transform .2s ease}
.user-navigation-item[aria-current=page]{color:#fff;background:linear-gradient(180deg,#75bfff 0%,#459ff6 48%,#2887ef 100%);box-shadow:inset 0 1px 2px #ffffff80,0 7px 20px #2887ef40}
.user-navigation svg{display:block;width:24px;height:24px;flex-shrink:0}
.user-navigation-item span{font-size:.75rem;line-height:1.25;text-align:center;overflow-wrap:anywhere}
.user-navigation-report{display:grid;place-items:center;flex-shrink:0;width:64px;height:64px;border-radius:50%;background:#111;color:#fff;text-decoration:none}
.user-navigation-report[aria-current=page]{background:linear-gradient(180deg,#75bfff,#2887ef);box-shadow:0 7px 20px #2887ef40}
@supports(backdrop-filter:blur(16px)){.user-navigation-capsule{background:#ffffffb8;backdrop-filter:blur(20px) saturate(1.3)}}
@media(hover:hover) and (pointer:fine){.user-navigation-item:hover{background-color:#edf5fa}.user-navigation-item[aria-current=page]:hover{transform:translateY(-2px)}.user-navigation-report:hover{filter:brightness(1.15)}}
@media(max-width:600px){.user-navigation{width:calc(100% - 32px)}.user-navigation-capsule{flex:1}.user-navigation-item{min-width:0;padding-inline:8px}.user-navigation-item span{position:absolute;width:1px;height:1px;padding:0;overflow:hidden;clip-path:inset(50%);white-space:nowrap}}
@media(max-width:360px){.user-navigation{gap:8px}.user-navigation-report{width:56px;height:56px}}
@media(prefers-reduced-motion:reduce){.user-navigation-item{transition:none}.user-navigation-item[aria-current=page]:hover{transform:none}}
</style>
