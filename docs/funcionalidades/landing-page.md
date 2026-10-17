# Landing pública en la plataforma

Integración solicitada17/10/2026, sin HU/RF/issue nuevos asignados. / en
apps/platform, Vue/Nuxt/TypeScript; [ADR-060](../decisiones/060-landing-integrada-en-platform-vue.md).
Proviene del trabajo de feature/landing-page, conservado sin modificar allí.

## Qué hace y recorrido

Presenta Entre Huellas con header/anclas, hero, personajes, propósito, cuatro
pasos, oportunidad, comunidad, colaboración, beneficios, FAQ, cierre y footer.
Mantiene composición y contenido aprobados, con siete ilustraciones independientes
generadas con imagegen y componentes Vue/CSS/SVG reales, sin capturas por debajo. CTA enlazan secciones existentes. FAQ nativo
exclusivo, operable con teclado y sin JavaScript. Responsive/movimiento reducido.

## Reglas, campos y persistencia

Página informativa sin campos ni envíos. No añade SDK/consultas Supabase, usuarios
simulados, estadísticas, contacto, descargas ni autenticación ficticios. No guarda
datos personales, sesión o cookies de usuario. Las fichas /c/<token> siguen siendo
la funcionalidad HU-09 independiente en rutas, dentro del mismo proyecto/despliegue.

Paleta institucional aislada de QR/app. Cinco PNG RGBA de1254×1254 y dos de1774×887,
con carga diferida salvo hero. LandingCharacterCard contiene tarjetas/etiquetas/
decoraciones HTML/SVG y LandingArt consume assets independientes sin atlas ni
offsets de captura. Logo oficial /brand.png en header/footer y hero aprobado
conservado con los mismos tiempos/movimiento reducido. CSP sin cambios. Prompts
y procedencia en apps/platform/LANDING_ASSETS.md. La raíz es
indexable con título/description/canonical/social; sitemap solo raíz, robots
excluye QR/API/rutas privadas y el servidor mantiene noindex fuera de la raíz.

## Errores y reintentos

Sin operaciones remotas ni loaders/toast artificiales. Fallos de entrega se
reintentan recargando en navegador; no existe confirmación de producto inventada.
Sin instalar la app ni ejecutar JavaScript se puede leer el contenido y usar FAQ.

## Activación y validación

Mismo Dockerfile/contexto apps/platform, stage runtime y puerto5173 de Dokploy.
No nuevas variables ni SQL. Publicar código y redeploy para ver la landing en el
dominio; no hace falta cambiar enlaces de QR. Node24/npm según guía de plataforma.
Landing puede renderizarse sin configurar Supabase; los casos sí lo necesitan.

Pruebas/tipos/build/QA locales y evidencia en [ESTADO](../ESTADO.md). Capturas en
apps/mobile/build/ui-preview/landing-vue; QA de enlaces, FAQ, indexación, ausencia
de llamadas de producto, CSP, variantes responsive/texto200% y aislamiento SPA.
Pendientes: revisión del usuario, Safari/Firefox, publicación y Search Console.
No se afirma posicionamiento real ni integración de login/administración web.
