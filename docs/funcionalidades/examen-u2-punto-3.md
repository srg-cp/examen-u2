# Examen Unidad II tipo 1 punto 3

Alcance exclusivo del examen sobre Explorar móvil (HU-07/RF-13), en el worktree
`entreHuellas-examen-punto-3`, rama `feature/examen-u2-punto-3`, base `125c04d`.
No modifica las carpetas originales, platform ni el seguimiento del punto 2.

## Implementación

ExploreCaseMap recibe CurrentLocation y dibuja CircleMarker con el centro de la
lectura, radio accuracyMeters y useRadiusInMeter=true. Debajo muestra
«Precisión ± N m», redondeando hacia arriba la etiqueta en metros sin alterar el
radio real. El círculo es independiente del radio de búsqueda de casos.

Ante locationUnavailable se oculta cualquier lectura GPS previa y su precisión.
ZoneMapPicker permanece visible aun sin centro inicial y permite tocar el mapa.
El punto seleccionado usa el pin oficial compartido y muestra sus coordenadas
como ubicación manual, sin precisión GPS ficticia. La pantalla aplica ese punto
a la búsqueda real de casos mediante el ViewModel existente. El motivo del fallo
se muestra por el toast compartido, conservando la política de feedback.

MapAttribution muestra siempre el crédito OpenStreetMap y solo añade CARTO
cuando corresponde al proveedor. ZoneMapPicker y MapCaseSheet respetan la
visibilidad solicitada sin condicionar el crédito OSM a CARTO. La configuración
local de esta copia usa https://tile.openstreetmap.org/{z}/{x}/{y}.png;
no se versionan secretos ni se cambia el proveedor del proyecto original.

## Integración con el punto 2

Integración realizada con el commit 4245c8b del punto 2 (cherry-pick bb1dcba).
La pantalla conserva su seguimiento y consume la lectura actual; errores dejan
ubicación nula y habilitan selección manual. Los párrafos siguientes describen
el contrato acordado durante el desarrollo.

El punto 2 mantiene la propiedad del repositorio GPS, watch(), sus límites,
timeout y cancelación. Tras integrar ambos commits, en ExploreMapScreen conservar
su provider/lifecycle/aviso y conectar:

```dart
currentLocation: location.hasError ? null : location.asData?.value,
locationUnavailable: location.hasError,
```

Conservar onManualLocationSelected del punto 3, que aplica el centro a la búsqueda.
No usar data.currentLocation como fallback tras error del seguimiento.
En la rama independiente se usa data.currentLocation y su ausencia para permitir
probar el flujo puntual del punto 1 sin copiar el seguimiento todavía no confirmado.

## Validación y evidencias

Cierre local: 30 pruebas integradas aprobadas y análisis sin incidencias; APK
debug conjunto compilado e instalado en emulator-5554. Se obtuvo lectura GPS
-18.006598, -70.246300 con etiqueta Precisión ± 64 m y círculo visible tras zoom.
Teselas OSM reales y atribución visibles. Después se apagó la ubicación global,
se abrió el mapa y se tocó un punto: pin manual -11.988067, -77.042800 sin círculo
ni precisión GPS, con aviso «Activa la ubicación del dispositivo». ADB confirmó
is-location-enabled=false. Al terminar se restauró a true y posición de Tacna.
Capturas reales de dispositivo y VS Code en docs/evidencias/examen-u2-punto-3.

Documento combinado corregido: SI988-EXPRAC-U2-ColquePonceSergioAlberto.pdf,
15 páginas con una sola carátula y puntos 1, 2 y 3. Copias Word propias preservan
los documentos del otro chat. No incluye desarrollo de puntos 4–5.

### Validación previa e historial

43 pruebas aprobadas de mapa/precisión/selección manual, recorrido de pantalla,
arquitectura, consistencia, retina y Recorrido; análisis Flutter sin incidencias.
Las cinco pruebas específicas comprueban radio en metros, coordenadas, crédito,
pantalla pequeña/texto200%/reducido, ocultamiento de lectura obsoleta, toque real
del mapa, ausencia inicial de GPS y consulta de casos por el punto manual.
Renders de pruebas con teselas neutras son QA y no evidencia nativa del examen.

APK debug compilado; pendiente instalación del build final, integración con el
commit del punto 2 y dos capturas reales cuando el emulador quede libre. No se
declara completo el punto 3 hasta verificarlos. Capturas de código también pendientes.
Word propio: SI988-EXPRAC-U2-ColquePonceSergioAlberto-punto-3.docx.
Logs locales en apps/mobile/build/examen-punto3; no se toca el Word del otro chat.
