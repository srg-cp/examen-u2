# Examen Unidad II tipo 1

## Punto 1 Separación de ubicación

Incremento del 30/10/2026 sobre Explorar móvil (HU-07/RF-13), únicamente para
el punto 1 del examen. No implementa los puntos 2–5 ni cierra la historia.

Recorrido: iniciar sesión → Explorar → conceder ubicación → Mapa. El panel
inferior muestra Ubicación GPS, Latitud y Longitud con seis decimales; puede
ampliarse o desplazarse en pantallas pequeñas/con texto ampliado.

`CurrentLocation` contiene `latitude`, `longitude` y `accuracyMeters`, sin SDK.
Solo `DeviceLocationSource` importa geolocator y obtiene la lectura nativa.
`CurrentLocationRepositoryImpl` convierte la lectura a entidad; el caso de uso
valida coordenadas y precisión. `ExploreViewModel` recibe el caso de uso mediante
los providers existentes, con repositorio inyectado desde main. Conserva la lectura
en `ExploreState` al refrescar, paginar o fallar la consulta de casos.

No añade persistencia ni envía la precisión a Supabase. Las coordenadas GPS que se
muestran son las del dispositivo, independientes de los puntos públicos de casos.
Permisos denegados/servicio apagado conservan el toast y selección manual existentes.
Precisión media y timeout de 12 s actuales conservados: el cambio a 10 s y el
seguimiento/cancelación corresponden al punto 2.

Validación local: 36 pruebas de lectura simulada, ViewModel, Explorar/filtros,
mapa y arquitectura aprobadas; análisis Flutter sin incidencias. El mapa se
revisa con teselas neutras en tamaño normal y pequeño/texto 200%/movimiento
reducido. Estas comprobaciones no acreditan GPS ni cartografía nativos.
Log: `apps/mobile/build/examen-u2-punto-1-tests.log`.

## Evidencia pendiente del estudiante

1. En el emulador, abrir Extended controls → Location, fijar latitud/longitud
   y pulsar Set location (el nombre puede variar según la versión del emulador).
2. Abrir Explorar con permiso de ubicación; si ya estaba abierto, usar
   Ubicación → Usar mi ubicación actual → Aplicar ubicación y después Mapa.
3. Capturar el mapa con Latitud y Longitud y los valores configurados del emulador.
4. Capturar en el editor la entidad, `DeviceLocationSource` y los imports de
   `ExploreViewModel`. Completar el documento con las imágenes reales recibidas.

Siguiente paso: verificar el punto 1 en Android y completar sus evidencias antes
de continuar al punto 2. El Word del usuario se conserva sin modificar.
