# Recarga de contenido por gesto móvil

PullToRefresh es presentación compartida de los consumidores existentes:
Inicio/Explorar/Mis mascotas, guardados, ubicaciones, avisos y recorridos que
declaran recarga. PullToRefreshTarget inscribe la operación de la sección activa.
Las pantallas/ViewModels conservan lectura de datos, feedback y reintentos;
el componente no añade persistencia ni permisos propios.

Jalar desde arriba muestra el icono glass y lo gira según el avance del dedo.
Soltar por debajo del umbral lo retira sin consultar; superar el umbral ejecuta
una operación con giro durante su Future. El consumidor conserva contenido y
shimmer. El fallo mantiene feedback/reintento del ViewModel; se admite otra
petición tras resolver la anterior. Acción accesible Actualizar contenido
conservada; sin scrolls anidados/horizontales ni formularios desactivados.

29/10, [ADR-162](../decisiones/162-recarga-por-gesto-y-retorno-al-top.md): limitar
la posición pintada ya no congela el giro. Cancelar con rebote retira desde la
primera actualización balística; confirmar/cancelar acomoda el scroll primario
al top de la pantalla actual. Sin navegación ni reinicio del stagger y sin
forzar el top durante scroll ordinario. Movimiento reducido directo/sin giro.

Validación:47 pruebas locales aprobadas del componente/consumidores y reglas;
clamping/bouncing, normal/reducido, gesto parcial/completo/largo y duplicados.
Análisis lib/test sin incidencias; sin nueva activación de backend ni cierre de
historias. Pendiente recompilar y revisar Android/iOS físicamente, incluidos
texto ampliado y pantallas pequeñas. Logs y límites en ESTADO.
