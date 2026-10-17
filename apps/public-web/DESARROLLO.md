# Tu primera ejecución en Vue/Nuxt

No instalar Vue/Nuxt globalmente. Sus versiones y las dependencias están fijadas
en package.json/package-lock.json. Node24.15+ recomendado; ver engines para rangos
admitidos. Node24.18.0 y npm11.16.0 ya están instalados en el equipo del proyecto.
En VS Code, la extensión opcional **Vue - Official** proporciona ayuda con .vue;
evitar activar simultáneamente Vetur sobre estos archivos.

Desde apps/public-web:

```powershell
npm ci
Copy-Item .env.example .env
npm run dev
```

Copiar el ejemplo solo si no tienes .env; no sobrescribir credenciales existentes.
Completar SUPABASE_URL y SUPABASE_SERVER_KEY con las mismas variables del servidor
Dokploy. No usar las claves de supabase.local.json del cliente Flutter como clave
de servidor. Nuxt dev muestra http://127.0.0.1:5173. Abrir /c/<token-real> para ficha;
/ sin token conserva neutral. No se registran tokens ni se incluyen casos demo.

## Qué estás programando

Un archivo .vue puede contener `<script setup lang="ts">` para estado/acciones,
`<template>` para HTML y `<style>` para CSS. El estilo común está en app/assets.
Vue actualiza la pantalla al cambiar su estado reactivo. TypeScript ayuda a detectar
datos/operaciones incompatibles antes de ejecutar; no reemplaza validación servidor.

Nuxt sigue siendo Vue, con rutas y servidor integrados. app/pages/c/[slug].vue
corresponde a /c/<slug>. app/features contiene componentes y pantallas reales;
app/components comparte marca, botones, skeleton y toast. Los componentes consumen
ViewModel; no consultan Supabase directamente. App/plugins compone dependencias
por petición para que SSR no comparta estado de visitantes.

SSR entrega el contenido inicial del caso como HTML; Vue lo hidrata para acciones
sin volver a consultar al arrancar. Mapas/herramientas privadas podrán renderizar
en cliente cuando se implementen. Nuxt no exige SSR en todas las rutas.

Con Vue+Vite también sería posible; tendríamos que integrar por separado el
servidor de lectura y renderizado público. Elegimos Nuxt para una web con contenido
público, QR y zonas privadas futuras. No cambia Flutter ni las políticas SQL.

## Validación y producción

```powershell
npm run typecheck
npm test
npm run build
npm run test:server
npm start
```

Las pruebas no usan datos ni secretos reales. Para revisión visual con fixtures,
ver check-browser.mjs/README; Playwright solo es herramienta de QA local.
No copiar .env a public, no usar NUXT_PUBLIC para secretos y no añadir datos de
usuario a variables de módulo del servidor. La autorización futura se comprobará
en backend además de los guards de navegación.

Dokploy conserva contexto, puerto y variables; necesita los nuevos archivos y
package-lock publicados en la rama elegida. [Pasos](DOKPLOY.md). Esta migración
no realiza push ni redeploy automático sobre la web ya operativa.
