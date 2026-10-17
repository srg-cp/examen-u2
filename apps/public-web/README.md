# Ficha pública QR — HU-09 / RF-09 / issue #9

Despliegue en el VDS del usuario: **[guía Dokploy desde GitHub](DOKPLOY.md)**.
Dockerfile listo para contexto apps/public-web, stage runtime y puerto5173;
variables solo en ejecución, healthcheck incorporado y CI de contenedor preparado.

Cliente ligero y servidor HTTP de lectura Node22+, sin dependencias de producción.
Ruta acordada: `https://entrehuellas.kormind.com/c/<token opaco de 64 hex>`.
Incremento local: no acredita publicación ni cierra HU-09. El formulario y la
recepción de avistamientos corresponden a HU-10.1/#36 y aún no existen aquí.

## Ejecución

Requiere backend con migraciones001–023 y pipeline de fotos operativo.
Copiar `.env.example` a `.env` local (ignorado por Git) y completar las dos
variables Supabase. Desde esta carpeta:

```powershell
npm run build
npm start
```

Abrir `http://127.0.0.1:5173/c/<token-real>`; sin token válido se muestra la
página neutral. No se crea una sesión ni se incluyen casos de demostración.
`npm test` reconstruye el cliente y ejecuta contratos, privacidad, HTTP, reintentos,
límites de solicitudes y fronteras. No necesita credenciales ni conexión Supabase.

QA visual reproducible con Playwright1.62.1 instalado fuera de producción:

```powershell
$env:PLAYWRIGHT_MODULE='C:/ruta/node_modules/playwright/index.js'
$env:CHROME_PATH='C:/Program Files/Google/Chrome/Application/chrome.exe'
node scripts/check-browser.mjs
```

Usa fixtures solo de prueba y el asset aprobado de onboarding; guarda capturas
en `flutter_application_entrehuellas/build/ui-preview/public-web`. No acredita
un QR físico, iPhone/Safari ni Storage real.

## Configuración y publicación pendiente

`SUPABASE_SERVER_KEY` es un secreto exclusivamente del proceso servidor. Acepta
`sb_secret_...` y el JWT antiguo con rol `service_role`; rechaza claves del cliente.
Las primeras se envían únicamente en `apikey`; las JWT también en Authorization,
según [la documentación de Supabase](https://supabase.com/docs/guides/getting-started/api-keys).
El navegador solo recibe entidades con campos permitidos y fotos por índice;
no recibe credenciales, UUID de propietario, paths privados ni URLs firmadas.

El servidor sirve exclusivamente el manifiesto de `dist`; nunca publicar el
checkout ni `.env` como raíz estática. Este proyecto necesita un proceso Node:
subir solo `dist` a hosting estático no implementa `/api/c/...`.
Dockerfile multietapa incluye solo fuentes necesarios y build público, corre sin
root e incluye healthcheck. .dockerignore excluye secretos/fixtures del contexto.
El workflow comprueba build/arranque del contenedor, sin desplegar. Ver DOKPLOY.md.

Publicar detrás de TLS en el dominio acordado, con todo `/` enviado a Node,
sin caché de CDN/proxy para HTML, API ni fotos. Mantener cabeceras CSP/no-store
y no registrar rutas `/c/` o `/api/c/` en logs/analytics: contienen tokens.
No añadir trackers. `HOST` predetermina loopback; para contenedor usar0.0.0.0.
`TRUSTED_PROXY_IPS` admite solo IPs exactas del peer que controla X-Forwarded-For;
el proxy debe reemplazarlo/anexar la IP real. Sin esa configuración, el límite
se aplica a la IP del proxy compartida, sin confiar en cabeceras del visitante.
Límite en memoria:60 peticiones/minuto/IP y64 operaciones concurrentes/proceso.
En múltiples réplicas se requiere un límite adicional en el proxy; no se añade Redis.

Activación en desarrollo antes de uso real:

1. Aplicar023 después de022 mediante el mecanismo SQL habitual, una sola vez.
2. Configurar el secreto en el servicio servidor y publicar Node/TLS.
3. Crear/obtener un enlace real autorizado con el contrato de carteles de022.
4. Desde otro teléfono sin app: probar caso activo y fotos, comparar zona pública,
   cerrar y comprobar retirada de fotos; revocar y comparar con token inexistente.
5. Verificar en red que no hay secretos, paths Storage ni referencias exactas;
   comprobar reintento offline, cabeceras y ausencia de caché del proxy.
6. Solo entonces habilitar `PUBLIC_CASE_WEB_READY=true` en Flutter. Permanece
   false en esta entrega. Integrar #36 antes de cerrar la historia completa.

La revocación es RPC autenticada `revoke_case_public_link(source,id)`, solo autor,
idempotente e irreversible para ese enlace. No se añade un botón nuevo a Flutter.
No revoca bytes ya descargados ni PDFs impresos; sí impide futuras lecturas.
Las pestañas visibles consultan de nuevo cada60s y al recuperar visibilidad;
también existe Actualizar estado. Sin canal en tiempo real.

## Límites de capas

`domain` valida entidades públicas y declara operaciones/contrato, sin DOM/Node/SDK.
`data` encapsula REST Supabase y HTTP del cliente, mapea DTO y normaliza fallos.
`presentation` contiene ViewModel/estado y vista DOM sin infraestructura.
`app` compone adaptadores, rutas, configuración y controles HTTP.
El build copia solo cliente/dominio/presentación/adaptador HTTP y assets explícitos.
La RPC privada devuelve descriptores Storage solo al servidor; este los valida,
descarga JPEG procesado y vuelve a comprobar estado/revocación antes de responder.
Una lectura anónima no amplía grants de tablas ni permisos Storage.
