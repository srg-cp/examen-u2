# Funcionalidades de Entre Huellas

Inicio móvil19/10: [glass estable y tarjeta de reunión](fondos-mobile.md),
con imagen original de web y superficie fuera del stagger. ADR-093.

Marca móvil19/10: [identidad visual](identidad-visual.md) usa el mismo lettering
Arial de web en BrandWordmark/arranque, conservando símbolo oficial. ADR-092.

Móvil19/10: [nubes en toda la altura con movimiento y tarjeta principal glass](fondos-mobile.md),
reutilizando el material compartido; pausa accesible y por ruta oculta. ADR-091.

Corrección móvil19/10: [fondo blanco con nubes azules](fondos-mobile.md) según
referencia aportada; ADR-088 sustituye el degradado inicial de ADR-086.

Acceso web19/10: [registro, verificación de correo y recuperación por código](acceso-web.md)
implementados localmente, con capacidad recovery aislada; ADR-087. Demo SMTP real
pendiente; no equivale a paridad global ni cierre de HU.

Móvil19/10: [fondo frío compartido](fondos-mobile.md), con los mismos colores
del resto de la web; arranque, shells y transiciones existentes. ADR-086.

Cartografía móvil19/10: [Positron y crédito compartido](cartografia-mobile.md),
con pines de marca conservados; ADR-084 sustituye ADR-054 para mapas CARTO.

Acceso web19/10: [avisos de una sola vez y URL limpia](acceso-web.md); se retira
reason consumido conservando parámetros de integración y fragmento.

Toast web: [entrada superior y descarte por gesto](toast-web.md), compartido
en todos sus consumidores actuales; ADR-081, validación local19/10/2026.

Corrección19/10: reveal compartido sin cobertura opaca en [acceso](acceso-web.md),
[moderación](moderacion-web.md), [QR](ficha-publica-qr.md) y
[avistamientos web](avistamientos-web.md). ADR-075; evidencia local en ESTADO.

Actualización19/10: [Acceso web](acceso-web.md) admite cuentas válidas sin rol de
revisión, con bienvenida por cuenta e inicio real de cuenta. Moderación conserva
permisos por operación y acceso desde gestión autorizada. /iniciar-sesion,
/terminos y /privacidad son canónicas, con redirecciones antiguas.
No se entrega paridad completa web/móvil ni administración; sin despliegue.

Confirmación posterior18/10:030 aplicado por usuario. Moderación web conserva
configuración/rol/login y demo real por verificar; no reaplicar030.


Moderación18/10: administración exclusivamente web por instrucción del usuario.
[Revisión y moderación](moderacion-web.md), HU-14.3/#45 implementada localmente;
030/configuración/demo pendientes. No se incorpora administración a Flutter.


Actualización posterior18/10:029 aplicado según confirmación del usuario.
HU-14.1 conserva validación real/integración pendientes; no reaplicar029.


Actualización18/10: el usuario confirma028 aplicado y autoriza continuar HU-14.1.
[Denuncias de contenido](denuncias-contenido.md) implementada localmente;029 confirmado, demo
pendiente. Firebase/FCM fuera del alcance; no bloquea la entrega. Estado remoto
del tablero conservado como última instantánea, sin nuevas acciones GitHub.


Auditoría ampliada18/10:27 Done,9 In progress,2 Ready y13 Backlog. Se
corrigieron20 tarjetas más tras contrastar integración/pruebas/confirmaciones.
[Motivo vigente por historia](../backlog/AUDITORIA_2026-10-18.md); las notas
históricas de las fichas no se tratan automáticamente como pendientes actuales.

