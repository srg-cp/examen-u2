# Inicio y navegación

20/10/2026, acabado vigente de accesos: Reportar/Mis reportes/Mis mascotas con
fondo negro #111111, iconos y texto blancos, peso600 original y sin refuerzo
de iconos. Tamaños compactos y destinos conservados; apertura de Reportar
parte del negro real. Sustituye el azul/gris de las notas anteriores. Sin
nuevos datos, permisos o activación. Formato/análisis limpios;11 comprobaciones
de arquitectura/captura aprobadas, normal y pequeño/texto2 sin overflow.
Captura normal revisada; pendiente revisión visual Android.

20/10/2026: Inicio también permite actualizar al jalar desde el borde superior
y soltar al alcanzar el umbral, con PullToRefresh/indicador glass compartidos.
Recarga el perfil real de cabecera; contenido editorial e ilustración fijos.
Router inyecta el callback del ViewModel de perfil; HomeViewModel coordina
duplicados, errores seguros y descarte al cambiar sección. Toast superior con
Reintentar; avatar conservado durante refresh de la misma cuenta. Explorar y
Mis mascotas mantienen sus callbacks propios. Sin nuevas tablas/permisos o
activación.14 pruebas de recarga/arquitectura y8 de perfil aprobadas, análisis
limpio. Pendiente gesto/consulta autenticada Android. Actualiza el alcance de
[ADR-048](../decisiones/048-actualizar-listas-al-jalar.md), sin cierre de HU.

20/10/2026, accesos vigentes: Reportar/Mis reportes/Mis mascotas usan texto700
y azul #2887EF en texto/iconos, con refuerzo horizontal de iconos0.25px por lado.
Conservan fondo gris, tamaños, destinos y ampliación. Sin nuevos datos, permisos
o activación. Formato/análisis limpios y11 comprobaciones de arquitectura/captura
aprobadas; renders normal/pequeño sin overflow, normal revisado. Android pendiente.

20/10/2026, título vigente tras nueva referencia: Poppins32 (antes26), primera
frase gris400 y segunda600 con degradado horizontal azul #459FF6→celeste #75C9EF.
Sin glass. ShaderMask solo en «empieza contigo»; ampliación, ajuste natural,
etiqueta accesible completa y stagger conservados. Sin nueva persistencia,
permisos o activación. Formato/análisis limpios;11 comprobaciones aprobadas,
renders390×844/texto1 y320×350/texto2 revisados sin overflow. Android pendiente.

20/10/2026, composición vigente: título «Su regreso empieza contigo» sin
glass, Poppins26 (antes23), mismos pesos/colores y ampliación del sistema.
La descripción «Una comunidad…» se muestra debajo del perro/gato en la misma
HomeReunionCard glass, conservando imagen3:2. Cerca de ti mantiene glass.
Sin nuevas reglas, permisos, persistencia o activación. Formato/análisis
limpios y11 comprobaciones de arquitectura/captura aprobadas; renders normal
y pequeño/texto2 revisados sin overflow. Pendiente revisión Android con imagen.

20/10/2026: «Explora cerca de ti» reutiliza GlassSurface/radio26 mediante
HomeNotice, igual que las otras tarjetas glass de Inicio. Conserva textos,
padding y acceso real a Explorar; entrada preserveBackdrop. El fallback que
usa HomeNotice comparte el acabado. Sin nueva persistencia, permisos,
dependencias o activación. Formato/análisis limpios y11 comprobaciones de
arquitectura/captura aprobadas; tamaños normal y pequeño/texto2 sin overflow.
Captura normal revisada; pendiente validación visual Android.

20/10/2026, ajuste posterior: se retiran la huella superior de la tarjeta
principal y «Conoce Mis mascotas». Los accesos Reportar/Mis reportes/Mis mascotas
conservan fondo gris #F5F5F7 y usan iconos/texto #459FF6 como el énfasis del título
(corrección explícita del usuario: el azul no corresponde al fondo);
padding vertical16, iconos25, separación10 y texto12.5. Mantienen destinos,
ampliación y columna adaptable; apertura de Reportar desde su color real.
Sin nuevas reglas de dominio, persistencia, permisos o activación.
Formato/análisis limpios y11 comprobaciones de arquitectura/captura aprobadas;
renders390×844/texto1 y320×350/texto2 revisados sin overflow. Captura aislada
del contenido; pendiente revisión visual Android.

