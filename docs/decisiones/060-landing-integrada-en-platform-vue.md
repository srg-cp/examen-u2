# ADR-060 — Landing integrada en la plataforma Vue/Nuxt

Fecha:17 de octubre de2026. Decisión: aceptada por solicitud del usuario.
Alcance: ampliación de presentación pública, sin HU/RF/issue nuevos asignados.
Complementa ADR-058/059; no sustituye contratos ni privacidad de HU-09.

## Contexto y decisión

La landing creada en feature/landing-page tenía Next/React y trabajo sin confirmar
en su propio worktree. El usuario pide integrarla en la web única Vue/Nuxt.
Se portan composición, textos, iconos y ventanas de ilustración a componentes Vue
en apps/platform/app/features/landing, y / pasa de neutral a página de presentación.
No se incorpora un segundo runtime Next ni se modifica el worktree de origen.
No se mezclan sus instrucciones/documentos antiguos de arquitectura con los vigentes.

La referencia visual de esta landing es el mockup aprobado del11 de octubre:
crema, lima/celeste y composición de personajes. Es una excepción deliberada de
presentación institucional; no modifica el diseño de QR, acceso o app móvil.
CSS se limita a .landing-page y el CSS del lector a .reader-shell. Componentes
propios de marca/acciones/ilustración se reutilizan dentro de esta composición.
Ventanas CSS reproducen las ilustraciones del raster autorizado; textos/FAQ
siguen siendo HTML, no una captura de pantalla. Resolución limitada por la fuente.

## Renderizado y seguridad

Se usa SSR de Nuxt para entregar HTML indexable con metadatos/canonical. El
contenido es estático en producto, pero no se exporta como otra app estática:
se sirve con el mismo proceso Nitro y nonce CSP por respuesta. Sin API de
producto, sesión, cookies de usuario ni lectura Supabase para mostrar la landing.
No prerender/ISR/caché compartido en este incremento; se conserva no-store.
Las ventanas de ilustración usan clases CSS fijas, sin style inline ni relajar CSP.

Solo / permite indexación. /c/<token>, /api y las rutas privadas conservan noindex;
robots.txt excluye fichas/API/app/admin y sitemap.xml contiene únicamente la raíz.
Los metadatos sociales no exponen mascotas ni datos privados. Canonical al dominio
acordado entrehuellas.kormind.com, sin crear enlaces o contactos inventados.

## Consecuencias y validación

FAQ nativo usable sin JavaScript y con teclado; anclas reales, sin botones de
descarga/registro falsos ni cifras de producto inventadas. Desarrollo Android
se informa conforme a la landing original. Login web/admin/HU-10 siguen pendientes.
No hay SQL, nuevas variables, dependencias ni cambios en Flutter.

Validar tipos, unitarias/fronteras, build/servidor compilado, SSR sin consultas de
producto, robots/canonical, navegación, FAQ y regresión de QR. Revisión de renders
1440/731/390/320px, texto200%, movimiento reducido y navegación SPA en ambos
sentidos para comprobar que no se mezclan estilos. Resultados en ESTADO.
La evidencia local no certifica Safari/Firefox, posicionamiento ni un redeploy.
