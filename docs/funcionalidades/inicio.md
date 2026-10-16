# Inicio y navegación

Refinamiento del gesto compartido: icono de recarga acompaña el descenso, gira durante refresh y retorna al finalizar/cancelar. Se mantiene inscripción por sección y navegación flotante. [ADR-049](../decisiones/049-indicador-recarga-y-retorno.md). Análisis estático sin incidencias; sin nuevas pruebas por instrucción del usuario, pendiente revisión Android.

Actualización del15 de octubre: el scroll principal integra PullToRefresh con destino registrado por la sección visible, Explorar o Mis mascotas. Cada sección controla su ViewModel, sin colaboración entre presentaciones de funcionalidades. Vacío/lista corta permite jalar; estado del gesto se descarta al cambiar sección y la navegación flotante se conserva. Inicio sin consulta remota no tiene refresco ficticio. [ADR-048](../decisiones/048-actualizar-listas-al-jalar.md). Análisis sin incidencias, sin pruebas ejecutadas por instrucción del usuario; revisión Android pendiente.

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

Sustituye la disponibilidad pendiente de las notas anteriores: Explorar consulta tarjetas públicas con filtros y paginación y abre las fichas existentes. App inyecta ExploreSection; Home no importa otras presentaciones. La cabecera y navegación se conservan, con entrada cover→stagger; consultas no repiten la animación. Actualizar y retorno desde ficha conservan datos durante refresh. Requiere backend019; evidencia local y pendientes en [ficha](explorar.md)/ESTADO. No incluye mapa de resultados ni entrega de alertas.
