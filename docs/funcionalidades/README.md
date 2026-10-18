# Funcionalidades de Entre Huellas

Documentación del comportamiento implementado al 18 de octubre de 2026.
Cada ficha explica propósito, recorrido, reglas, persistencia, errores y
validación. Se actualiza junto con el código cuando cambia una funcionalidad.
Una funcionalidad implementada no equivale a una historia cerrada: la evidencia
de pruebas y despliegue se registra en [ESTADO](../ESTADO.md).

| Funcionalidad | Módulo Flutter | Trazabilidad |
| --- | --- | --- |
| [Seguimiento y alertas](seguimiento-y-alertas.md) | notifications / SQL / Edge FCM | HU-12.1/12.2/12.3; RF-16,17,18; issues #40/#41/#42; local,027/Firebase pendientes |
| [Identidad visual y marca](identidad-visual.md) | core branding / apps/platform | Petición17/10/2026; sin HU/issue nuevo |
| [Landing pública](landing-page.md) | apps/platform (Vue/Nuxt) | Ampliación del usuario; integración17/10/2026; sin HU/issue nuevos |
| [Ficha pública QR](ficha-publica-qr.md) | apps/platform (Vue/Nuxt) | HU-09; RF-09; issue #9; versión anterior operativa según usuario, migración Vue local/HU-10 pendiente |
| [Avistamientos web](avistamientos-web.md) | apps/platform / sightings | HU-10.1; RF-11; issue #36;024/operación confirmados por usuario |
| [Avistamientos Android](avistamientos-android.md) | apps/mobile / sightings y servidor Nuxt | HU-10.2; RF-11; issue #37;025 confirmado por usuario, sin inspección remota |
| [Cronología y revisión](cronologia-y-revision.md) | apps/mobile / case_timeline, RPC autenticadas | HU-11.1/11.2; RF-12,14; issues #38/#39;026/recorrido confirmados por usuario |
| [Carteles PDF y QR](carteles-qr.md) | case_posters | HU-08.1/08.2; RF-08,37; issues #34/#35; implementación local, activación pendiente |
| [Buscador compartido de ubicaciones/ciudades](ubicaciones-buscador.md) | places | HU-07/RF-13 y Perfil HU-01.7/RF-01; ampliación16/10/2026 |
| [Casos guardados](casos-guardados.md) | saved_cases | Ampliación del usuario16/10/2026 de HU-07/RF-13; sin issue asignado; local |
| [Acceso y recuperación](acceso.md) | auth | HU-01; RF-01,34; issue #1 y subtareas |
| [Onboarding por cuenta](onboarding.md) | onboarding | Flujo de entrada de HU-01; ADR-004 |
| [Inicio y navegación](inicio.md) | home | Composición de recorridos, acceso a Reportar y módulos |
| [Perfil y foto de cuenta](perfil.md) | profile | HU-01.7; RF-01; issue #23 |
| [Mascotas](mascotas.md) | pets | HU-03; RF-03; issues #3, #28, #29 |
| [Fotos de mascotas](fotos-mascotas.md) | pets y Edge pet-photo-process | HU-04; RF-03; issues #4, #30, #31 |
| [Ubicaciones de interés](zonas.md) | interest_zones | HU-02.1; RF-02,16; issue #26 |
| [Preferencias de alertas](preferencias-alertas.md) | alert_preferences | HU-02.2; RF-02,16; issue #27 |
| [Casos perdidos](casos-perdidos.md) | lost_cases | HU-05; RF-05; issue #5; implementación local |
| [Avisos y reportes anteriores](casos-encontrados.md) | found_cases | HU-06; RF-06; issue #6; implementación local |
| [Búsquedas y avisos vinculados](busquedas-y-avisos.md) | lost_cases / found_cases | HU-05/06; partes HU-10/13; ADR-034; implementación local |
| [Explorar: lista y mapa filtrados](explorar.md) | explore | HU-07.1/07.2; RF-13; issues #32/#33; implementación local |
| [Mis reportes](mis-reportes.md) | found_cases / dominio lost_cases | HU-05/06; consulta unificada; ADR-036 |

Las HU son identificadores del producto; los números # son issues de GitHub.
El detalle de subtareas se conserva en [backlog](../backlog/README.md).

Todas las funcionalidades siguen [las reglas de arquitectura](../REGLAS_ARQUITECTURA.md):
pantallas → ViewModel → casos de uso → contrato de repositorio → fuente de datos.
Las sesiones y permisos se comprueban también en servidor; la UI no sustituye
RLS, grants ni restricciones. Al cambiar de cuenta se descartan resultados
tardíos y datos privados de la identidad anterior.

Mapa de Explorar, carteles/QR y lectura web tienen implementación local;
activación y evidencia se detallan en sus fichas. Avistamientos web operativos
según usuario; Android implementado localmente con025/demo pendiente. Bandeja
y entrega real de alertas tienen implementación local HU-12; activación027,
Firebase/planificador y demo hosted pendientes según
[GUIA_MVP](../GUIA_MVP.md). Las preferencias se consumen al activar ese incremento.

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
