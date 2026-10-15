# Zonas de interés privadas

Cambio visual del 15 de octubre de 2026: por instrucción explícita del usuario,
ZoneMapPicker deja de mostrar el texto de atribución y su botón/enlace en todas
sus instancias (zonas, formularios y fichas de reportes). Se eliminan las opciones
de configuración de ese texto/enlace. El proveedor de teselas sigue siendo el
existente; sus condiciones de atribución quedan pendientes de resolver antes de
distribuir, según CONFIGURACION. Selección, círculo y reintento se conservan.

Módulo: `interest_zones`. HU-02.1 / RF-02,16;
[issue #26](../backlog/026-HU-02.1.md).

## Qué hace y cómo se usa

Desde Perfil se consultan, crean, editan y eliminan zonas propias. Cada zona
tiene nombre, centro y radio. El usuario toca el mapa para elegir el punto,
puede mover/zoom y ve el círculo de alcance. También puede introducir coordenadas
manualmente, incluso si falla el servicio de mapas.

No requiere permiso GPS ni obtiene ubicación del dispositivo. Lima es el
encuadre inicial del mapa, no una posición inferida ni guardada automáticamente.
Las zonas no se asocian a una mascota concreta ni publican coordenadas de casos.

## Reglas y persistencia

Nombre obligatorio de1–60 puntos de código; latitud −85..85, longitud −180..180
y radio100–50000 metros. Se exige seleccionar un punto explícito y rechazan
valores no finitos. Dominio y SQL comparten estos límites.

Las RPC obtienen la cuenta de la sesión, usan UUID estable y versión esperada.
El reintento idéntico reconoce el resultado sin duplicar ni incrementar de nuevo;
el incompatible produce conflicto. Eliminación conserva una marca para impedir
que un envío antiguo recree la zona. Datos privados y sin escritura directa cliente.

Error conserva el borrador. Consultar versión actual o descartar cambios requiere
confirmación cuando se perdería edición. Refresco conserva contenido con progreso;
cambio de cuenta oculta datos previos. No existe cola offline persistente.

## Dependencias y validación

Patch010, repositorio Supabase y mapa flutter_map con proveedor configurable.
La selección por coordenadas permite continuar sin teselas; no hay seguimiento
GPS, descarga masiva de mapas ni búsqueda geográfica de casos en este incremento.
El usuario reportó aplicación del parche y validación de HU-02 en ESTADO;
consultar allí la evidencia concreta, sin convertirla en prueba de casos/alertas.

Comprobar persistencia, edición/eliminación, coordenadas manuales, conflictos y
aislamiento entre cuentas. [ADR-018](../decisiones/018-zonas-manuales-privadas.md),
[ESTADO](../ESTADO.md) y [CONFIGURACION](../CONFIGURACION.md).


## Reutilización visual — 10 de octubre de 2026

Confirmaciones delegadas al diálogo completo confirmActionDialog de core, con acciones de geometría/alineación y adaptación compartidas, sin layouts propios. En reportes, terminar carga conserva la entrada del skeleton y no dispara cover/stagger nuevos; vista previa y confirmación conservan su transición. Validación local y límites en ESTADO; no cambia persistencia/permisos ni cierra la historia remota.


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.

## Corrección de consistencia — 11 de octubre de 2026

Carga, selección de campos/punto, guardado y eliminación usan toast, marcas invalid y shake. Decoración y superficie de mapa compartidas; acciones de reintento/conflicto se conservan.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.
