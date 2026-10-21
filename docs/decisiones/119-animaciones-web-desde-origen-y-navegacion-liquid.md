# ADR-119: animaciones web desde origen y navegación liquid

Fecha: 20/10/2026, America/Lima. Estado: aceptada por instrucción explícita.

## Contexto

El usuario corrige la primera adaptación web: la barra móvil no tiene etiquetas
visibles y faltan el indicador que se desplaza y las aperturas desde el origen.
Solicita llevar los efectos reales a componentes web reutilizables.

## Decisión

UserNavigation es solo iconos en todos los anchos, con aria-label/title/foco y
áreas de 52/64 px. Su instancia permanece montada al cambiar secciones, fuera de
NuxtPage. Un indicador azul único se desplaza 320 ms con la curva de móvil; los
iconos interpolan gris/blanco según la posición real. Hover/foco/presión levantan
el acento 2 px/200 ms. Se conserva el acabado GlassSurface/navigation accent de
móvil y el botón negro independiente de Reportar.

El plugin navigation_motion crea estado de presentación por aplicación, sin
serializar DOM/identidad en SSR. AccountScreen habilita la barra únicamente tras
confirmar cuenta/bienvenida; el host restringe su visibilidad a las cuatro rutas
de cuenta. No se crean reglas de acceso alternativas a la política global.

OriginTransitionHost y su controlador compartido expanden la superficie real del
control: bounds, radio, color e icono/etiqueta. Entrada 320 ms y retorno 260 ms,
como OriginPageTransition/router móvil. La identidad del origen se desvanece
hasta el 45%; el contenido aparece del 65% al 100%. Cabecera/marca y barra quedan
fuera de la transformación. La superficie crece hasta el área bajo la cabecera.

NavigationLink opta por este efecto con origin; OriginActionButton lo reutiliza
en cambios locales. Aplicaciones iniciales: Reportar, Registrar/Editar mascota y
acceso autorizado a revisión. Volver desde la ruta de origen y cancelar editor
revierten el efecto. Rutas directas/recargas no inventan un origen. Se conservan
stagger, permisos, formularios y guard de cambios pendientes.

La pantalla anterior puede permanecer como copia visual inerte durante la
expansión: sin campos de formulario, IDs, scripts, diálogos o avisos, sin eventos,
sin almacenamiento ni SSR. Se libera al terminar/cancelar y no se conserva en el
registro de retorno. Un cambio de identidad cancela y limpia el efecto. Nunca se
capturan credenciales de acceso ni se reutiliza una copia entre cuentas.

## Consecuencias y validación

Animaciones mediante CSS/WAAPI/CSSOM, compatibles con la CSP vigente sin unsafe-inline.
Esperar montaje de la nueva página de Nuxt antes de adjuntar la superficie a su
shell. Retorno, resize/orientación, movimiento reducido, cambios de identidad y
desmontaje liberan máscaras, promesas, frames e inert. Navegación cancelada no
reproduce el efecto; clic modificado/otra pestaña conserva el comportamiento web.

La expansión explícita desde un control sustituye solo esa apertura, no introduce
una cobertura global opaca/crema ni reemplaza el stagger general de ADR-075.
No se añade ocultamiento de barra por scroll vertical: LiquidNavigation móvil
mantiene su posición; se traslada el deslizamiento real de su indicador.

QA Chrome de fotogramas, retorno, identidad, cancelación y movimiento reducido;
build/tipos/pruebas y pendientes en ESTADO y ficha transiciones-web. Sin backend,
SQL, Flutter, publicación o cierre de historias por este incremento.
