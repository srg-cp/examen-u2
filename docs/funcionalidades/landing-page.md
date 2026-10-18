# Landing pública en la plataforma

Integración solicitada17/10/2026, sin HU/RF/issue nuevos asignados. / en
apps/platform, Vue/Nuxt/TypeScript; [ADR-060](../decisiones/060-landing-integrada-en-platform-vue.md).
Proviene del trabajo de feature/landing-page, conservado sin modificar allí.

## Qué hace y recorrido

Presenta Entre Huellas con header/anclas, hero, personajes, propósito, cuatro
pasos, oportunidad, comunidad, colaboración, beneficios, FAQ, cierre y footer.
Mantiene composición y contenido aprobados, con diez ilustraciones independientes
generadas con imagegen y componentes Vue/CSS/SVG reales, sin capturas por debajo. CTA enlazan secciones existentes. FAQ nativo
exclusivo, operable con teclado y sin JavaScript. Responsive/movimiento reducido.

## Reglas, campos y persistencia

Página informativa sin campos ni envíos. No añade SDK/consultas Supabase, usuarios
simulados, estadísticas, contacto, descargas ni autenticación ficticios. No guarda
datos personales, sesión o cookies de usuario. Las fichas /c/<token> siguen siendo
la funcionalidad HU-09 independiente en rutas, dentro del mismo proyecto/despliegue.

Paleta institucional aislada de QR/app. Diez PNG RGBA con dimensiones nativas documentadas,
con carga diferida salvo hero. LandingCharacterCard contiene tarjetas/etiquetas/
decoraciones HTML/SVG y LandingArt consume assets independientes sin atlas ni
offsets de captura. Logo oficial PNG actualizado en header/footer y favicon; SVG completo disponible y hero aprobado
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

Diversidad17/10: corgi, dálmata, atigrado, spaniel, mestizo/calicó y parejas de
retriever/gris y beagle/blanco-negro, además de pastor/ragdoll. Pañuelos de colores
con only-black.svg reproducido en blanco por imagegen dentro del tejido del PNG,
sin superposición SVG/CSS. Se conservan interfaz, CTA y animación aprobados.

Acabado17/10: por corrección explícita del usuario, los PNG se editan con
imagegen para retirar el perfil oscuro y la iluminación de borde anaranjada.
Las tres referencias aportadas fijan pelaje natural, detalle fino y luz difusa
neutra, sin halo de color ni desenfoque global. Mantener razas, estampados y
escenas; revisar archivos sobre fondos claros/oscuros y detalle al100%, además
de la composición real. Prompts y procedencia en LANDING_ASSETS.md; evidencia y
límites de comprobación en ESTADO. Sin cambios de funcionalidad o persistencia.

Revisión posterior del usuario: los primeros suavizados no resuelven el acabado.
Priorizar hebras definidas y silueta formada por pelo, según gatito-curioso.png;
no aceptar una franja luminosa, oscura o desenfocada. Se calibró primero un PNG
de dálmata y se integraron después diez PNG seleccionados, revisados en fondos
claros/oscuros y en Chrome responsive. Build y QA de esta pasada registrados en
ESTADO; integración verificada y aprobación artística final del usuario pendiente.

El usuario rechazó también esa última pasada: identifica una franja gris sobre
pelo blanco en la oreja del dálmata. La corrección artística global sigue pendiente.
Se preparó una muestra fuera del público que retira ese sombreado y reconstruye
hebras claras; comparar landing-white-fur-ear.png y resolver su revisión visual
antes de nuevos reemplazos en bloque. No confundir build/QA con aceptación de arte.

La muestra también fue rechazada. Diagnóstico de solo lectura de color/alfa en
ESTADO; no se continúa extrapolando generaciones. Pendiente elección del usuario
sobre probar tratamiento localizado del PNG conservando el detalle existente.

Nueva referencia explícita: hero-bienvenida.png original, especialmente los
mechones y volumen de la cola. Se prueba esa fuente transparente con una edición
imagegen limitada a estampados; muestra/comparación en ESTADO. No se ha aplicado
la alternativa manual ni se ha resuelto todavía el conjunto de ilustraciones.

Las dos nuevas pruebas desde el master y de neutralización con imagegen también
fueron rechazadas por contorno/luminosidad y pérdida de pelo en cola. No se han
integrado ni extrapolado al resto. La corrección visual global sigue sin resolver;
los checks de web no acreditan cumplimiento de ese acabado.

Pasada posterior del 17/10: sustituido el dálmata público por la edición ImageGen
`exec-e5839c84-0e7b-46ec-8087-e9bfc66c8f4c.png`, PNG transparente de 1254×1254,
sin retoques posteriores. Revisión visual de oreja y cola al tamaño nativo sobre
gris: menor halo, pelo negro continuo en su borde y hebras de cola conservadas.
Emblema blanco integrado en el pañuelo naranja. Build comprobado. La aceptación
artística del usuario y revisión de los otros ocho recursos siguen pendientes.

Corrección siguiente: el usuario rechazó e5839c84 por sombreado en mejilla.
Sustituido por `exec-228f74fc-9ac3-428c-89de-5a5f1d1932bc.png`, generado
directamente desde su referencia del 7 de octubre y emblema oficial. Dimensiones
nativas 1312×1199. La tarjeta del dálmata usa contain para no cortar su cola
completa; antes heredaba cover. Aceptación artística pendiente.
Build y QA responsive de esta sustitución pasados: registros
landing-dalmatian-reference-build.log y landing-dalmatian-reference-browser.log
en apps/mobile/build; captura de tarjetas confirma cola visible entera.
