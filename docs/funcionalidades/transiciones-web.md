# Transiciones web desde origen y navegación liquid

Incremento visual del 20/10/2026. [ADR-119](../decisiones/119-animaciones-web-desde-origen-y-navegacion-liquid.md).

## Qué hace y recorrido

La barra de cuenta usa solo iconos en todos los tamaños, con tooltip/nombre
accesible. Una cápsula azul compartida se desplaza entre Inicio, Explorar y Mis
mascotas en 320 ms; el color de cada icono sigue su distancia al indicador, incluso
al pasar por la sección intermedia. Hover/foco/presión elevan el acento 2 px.
Reportar conserva sus nueve puntos blancos en círculo negro independiente.

Reportar se abre transformando la superficie del botón hasta el área de contenido
bajo la marca. Del 0 al 45% se desvanece el icono de origen; del 65 al 100% aparece
el contenido. Duraciones móvil: entrada 320 ms, retorno 260 ms. Registrar/Editar
mascota reutilizan el mismo componente; cancelar editor revierte hacia su origen.
También se aplica al enlace de revisión de Inicio, conservando permiso global.

## Componentes y reutilización

- app/utils/origin_transition.ts: controlador visual por aplicación, captura y
  coordinación de aperturas locales/rutas, cancelación y registro de retorno.
- OriginTransitionHost: superficie, fondo, identidad y capa decorativa anterior;
  ubicación en el shell y revelado del contenido. Fuera de cabecera y navegación.
- NavigationLink con origin: conserva enlaces reales, clic modificado, guards y
  destino. Sin origen explícito, conserva el comportamiento normal.
- OriginActionButton con action: ejecuta cambio local y anima la misma superficie;
  closeLocal revierte al cerrar. No contiene reglas de negocio ni repositorios.
- navigation_motion: composición/estado por aplicación; no se serializan nodos.

## Reglas, privacidad y persistencia

La barra permanece montada entre las rutas de cuenta para interpolar el indicador.
Solo se habilita con cuenta y bienvenida confirmadas, y se oculta en rutas ajenas;
la política global y los permisos de cada operación siguen siendo autoritativos.
No se anima una entrada directa o recarga desde un origen ficticio.

La captura decorativa anterior es temporal, inerte y excluida de semántica. Retira
formularios/campos, scripts, IDs, diálogos y avisos; no escribe almacenamiento,
payload SSR ni caché. Se limpia tras la animación y no queda en el registro de
retorno. Cambio de identidad cancela la capa y no anima datos de otra cuenta.

## Errores, accesibilidad y reintentos

No cambia feedback, persistencia, RPC ni reintentos del producto. Las confirmaciones
de salida mantienen el formulario y no reproducen una animación si se cancela.
Destino inerte solo durante la expansión; cancelar, redimensionar, cambiar
preferencia o desmontar libera máscaras/frames/animaciones y restaura interacción.
Movimiento reducido elimina expansión/deslizamiento/elevación. Marca y barra
permanecen estables y el contenido conserva su stagger compartido.

## Activación y validación

Sin variables nuevas, SQL, backend o dependencias. Requiere el build web con los
componentes nuevos; no se ha publicado. La instancia de desarrollo existente se
conservó, usando NUXT_BUILD_DIR aislado para verificar producción.

scripts/check-navigation-motion-browser.mjs comprueba fotogramas intermedios del
indicador y expansión, color/semántica, retorno de ruta/local, cabecera estable,
cancelación de navegación con cambios, resize y movimiento reducido. Regresión
de recuperación/acceso y pruebas habituales en ESTADO. Capturas en
apps/mobile/build/ui-preview/web-navigation-motion. Pendiente revisión del usuario
y comprobación táctil en navegadores físicos; evidencia local con backend fixture.
