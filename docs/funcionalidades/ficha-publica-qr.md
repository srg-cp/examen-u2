# Ficha pública QR

Migración17/10/2026 en feature/vue-nuxt-web: Vue/Nuxt/TypeScript sustituye
la vista DOM y HTTP manual, manteniendo proyección, /c/<token>, API y fotos.
Primera lectura SSR con entidad permitida e hidratación sin segunda consulta;
componentes Vue compartidos, nonce CSP y estado por petición. Sin SQL nuevo.
Usuario confirma022/023 aplicados y recorrido QR funcionando en versión previa;
la migración Vue sigue local hasta publicación/redeploy. [ADR-058](../decisiones/058-web-unica-vue-nuxt-y-roles.md),
[guía Vue](../../apps/public-web/DESARROLLO.md). Landing, login/admin web e integración
HU-10 siguen fuera de este incremento.

HU-09 / RF-09 / issue #9. Incremento local del16 de octubre de2026 en
`feature/public-qr-case-web`. Consulta implementada; historia abierta por
integración HU-10.1 y validación/activación remota pendientes.

## Recorrido y campos

El QR de HU-08 abre `https://entrehuellas.kormind.com/c/<token>` sin instalar
la app ni iniciar sesión. Activo:1–3 fotos procesadas seleccionadas, nombre
cuando existe, especie/detalle/tamaño/sexo disponibles, rasgos, fecha,
zona pública aproximada y estado. Galería glass, compartir/copia real y
actualización manual; consulta cada60s visible/al volver a la pestaña.
El enlace externo de área usa solo coordenadas públicas redondeadas.

Cerrado: mensaje y fecha real del evento cuando existe, sin fotos/ficha privada
ni motivo inventado. Revocado, inexistente y eliminado: mismo estado neutral.
No hay formulario ni CTA ficticia: HU-10.1/#36 lo incorporará.

## Persistencia y permisos

Reutiliza tokens opacos64hex de022. No modifica casos. Fuentes080–082/plan023:
lector solo service_role y revocación solo autor autenticado; tablas/Storage
siguen privados. El navegador consulta al servidor Node, que filtra DTO y
sirve fotos por índice tras comprobar vigencia dos veces. No devuelve claves,
propietario/contacto, referencia privada, coordenadas exactas ni paths Storage.
Revocar es idempotente y no reactiva enlaces; actualmente es RPC sin nueva UI.

## Errores y reintentos

Skeleton inicial; shimmer sobre contenido conservado al actualizar. Fallos y
resultados en toast superior con reintento real, cierre/temporizador; compartir
cancelado es silencioso. Consultas repetidas se deduplican y se descartan
respuestas de rutas anteriores. Un fallo de red conserva ficha; cierre/revocación
confirmados la retiran. Copias descargadas/impresas no se revocan retroactivamente.

## Dependencias y activación

Preparación Dokploy17/10/2026: [guía GitHub→VDS](../../apps/public-web/DOKPLOY.md),
Dockerfile multietapa/runtime no root, contexto permitido por .dockerignore,
healthcheck y CI de build/arranque sin secretos reales. El usuario completará
Environment. No configura automáticamente su panel, DNS, SQL ni publica la rama.

Node22+, Supabase001–023 y pipeline de rendiciones; secreto solo servidor,
HTTPS en el dominio elegido y proxy sin caché ni logs de tokens. Límites por
IP/concurrencia por proceso. [README](../../apps/public-web/README.md),
[ADR-057](../decisiones/057-ficha-qr-web-y-proxy-privado.md).
PUBLIC_CASE_WEB_READY sigue false hasta comprobar hosting/lectura real.

## Validación pendiente

Resultados locales de Node, SQL/PostGIS y revisión Chrome en [ESTADO](../ESTADO.md).
Pendientes: aplicar023, Supabase/Storage real, DNS/TLS/proxy, segundo teléfono
sin app/Safari, QR impreso, cierre/revocación reales y límites con varias réplicas.
No se publica ni habilita generación de PDFs en este incremento.