20/10/2026: título principal con el estilo de la referencia del usuario:
Poppins local23/altura1.25; «Su regreso» gris/peso400 y «empieza contigo»
azul/peso600, con salto entre ambos. Aproximación tipográfica a la captura,
no identificación de su fuente. Ajuste natural con texto ampliado y frase
accesible completa. No requiere activación, persistencia o permisos nuevos.
[ADR-105](../decisiones/105-titulo-inicio-mobile-referencia-tipografica.md).
Validación: análisis limpio; captura específica390×844/texto1 y320×350/texto2
aprobada y revisada. Suite Home/arquitectura:15 pasan,2 timeout al esperar
el fin del fondo continuo; captura general también bloqueada por esa espera.
Pendiente revisión visual Android; evidencia completa en ESTADO.

Corrección posterior19/10/2026 del usuario: Reportar (nueve puntos) vuelve
a su IconButton circular negro #111111 original, de64px y puntos blancos,
sin degradado, brillo ni sombra azul. El acabado de landing y sus efectos
se conservan únicamente en la selección activa de la barra.
Validación: formato, análisis completo y7 pruebas de Home aprobados.
Pendiente revisión visual Android.

19/10/2026: opción activa y Reportar comparten un acabado local equivalente
a Iniciar sesión de landing: degradado azul, brillo y sombras suaves,
hover/foco/pulsación con elevación2px y oscurecimiento3% en200ms. Movimiento
reducido aplica solo color inmediato. Conserva glass, destinos, origen real
de Reportar, áreas52/64 y selección deslizante320ms. No requiere activación,
persistencia ni permisos nuevos.16 comprobaciones de Home/arquitectura y
análisis aprobados; renders390/320 con texto2 revisados. Pendiente revisión
Android. [ADR-098](../decisiones/098-navegacion-mobile-acabado-boton-landing.md).

19/10/2026: los títulos de fallback Explorar/Mis mascotas usan peso500, igual
que CollectionHeader en las secciones reales, por petición del usuario.
Sin cambios de navegación. Revisión visual Android pendiente.

18/10/2026: la campana Alertas abre la bandeja persistente HU-12, sustituyendo
el aviso de indisponibilidad. Callback compuesto en router; HomeScreen no
importa presentación de notifications. [Ficha](seguimiento-y-alertas.md).

Corrección18/10/2026: la clave de sección pertenece al scroll del contenido,
no al contenedor de toda la pantalla. LiquidNavigation y su Tween conservan
la instancia al alternar Inicio/Explorar/Mis mascotas, restaurando el
desplazamiento320ms y el cambio de destino durante el movimiento. Movimiento
reducido mantiene selección inmediata. Regresión integrada en Home comprueba
identidad, posición inicial/intermedia y cambios rápidos; análisis limpio y
31 pruebas de Home/Explorar/recarga de mascotas/arquitectura aprobadas.
Revisión de fluidez Android pendiente; sin cambios de dominio o permisos.

Refinamiento del gesto compartido: icono de recarga acompaña el descenso, gira durante refresh y retorna al finalizar/cancelar. Se mantiene inscripción por sección y navegación flotante. [ADR-049](../decisiones/049-indicador-recarga-y-retorno.md). Análisis estático sin incidencias; sin nuevas pruebas por instrucción del usuario, pendiente revisión Android.

Actualización del15 de octubre: el scroll principal integra PullToRefresh con destino registrado por la sección visible, Explorar o Mis mascotas. Cada sección controla su ViewModel, sin colaboración entre presentaciones de funcionalidades. Vacío/lista corta permite jalar; el scroll se reinicia al cambiar sección y la navegación flotante conserva su instancia. Inicio sin consulta remota no tiene refresco ficticio. [ADR-048](../decisiones/048-actualizar-listas-al-jalar.md). Análisis sin incidencias, sin pruebas ejecutadas por instrucción del usuario; revisión Android pendiente.

Ajuste del15 de octubre: texto Zona/Zonas sustituido por Ubicación/Ubicaciones y descripción de Explorar actualizada al inicio por ubicación actual/radio15km con alternativa manual. Sin cambios de rutas. Formato/análisis, sin nuevas pruebas por instrucción del usuario. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md).

Módulo: `home`; composición y protección de rutas en `app`.

## Qué hace y cómo se usa

Es el destino tras iniciar sesión y completar onboarding. Compone Inicio,
Explorar y Mis mascotas mediante la navegación compartida. La cabecera incluye
el acceso al perfil y el control de alertas. Mis mascotas recibe el contenido
real de la funcionalidad pets desde la composición de la app.

