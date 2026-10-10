# Zonas de interés privadas

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
