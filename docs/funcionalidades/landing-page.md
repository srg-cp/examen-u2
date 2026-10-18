# Landing pública en la plataforma

**Radio unificado17/10:** todos los botones de landing comparten cápsula999px,
incluidos secundarios/lima y tamaños tablet/móvil. Se conserva estilo cromático
de cada acción y control circular. Validación responsive y build en ESTADO.

**Botones/ilustración17/10:** por referencias del usuario, acciones azules de
cabecera/cierre ahora son cápsulas con brillo superior, degradado azul/celeste,
texto blanco y sombra. Botones lima aprobados conservados. dog-report.png
recreado con imagegen para eliminar la pata extra del perro, preservando PNG
transparente1312×1199, personajes y emblemas; actualizado en ambos usos. Evidencia
glossy-buttons/report-anatomy, procedencia en LANDING_ASSETS y validación en ESTADO.

**Corrección de fondos17/10:** restaurada la generación y cobertura de la capa
.aurora::before eliminada accidentalmente al consolidar colores. Hero original
y cierre azul vuelven a pintarse. QA navegador ahora comprueba que las capas
existan y cubran ambas secciones, además del gradiente. Build/QA aprobados y
capturas revisadas; evidencia aurora-fix en ESTADO. Sin despliegue.

**Corrección4/5/6 del17/10:** oportunidad, comunidad y colaboración restauran
sus colores de fondos/botones/números/etiquetas originales. Por rectificación
explícita, «Una huella tuya» conserva la paleta azul nueva. Geometría y recursos
intactos; sin reintroducir pines02/03. Build/QA en ESTADO, evidencia sections-original.

**Propósito17/10:** numeración01–04 con color original171918 por solicitud del
usuario. Retirados los pines CSS morados y decoración asociada de pasos02/03;
PNG/fondos/encuadres conservados. Build y QA responsive en ESTADO, evidencia
steps-cleanup. Sin publicación.

**Corrección posterior17/10:** el hero vuelve a la paleta original completa,
incluidos gradiente, botones, badge, valores y fondos de mascotas. El resto
conserva la paleta azul nueva; geometría y animación intactas. Build/QA y
renders hero-original-colors en ESTADO. Sin publicación.

**Paleta azul autorizada17/10:** primario3C537B/blanco, secundarioB5D5E9/azul,
acentos2C87CE; fondos celeste/azul/lavanda y verde suave residual. Se conserva
crema, mascotas, geometría y movimientos aprobados. Variables compartidas en
landing.css; botones primary/secondary por función. Cambios solo de presentación,
sin operaciones, permisos o rutas nuevas. Regla/decisión actualizadas en UI/ADR-060.
Build, tipos,9 pruebas y QA responsive/200%/SSR/QR aprobados; contrastes de
acciones AA, capturas revisadas y valoración del usuario pendiente. Evidencia
blue-palette en ESTADO. No publicado.

**Ajuste tras aprobación17/10:** margen superior del pie reducido a24–48px
(3vw), conservando texto entre mascotas y encuadre/tamaños aprobados. Nueva
exportación del logo sincronizada en landing/QR/favicon. Build y QA responsive
en ESTADO; evidencia footer-gap-logo. Sin despliegue.

**Encuadre final del pie17/10:** por aclaración del usuario, texto entre las
mascotas en escritorio, centrado con elevación20–40px y ancho36%; imágenes39%
sin recorte y cerca de los laterales. Sustituye el contenido en fila superior
del ajuste anterior. Móvil conserva distribución en dos filas y figuras50%.
Cierre alto conservado. Build/QA y capturas footer-centered en ESTADO.

**Corrección posterior17/10:** el usuario solicita conservar el tamaño original
de las mascotas del pie. Ancho39% cada una en escritorio y50% en móvil; fila
natural completa debajo del contenido para evitar recorte y cruces. Se mantiene
la altura ampliada del cierre. Sustituye el escalado reducido del ajuste previo.
Build y geometría responsive aprobados; evidencia footer-original-size en ESTADO.

**Pie y cierre17/10/2026:** mascotas completas en columnas laterales sin
recorte ni superposición con enlaces. Contenido central alineado arriba; móvil
coloca las mascotas en una segunda fila. Cierre «Una huella tuya» con altura
mínima420–640px (440px móvil) y contenido centrado. Sin recursos ni operaciones
nuevas. Build SSR y QA responsive/200%/FAQ/anclas/no-JS/CSP/hidratación/QR
aprobados; geometría sin cruce/recorte verificada en1920/1440/731/390/320px
y texto ampliado. Renders revisados; pendiente valoración del usuario,
sin despliegue. Evidencia landing-footer-* en apps/mobile/build.

