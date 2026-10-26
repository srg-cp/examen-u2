# ADR-151: desvanecido del contenido bajo la cabecera de Inicio móvil

Fecha:26/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Decisión

Precisión posterior del usuario: la transición comienza dentro del margen
inferior de la cabecera, no debajo de su límite. HomeScrollLayout solapa28px
del viewport de scroll bajo la cabecera y reserva esos28px en el padding del
cuerpo para conservar su posición inicial. Cabecera medida con su altura real
y pintada al final; geometría y texto ampliado conservados. El desvanecido48px
empieza28px antes de la unión y termina solo20px después, en altura normal.

Aplicar la última referencia aprobada: transición amplia, continua y suave
entre cabecera y contenido desplazado, integrada con el fondo real. Sin
imagen de humo, textura decorativa ni nubes de bordes irregulares.

HomeScrollFade en presentación de Home aplica una máscara alfa vertical
dstIn al cuerpo existente. Deja ver AppPageBackground, incluida su iluminación
y movimiento originales. No añade una superficie celeste independiente ni
desenfoca toda la pantalla. La referencia se traduce en desvanecido de opacidad,
sin introducir un filtro de desenfoque adicional.

El alcance crece con el desplazamiento real hasta48px lógicos; se limita al40%
del viewport de scroll en ventanas bajas. Arriba no atenúa el título. Al volver
al inicio o hacer pull-to-refresh se retira de forma continua. Sin temporizador
ni animación nueva; funciona también con movimiento reducido.

Cabecera, controles y navegación quedan fuera de la máscara, con dimensiones,
materiales, semántica y origen/retorno conservados conforme a ADR-148.
Solo Inicio móvil: Explorar, Mis mascotas y web conservados. Sin cambios de
dominio, datos, rutas, permisos, persistencia, dependencias o assets de producto.

## Validación

39 comprobaciones locales aprobadas: Home, destinos/retorno normal y reducido,
refresh/reintento, estabilidad glass, arquitectura, consistencia y harness visual.
Se fija AMBIENT_BACKGROUND_MOTION=false para pumpAndSettle; la ejecución sin
esa opción agotó la espera por el movimiento ambiental continuo existente.
Capturas con fuentes y assets reales en390×844 y320px/texto200%, incluyendo
ventana320×350. Pendiente aceptación del render y Android físico; APK sin
recompilar ni instalar. Sin cierre de historias ni despliegue.
Análisis de lib/test/tool sin incidencias; análisis global señala dos avisos
avoid_print en un archivo preexistente de build, fuera de las fuentes mantenidas.