HomeViewModel mantiene la sección seleccionada; la pantalla observa ese estado.
Bootstrap/router conectan funcionalidades sin que home importe sus repositorios
ni combine directamente providers de infraestructura.

## Alcance actual y estados

Mis mascotas permite el recorrido documentado en [Mascotas](mascotas.md).
Explorar recibe desde app el listado filtrado real de [Explorar](explorar.md).
Alertas conserva información de disponibilidad pendiente; no hay bandeja operativa.

La cabecera permanece fuera del reveal del contenido. Navegación y cargas
reutilizan las reglas visuales compartidas; al cambiar identidad se protege el
contenido privado y el router devuelve a login cuando corresponde.

## Validación

Comprobar acceso autorizado, cambio de sección, entrada a mascotas/perfil,
cierre de sesión y dimensiones pequeñas con texto ampliado. No atribuir
persistencia de casos o entrega de alertas al shell. Evidencia: [ESTADO](../ESTADO.md).

## Reportar y consultar casos

Reportar permite Mascota perdida (HU-05) y Mascota encontrada (HU-06), con accesos a Mis casos y Mis encontrados. Los botones abren los formularios; solo su publicación confirmada crea un caso. La composición/router protege sesión y onboarding sin importar presentación/data entre funcionalidades. Recorridos completos en [Casos perdidos](casos-perdidos.md) y [Casos encontrados](casos-encontrados.md), con activación/demo real pendientes según ESTADO. Mis encontrados distingue drafts y limpieza pendiente de publicaciones; no muestra identificadores técnicos ni datos ficticios.


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.


## Nuevo significado de búsqueda y aviso — 11 de octubre de2026

Por instrucción del usuario, Mascota perdida admite Mi mascota u Otra mascota posiblemente perdida. Mascota encontrada avisa en una búsqueda abierta con La vi o La encontré y está conmigo, sin cerrarla. Desde ficha se vincula automáticamente el aviso; solo el autor confirma Ya fue recuperada. Se conservan UI de Mascotas, coordenadas privadas/zonas públicas y órdenes estables. Aviso admite foto opcional; búsqueda comunitaria exige fotos. Registros anteriores siguen como Reporte anterior, sin reclasificación automática. [ADR-034](../decisiones/034-busquedas-y-avisos-vinculados.md) y [ficha](busquedas-y-avisos.md).

Cambio de alcance autorizado: HU-05/RF-05 y HU-06/RF-06; se adelantan partes app de HU-10/RF-11 y confirmación de HU-13/RF-07. No se cierran historias ni se entrega web/QR, moderación completa, push o exploración/paginación de HU-07. Fuentes062–065/plan018, migración generada y probada localmente; activación remota/Android y concurrencia multiconexión pendientes.


## Panel Reportar y Mis reportes — 12 de octubre de 2026

Sustituye los accesos intercalados anteriores: Reportar contiene únicamente Mascota perdida/Mascota encontrada con explicación breve. Cerrar retirado por instrucción del usuario; modal se cierra con gesto, barrera o Atrás. Inicio ofrece Reportar, Mis reportes y Mis mascotas. [Mis reportes](mis-reportes.md) reúne ambos orígenes con tarjetas/filtro/swipe compartidos; no divide la consulta en enlaces dentro de crear. [ADR-036](../decisiones/036-reportar-y-mis-reportes.md). Sin nuevos SQL o funciones de exploración/alertas.


## Reportar directo — 12 de octubre de 2026

Por decisión explícita del usuario, se retira Mascota encontrada del acceso Reportar y el panel intermedio. Reportar abre Mascota perdida con Mi mascota/Otra mascota. Avisos solo desde ficha abierta con caso vinculado; Mis reportes conserva consulta/gestión. Explorar es destino previsto de consulta pública pero su implementación continúa pendiente. [ADR-037](../decisiones/037-avisos-desde-ficha.md).


## Explorar operativo localmente — 15 de octubre de 2026

Sustituye la disponibilidad pendiente de las notas anteriores: Explorar consulta tarjetas públicas con filtros y paginación y abre las fichas existentes. App inyecta ExploreSection; Home no importa otras presentaciones. La cabecera y navegación se conservan, con entrada cover→stagger; consultas no repiten la animación. Actualizar y retorno desde ficha conservan datos durante refresh. Requiere backend019; evidencia local y pendientes en [ficha](explorar.md)/ESTADO. El16 de octubre HU-07.2 agrega Lista/Mapa sobre la misma consulta, con puntos públicos aproximados y apertura de tarjetas/fichas; sin entrega de alertas. Demo Android/hosted pendiente.