**Títulos y comunidad17/10/2026:** los siete h2 de sección comparten la escala
de propósito mediante --section-title-size (hasta58px; móvil34px), sin alterar
el h1 del hero. Imagen de comunidad con ventana305:160 frente a305:123 anterior
(aprox.30% más alta), conservando PNG y contain. Anchos, márgenes y onda intactos.
Build SSR y QA responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados;
igualdad de fuentes/proporción comprobada hasta1920px y capturas revisadas.
Logs landing-heading-scale-*.log en apps/mobile/build. Pendiente valoración
visual del usuario; sin publicación, cambios de datos ni cierre de historias.

**Onda viajera17/10/2026:** referencias del usuario requieren una curva amplia
que recorra las tarjetas. Ciclo6s, doce fases progresivas cada0.5s y amplitud
24–56px. Seis personajes repetidos dos veces por grupo; copias decorativas,
sin duplicar mensajes accesibles. Dos grupos equivalentes y avance120s conservan
velocidad horizontal previa y continuidad de onda en la unión. Pausa horizontal,
movimiento reducido, dimensiones y márgenes conservados. Build SSR y QA
responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados; muestreo confirma
propagación, continuidad y velocidad conservada. Capturas revisadas; logs
landing-traveling-wave-*.log en apps/mobile/build. Pendiente revisión del usuario,
sin publicación ni nuevas historias.

**Espacio y onda17/10/2026:** margen adaptable40–88px tras propósito y entre
secciones posteriores/pie, conservando el espacio previo de la tercera sección.
Onda vertical6s, seis fases cada1s y curva suave; avance horizontal60s, amplitud,
arte, marcos, pausa horizontal y movimiento reducido conservados. Build SSR y
QA responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados; espacios medidos
en1920/1440/731/390/320px y continuidad de onda comprobada. Capturas revisadas.
Evidencia landing-spacing-wave-*.log en apps/mobile/build; pendiente revisión
visual del usuario, sin publicación, cambios de permisos ni nuevas historias.

**Ancho global17/10/2026:** por petición del usuario, todas las secciones,
cabecera y pie comparten el ancho aprobado de hero/propósito mediante `.wrap`,
sin máximo1280px y con margen móvil14px conservado. Diseño, arte y movimientos
conservados. Diez contenedores alineados en1920/1440/731/390/320px, sin overflow;
build SSR y QA responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados.
Capturas escritorio/móvil revisadas; logs landing-sections-width-*.log en
apps/mobile/build. Pendiente revisión del usuario, sin publicación ni nuevas HU.

**Ajuste de tercera sección17/10/2026:** el panel blanco de «Una comunidad con
un propósito» comparte ancho/márgenes del hero sin máximo1280px; cuatro imágenes
con ventanas3:1 en lugar de3.6:1 (20% más altas a igual ancho). Se conservan
recursos y movimientos. Build SSR y QA responsive/200%/no-JS/CSP/hidratación/QR
pasados; comprobación adicional de alineación con hero hasta1920px y capturas
escritorio/móvil revisadas. Logs landing-purpose-*.log en apps/mobile/build.
Servidor dev existente reutilizado; pendiente aprobación visual del usuario.
Sin cambios de persistencia/permisos, publicación ni cierre de historias.

**Relevo vigente17/10/2026:** el usuario aprobó el diseño tras el último aumento
leve del marco. Para continuar en otro chat, leer [RELEVO_LANDING](../RELEVO_LANDING.md):
consolida el estado final y sustituye las soluciones intermedias de este historial.

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

### Colección desde el estilo aprobado —17/10/2026

El usuario aprobó el dálmata y autorizó completar e integrar las ocho variantes
restantes. Sustituidos dog-curious/cat/dog-wave/corgi/tabby/dog-report/pets-home/
pets-map con ImageGen, usando como referencias el dálmata y el emblema blanco.
Pañuelos variados con emblema integrado, PNG RGBA sin filtros posteriores.
Dimensiones nativas declaradas. Pareja original conservada y ampliada al 160 %
solo en la tarjeta Volvemos, centrada abajo. Animación principal conservada.
Prompts, referencias y procedencia: apps/platform/LANDING_APPROVED_STYLE.md.
Build SSR y QA Chrome responsive/texto200 %/SSR/no-JS/FAQ/teclado/anclas/CSP/
hidratación/aislamiento QR pasados; capturas desktop/mobile/characters revisadas.
Sin publicación. No equivale a cerrar una HU ni aprobar artísticamente cada PNG.

Petición posterior: recuperar exclusivamente las dos imágenes anteriores del
hero. Restauradas como hero-dog.png/hero-cat.png (1254×1254) con asignación
independiente; las imágenes nuevas del resto y Volvemos ampliado se conservan.
Build SSR y QA responsive/texto200 %/no-JS/QR pasados en esta restauración;
captura del hero revisada, sin cambio de animación ni despliegue.

Petición posterior: hero más grande, con título hasta78px, ilustraciones
hasta120px y mayor padding adaptable; móvil con tipografía y espacio propios.
Marca de cabecera/footer en minúsculas «entre huellas» y peso500, antes750.
Sin modificar el icono oficial ni el texto editorial o la marca de la ficha QR.
Build SSR y QA responsive/texto200 %/SSR/no-JS/QR pasados; capturas revisadas
y git diff --check sin errores. Evidencia landing-hero-size-*.log en build móvil.

