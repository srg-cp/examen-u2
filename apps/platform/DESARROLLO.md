# Tu primera ejecución en Vue/Nuxt

## Incremento HU-14.3: administración solo web

/moderacion utiliza acceso real y roles de servidor, sin equivalente Flutter.
Añadir las variables nuevas de .env.example a tu entorno local existente, sin
sobrescribirlo: SUPABASE_PUBLISHABLE_KEY y MODERATION_SESSION_SECRET aleatorio
(mínimo32 caracteres). PUBLIC_WEB_ORIGIN debe coincidir exactamente con el
origen del navegador. Aplicar030 completo y asignar cuenta revisora explícita
según CONFIGURACION;029 ya está confirmado y no se reaplica. No guardar claves
reales en archivos versionados. Cookie Secure con HTTPS, HttpOnly/SameSite Strict;
expira como máximo en una hora, sin refresh token.

QA: npm test incluye moderación/arquitectura; npm run test:server incluye acceso,
CSRF/cookie/SSR/proxy/reintentos con fixture. scripts/check-moderation-browser.mjs
requiere PLAYWRIGHT_MODULE/CHROME_PATH y build actual. No realiza cambios remotos.


Antes de implementar o revisar UI web, leer
[REGLAS_UI_UX_WEB](../../docs/REGLAS_UI_UX_WEB.md): la landing final aprobada el
18/10/2026 es la base visual común para público, usuarios y administración.
Conservar fronteras arquitectónicas y adaptar componentes con uso real;
la adopción documental no significa que el QR ya esté migrado visualmente.

No instalar Vue/Nuxt globalmente. Sus versiones y las dependencias están fijadas
en package.json/package-lock.json. Node24.15+ recomendado; ver engines para rangos
admitidos. Node24.18.0 y npm11.16.0 ya están instalados en el equipo del proyecto.
En VS Code, la extensión opcional **Vue - Official** proporciona ayuda con .vue;
evitar activar simultáneamente Vetur sobre estos archivos.

Desde apps/platform:

```powershell
npm ci
Copy-Item .env.example .env
npm run dev
```

Copiar el ejemplo solo si no tienes .env; no sobrescribir credenciales existentes.
Completar SUPABASE_URL y SUPABASE_SERVER_KEY con las mismas variables del servidor
Dokploy. No usar las claves de supabase.local.json del cliente Flutter como clave
de servidor. Nuxt dev muestra http://127.0.0.1:5173. Abrir /c/<token-real> para ficha;
/ muestra la landing y /c/<token> inválido conserva neutral. No se registran
tokens ni se incluyen casos demo. La landing no necesita credenciales para leerse.

Si utilizas .env.local, iniciar con `npm run dev -- --dotenv .env.local` para
seleccionarlo explícitamente. No renombrar ni sobrescribir ese archivo. En Dokploy
siguen usándose las variables del contenedor; .env.local no entra en la imagen.

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

HU-10.1: aplicar024 en desarrollo después de023 antes de probar envíos reales.
PUBLIC_WEB_ORIGIN limita POST al origen exacto: `https://entrehuellas.kormind.com`
en producción, o el origen local del dev server si no se configura. No terminar
con slash. Navegador no recibe clave de servidor ni rutas/evidencia privada.
Ver [avistamientos web](../../docs/funcionalidades/avistamientos-web.md).

`scripts/check-sightings-browser.mjs` ejecuta navegador con backend/teselas
fixture. Requiere PLAYWRIGHT_MODULE (ruta absoluta al módulo) y CHROME_PATH.
Produce capturas en apps/mobile/build/ui-preview/public-sightings y no realiza
escrituras remotas. El build aislado acepta NUXT_BUILD_DIR; por ejemplo
`.nuxt-hu10-qa` con NUXT_IGNORE_LOCK=1 evita compartir artefactos con el dev server.
Se excluyen estos directorios de Git. No detener el servidor del usuario para QA.

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

## Login separado

/login es el acceso para cuentas revisoras existentes. /moderacion sin sesión
redirige después de hidratar; cookie API/permiso servidor conservados. No existe
registro web ni asignación automática de rol. check-login-browser.mjs valida
redirecciones, roles, caducidad, pestañas, reintento y responsive con fixtures;
requiere PLAYWRIGHT_MODULE/CHROME_PATH y build vigente, igual que moderación.

Google/Facebook: POST /api/moderation/oauth/start y GET callback PKCE en servidor.
Misma configuración de moderación, más allowlist web en Supabase según
docs/CONFIGURACION. check-login-browser.mjs recorre ambos proveedores mediante
fixture, sin contactar Google/Facebook reales. Formulario estable, sin skeleton
inicial ni texto de cuentas autorizadas.