Corrección18/10: HU-03 (#3/#28/#29) en Done y cerrada; los motivos de
seguimiento antiguos de fotos/patch se sustituyen por la implementación e
integración acreditadas. [Backlog actualizado](../backlog/README.md).

Seguimiento18/10: HU-10.1/#36 y HU-11.1/11.2 (#38/#39 y épica #11)
aceptadas por el usuario, Done y cerradas en GitHub. HU-12.1/12.2 y HU-13
permanecen In progress; FCM pospuesto. [Backlog sincronizado](../backlog/README.md).

Documentación del comportamiento implementado al 18 de octubre de 2026.
Cada ficha explica propósito, recorrido, reglas, persistencia, errores y
validación. Se actualiza junto con el código cuando cambia una funcionalidad.
Una funcionalidad implementada no equivale a una historia cerrada: la evidencia
de pruebas y despliegue se registra en [ESTADO](../ESTADO.md).

| Funcionalidad | Módulo Flutter | Trazabilidad |
| --- | --- | --- |
| [Fondos web compartidos](fondos-web.md) | apps/platform | Ajuste visual19/10/2026; toda la web excepto landing; sin HU/issue nuevo |
| [Documentos legales web](documentos-legales.md) | apps/platform | /terminos y /privacidad, con redirecciones antiguas; sin HU/issue nuevo |
| [Acceso web](acceso-web.md) | apps/platform | /iniciar-sesion, /bienvenida y /inicio; HU-01/RF-01,34 en web; conserva HU-14.3 / issue #45; demo real pendiente |
| [Revisión y moderación web](moderacion-web.md) | apps/platform / SQL Supabase | HU-14.3; RF-22,33; issue #45;030/configuración/demo pendientes |
| [Denuncias de contenido](denuncias-contenido.md) | content_reports / SQL Supabase | HU-14.1; RF-22; issue #43;029 confirmado; demo/integración pendientes |
| [Cierre y recuperación](cierre-y-recuperacion.md) | case_closure / SQL Supabase | HU-13; RF-07; issue #13; 028 confirmado aplicado; demo/integración pendientes |
| [Seguimiento y alertas](seguimiento-y-alertas.md) | notifications / SQL Supabase | HU-12.1/12.2; RF-16,17,18; issues #40/#41;027 confirmado, demo pendiente. HU-12.3/#42 FCM/Firebase pospuesta (ADR-068) |
| [Identidad visual y marca](identidad-visual.md) | core branding / apps/platform | Petición17/10/2026; sin HU/issue nuevo |
| [Landing pública](landing-page.md) | apps/platform (Vue/Nuxt) | Ampliación del usuario; integración17/10/2026; sin HU/issue nuevos |
| [Ficha pública QR](ficha-publica-qr.md) | apps/platform (Vue/Nuxt) | HU-09; RF-09; issue #9; lector operativo e integrado; Done |
| [Avistamientos web](avistamientos-web.md) | apps/platform / sightings | HU-10.1; RF-11; issue #36;024/operación aceptados; Done |
| [Avistamientos Android](avistamientos-android.md) | apps/mobile / sightings y servidor Nuxt | HU-10.2; RF-11; issue #37;025 confirmado e integración PR60; Done |
| [Cronología y revisión](cronologia-y-revision.md) | apps/mobile / case_timeline, RPC autenticadas | HU-11.1/11.2; RF-12,14; issues #38/#39 y épica #11;026/recorrido aceptados; Done |
| [Carteles PDF y QR](carteles-qr.md) | case_posters | HU-08.1/08.2; RF-08,37; issues #34/#35; integrado; impresión/escaneo y exportación nativa pendientes; In progress |
| [Buscador compartido de ubicaciones/ciudades](ubicaciones-buscador.md) | places | HU-07/RF-13 y Perfil HU-01.7/RF-01; ampliación16/10/2026 |
| [Casos guardados](casos-guardados.md) | saved_cases | Ampliación16/10 de HU-07/RF-13; online integrado; offline HU-15.3/#49 sin implementar |
| [Acceso y recuperación](acceso.md) | auth | HU-01; RF-01,34; #17/#18/#20/#22 Done; #19 retorno Google pendiente; épica #1 abierta por Google/baja/exportación |
| [Onboarding por cuenta](onboarding.md) | onboarding | HU-01.5; RF-01; issue #21; ADR-004; Done |
| [Inicio y navegación](inicio.md) | home | Composición de recorridos, acceso a Reportar y módulos |
| [Perfil y foto de cuenta](perfil.md) | profile | HU-01.7; RF-01; issue #23; entrega integrada; Done |
| [Mascotas](mascotas.md) | pets | HU-03; RF-03; issues #3/#28/#29; Done |
| [Fotos de mascotas](fotos-mascotas.md) | pets y Edge pet-photo-process | HU-04; RF-03; issues #4/#30/#31; cámara/procesamiento/principal integrados; Done |
| [Ubicaciones de interés](zonas.md) | interest_zones | HU-02.1; RF-02,16; issue #26 y épica #2;010 confirmado; Done |
| [Preferencias de alertas](preferencias-alertas.md) | alert_preferences | HU-02.2; RF-02,16; issue #27 y épica #2;011/HU-02 confirmados; Done |
| [Casos perdidos](casos-perdidos.md) | lost_cases | HU-05; RF-05; issue #5; entrega integrada; Done |
| [Avisos y reportes anteriores](casos-encontrados.md) | found_cases | HU-06; RF-06; issue #6; alcance ADR-034 integrado; Done |
| [Búsquedas y avisos vinculados](busquedas-y-avisos.md) | lost_cases / found_cases | HU-05/06 Done; partes HU-10; cierre nuevo HU-13 028 confirmado; integración/demo pendientes; ADR-034 |
| [Explorar: lista y mapa filtrados](explorar.md) | explore | HU-07.1/07.2; RF-13; issues #32/#33 y épica #7; integración/Android real; Done |
| [Mis reportes](mis-reportes.md) | found_cases / dominio lost_cases | HU-05/06; consulta unificada; ADR-036 |

Las HU son identificadores del producto; los números # son issues de GitHub.
El detalle de subtareas se conserva en [backlog](../backlog/README.md).

Todas las funcionalidades siguen [las reglas de arquitectura](../REGLAS_ARQUITECTURA.md):
pantallas → ViewModel → casos de uso → contrato de repositorio → fuente de datos.
Las sesiones y permisos se comprueban también en servidor; la UI no sustituye
RLS, grants ni restricciones. Al cambiar de cuenta se descartan resultados
tardíos y datos privados de la identidad anterior.

## Notas técnicas históricas

Las notas siguientes reflejan sus incrementos originales. Para el estado actual
se aplican la tabla y la auditoría del18/10; no reactivan pendientes ya superados.

Mapa de Explorar, carteles/QR y lectura web tienen implementación local;
activación y evidencia se detallan en sus fichas. Avistamientos web operativos
según usuario; Android implementado localmente con025/demo pendiente. Bandeja
y seguimiento/bandeja tienen implementación local HU-12.1/12.2 con027 confirmado
por el usuario; demo hosted pendiente. FCM/Firebase y HU-12.3 quedan pospuestos
por instrucción del usuario (ADR-068), fuera de la activación actual.

Para cada incremento, actualizar su ficha, enlazar nuevas fichas aquí y
registrar en ESTADO la validación real y lo pendiente. Los motivos técnicos van
en ADR; los pasos de activación van en CONFIGURACION, evitando copias de SQL o
comandos de despliegue que puedan divergir.

Corrección de feedback en reportes perdidos/encontrados: [ADR-023](../decisiones/023-feedback-reportes-toast-superior.md). Patch014 y copia/extracción del paquete confirmados por el usuario; validación remota autenticada pendiente.


Perdidos y encontrados comparten la vista previa inmersiva de publicación y la descripción expandible, según [ADR-024](../decisiones/024-vista-previa-publicacion-inmersiva.md). Vista previa y ficha pública comparten esta composición; la galería del formulario conserva sus tiles. Se mantienen los criterios remotos pendientes.


Los layouts con scroll de acceso, Inicio, perfil, mascotas, zonas, preferencias y reportes comparten la continuidad inferior y protección de acciones de [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md); modales/onboarding conservan sus geometrías específicas.

Las fichas/previas de perdidos y encontrados incorporan mapa compartido de zona pública, fecha destacada y retorno sin título glass. Ver fichas y ADR-024 actualizado; verificación de teselas reales en Android pendiente.

Mis casos/Mis reportes adoptan los componentes reales de Mis mascotas y eliminación por swipe de casos abiertos/resueltos. Activación por migración016 pendiente; detalle en ambas fichas y [ADR-026](../decisiones/026-listas-casos-componentes-compartidos.md).

La corrección global del11 de octubre aplica ADR-027/028 a las fichas existentes, incluido onboarding; todas documentan toast/shimmer, reintentos y límites. Evidencia consolidada en ESTADO.


Mascota perdida adopta un único formulario con selección de ficha y datos del reporte conservados: [búsquedas y avisos](busquedas-y-avisos.md), [ADR-038](../decisiones/038-formulario-unico-mascota-perdida.md).