Referencia posterior: hero ocupa la primera pantalla bajo cabecera, ancho casi
completo y min-height100svh descontando cabecera/margen; contenido centrado,
título hasta108px e imágenes hasta148px en escritorio. Móvil conserva escala
propia y crecimiento natural con texto ampliado. Marca/arte/animación intactos.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados; capturas revisadas.
Evidencia landing-fullscreen-hero-*.log en apps/mobile/build. Sin despliegue.

### Fila horizontal escalonada —17/10/2026

Tarjetas alternan altura y tienen64–100px de espacio vertical alrededor.
Dos grupos de seis completan ciclo horizontal de60s sin salto; la copia se
oculta a lectores de pantalla. Control pausa/reanudar, pausa al hover/foco y
fila estática con movimiento reducido. Carga anticipada solo de las tarjetas.
Dálmata145 % y pareja185 % para equilibrar presencia, sin cambiar los PNG.
Build y QA responsive/200 %/SSR/no-JS/QR pasados; movimiento entre frames,
pausa/reanudación y reducción de movimiento comprobados. Captura revisada.
Evidencia landing-character-drift-*.log en apps/mobile/build; sin publicación.

Revisión posterior solicitada: mayor margen32–64px y padding72–104px vertical,
etiquetas centradas y peso400. La onda sustituye alturas fijas: oscilación12s
con fases separadas2s por tarjeta, simultánea al avance horizontal60s. Grupos
duplicados mantienen fases iguales para el cierre continuo. Retirados botón y
pausas hover/foco según instrucción; movimiento reducido del sistema conservado.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados; comprobados movimiento
vertical/horizontal real, fases y continuidad durante hover. Captura revisada.
Evidencia landing-character-wave-*.log en apps/mobile/build; sin publicación.

Revisión posterior: marcos12–24px más anchos y48–72px más altos. Se conserva
el tamaño anterior de la ventana de arte, centrada abajo, y cada escala de mascota.
Botón cápsula inferior derecha con pausa/play y aria-pressed: detiene solo el
avance horizontal; la onda vertical sigue. Reanuda desde el mismo punto, sin
pausas hover/foco. Preferencia de movimiento reducido conservada.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados; comprobada pausa horizontal
con onda activa, reanudación y tamaño de imágenes conservado. Captura revisada.
Evidencia landing-card-frame-*.log en apps/mobile/build. Sin publicación.

Corrección posterior: control circular44×44 en la esquina superior derecha.
Todas las mascotas usan contain y se retiran zooms de pareja/dálmata para mostrar
las ilustraciones completas sin cortar orejas/patas/colas. Marcos conservados;
ajuste proporcional de arte sin editar PNG. Pausa solo horizontal y onda activa.
Build y QA responsive/200 %/SSR/no-JS/QR y verificaciones del encuadre/control
pasados; captura revisada. Evidencia landing-card-fit-*.log en apps/mobile/build.

Corrección posterior del usuario: recuperar el tamaño anterior de mascotas,
restaurando cover/pareja185 %/dálmata145 % sin reducir marcos. Control circular
superior derecho76×76, mismo ancho que la cápsula anterior; pausa solo horizontal.
Build y QA responsive/200 %/SSR/no-JS/QR pasados, incluida onda durante pausa.
Captura revisada; evidencia landing-restored-card-scale-*.log en build móvil.

Corrección de contenedor limitado: ventana y marco se amplían al ancho completo
de las mascotas grandes (factor1.45 individual/1.85 pareja), conservando altura
visual. Contain sin zoom/márgenes negativos en el PNG: sin recortes internos.
Tarjetas más anchas para alojar la ilustración. Control60px/icono28px superior;
margen40–72px y padding superior128–168px despejan el botón y bajan la fila.
Build SSR y QA responsive/200 %/no-JS/QR pasados, incluyendo altura conservada,
ventanas contenidas y separación del control. Captura revisada; evidencia
landing-unclipped-frames-*.log en apps/mobile/build. Sin publicación.

Corrección explícita posterior: se restaura ancho aprobado de tarjetas sin el
factor1.45/1.85. Esos factores permanecen solo en la ventana de arte, con overflow
visible para eliminar el corte interior; el marco redondeado exterior delimita
la ilustración. Botón/espacio/movimiento conservados. Build SSR y QA responsive/
200 %/SSR/no-JS/QR pasados, ancho y overflow interior comprobados, captura revisada.
Evidencia landing-inner-window-*.log en apps/mobile/build. Sin publicación.

Aumento leve posterior solicitado: solo marcos, aproximadamente+16px ancho y
24px alto en escritorio (+8/+12px móvil). Ventanas e imágenes conservan medidas
y escala; botón/onda/avance intactos. Build SSR y QA responsive/200 %/SSR/no-JS/
QR pasados; captura revisada. Evidencia landing-card-small-increase-*.log en build.
