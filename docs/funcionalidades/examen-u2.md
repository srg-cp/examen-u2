# Examen Unidad II tipo 1

## Punto 2 Seguimiento con consumo controlado

Incremento exclusivo del examen,30/10/2026. Iniciar sesión → Explorar → Mapa.
El mapa suscribe el GPS al entrar y lo cancela al salir; abrir una ficha y pasar
a segundo plano también detienen el seguimiento. No se apaga el GPS global del
dispositivo: se liberan las solicitudes de esta pantalla.

Reglas: LocationAccuracy.medium, intervalo nativo30s y distancia50m. El filtro
de recepción exige a la vez30s transcurridos y desplazamiento≥50m desde la última
lectura aceptada. Se usa Stopwatch monotónico. Después de verificar acceso,
la primera lectura tiene10s; si no llega, cancelación y locationTimeout, que la
pantalla muestra como «Tiempo agotado» mediante el toast compartido. No se aplica
un timeout recurrente que falle al permanecer quieto. Los errores del seguimiento
eliminan el valor GPS visible; no se ofrece una lectura anterior como actual.

Contratos para la integración del punto3, sin implementarlo aquí:
`CurrentLocationRepository.watch()` devuelve `Stream<CurrentLocation>`;
`ExploreFailureKind.locationTimeout`; `exploreMapLocationProvider` expone
`AsyncValue<CurrentLocation?>`. La pantalla usa `location.asData?.value`, sin
fallback a ExploreState.currentLocation cuando el seguimiento falla.

Datos: única dependencia de geolocator en DeviceLocationSource; fuente/repo/caso
de uso/ViewModel existentes extendidos sin persistencia nueva ni llamadas a
Supabase. onCancel libera temporizador y escucha nativa. stop registra
«GPS detenido» tras cancel; ref.onDispose y dispose del mapa evitan fugas.
ACCESS_FINE_LOCATION junto a ACCESS_COARSE_LOCATION reproduce125c04d sin cambiar
la precisión solicitada, sin incorporar los otros cambios de ese commit.

Validación:29 pruebas de configuración, límites simultáneos, timeout, cancelación
antes de primera lectura y durante permisos, errores sin dato GPS anterior,
presentación del aviso, regresiones de navegación normal/pequeña y arquitectura;
análisis sin incidencias. APK debug compilado e instalado con el ajuste Java
temporal comunicado por el estudiante. Logcat final en emulator-5554 confirma
PID9385:21:24:51.950 GPS detenido y21:24:51.951 position updates stopped.
No se modificó la ubicación ni se apagó el GPS para obtener esta evidencia.

[Capturas y registros](../evidencias/examen-u2-punto-2/README.md).
Word independiente: `SI988-EXPRAC-U2-ColquePonceSergioAlberto-Punto2.docx` en la raíz;
conserva carátula de la copia recibida y documenta solamente el punto2 en4 páginas.
Se exportó con Word y se revisaron visualmente las4 páginas. La herramienta
render_docx.py se intentó, pero falta LibreOffice en Windows; se usó el render
nativo de Word con PNGs de comprobación. No sobrescribe el Word original.
Pendientes: integración con los apartados de otros chats y validación del docente.
Las pruebas de este incremento no presentan como desarrollado el punto4 del examen.

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

## Evidencias y validación

Cierre del punto 1, 30/10: incorporado ACCESS_FINE_LOCATION junto a COARSE en
AndroidManifest.xml, manteniendo LocationAccuracy.medium. APK debug compilado
e instalado mediante actualización, sesión conservada y permiso preciso activado
en emulator-5554. Posición fijada -18.0066, -70.2463; tras solicitar ubicación
desde Explorar y aplicar, el mapa muestra -18.006598, -70.246300. Diferencia
aproximada de 0.22 m, dentro de la precisión de la lectura nativa. Coordenadas
reales verificadas mediante captura y árbol de accesibilidad, sin sustituciones.
Las cinco figuras y explicación actualizadas en el Word de nueve páginas; figura 5
sustituida por la captura precisa. 22 pruebas focalizadas aprobadas; la última
fuente Dart analizada no cambió en este ajuste de permiso. Puntos 2–5 pendientes.

Logs: `apps/mobile/build/examen-punto1-cierre-tests.log` y
`apps/mobile/build/examen-punto1-cierre-build.log`. El bloqueo Java de loopback
se resolvió solo en el proceso de compilación con
`JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\Temp\eh-java`, sin configuración
global ni cambio de Gradle del proyecto. La captura precisa acredita coordenadas;
las teselas de la captura final no aparecen pintadas, por lo que no acredita la
cartografía del punto 3. No se altera platform ni el backend.

### Historial previo al cierre

Última evidencia recibida 30/10: tras comprobar mi ubicación en Google Maps y
reabrir Entre Huellas, la app muestra Tacna (-18.018018, -70.237279). Incorporada
como figura 5 a la copia Word, ahora de nueve páginas. Incluye las cinco capturas
del punto 1 y explicación técnica. ACCESS_COARSE_LOCATION/precisión media conservados:
la lectura es aproximada y no coincide numéricamente con el punto configurado
(-18.0066, -70.2463). Diferencia explicada en el documento; no se afirma precisión
exacta ni aceptación del docente. Puntos 2–5 todavía no desarrollados.

Avance documental 30/10: copia de trabajo
`SI988-EXPRAC-U2-ColquePonceSergioAlberto.docx` con las tres capturas de código
y la confirmación de Extended Controls en -18.0066, -70.2463. Maquetación
revisada en ocho páginas con Word. La captura recibida de la app todavía muestra
37.423423, -122.083953; no se usa para acreditar la posición de Tacna.
Pendiente renovar la lectura y recibir la captura coincidente de la app.

Corrección posterior del punto 1: `locateForFilter` ahora guarda en el estado la
nueva lectura GPS, además de devolverla al editor. Antes, aplicar otra lectura
movía el filtro pero conservaba las coordenadas GPS anteriores en el panel.
Regresión con dos ubicaciones distintas comprueba coordenadas/precisión nuevas
y su conservación tras aplicar/refrescar/paginar. 22 pruebas focalizadas aprobadas
y análisis Flutter sin incidencias. Compilación debug local bloqueada por Gradle
(`Unable to establish loopback connection`); no se instaló un APK nuevo.
Diagnóstico ADB: Android aún registra California como última ubicación GPS/fused,
incluso después de enviar `emu geo fix -70.2463 -18.0066` (respuesta OK). Pendiente
comprobar la lectura nativa activando mi ubicación en Google Maps y renovar la
lectura de Entre Huellas. No se afirma resuelto el GPS del emulador.

1. En el emulador, abrir Extended controls → Location, fijar latitud/longitud
   y pulsar Set location (el nombre puede variar según la versión del emulador).
2. Abrir Explorar con permiso de ubicación; si ya estaba abierto, usar
   Ubicación → Usar mi ubicación actual → Aplicar ubicación y después Mapa.
3. Capturar el mapa con Latitud y Longitud y los valores configurados del emulador.
4. Capturar en el editor la entidad, `DeviceLocationSource` y los imports de
   `ExploreViewModel`. Completar el documento con las imágenes reales recibidas.

Siguiente paso: verificar el punto 1 en Android y completar sus evidencias antes
de continuar al punto 2. El Word del usuario se conserva sin modificar.
