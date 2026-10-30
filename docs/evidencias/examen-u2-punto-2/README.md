# Evidencias del punto 2 del examen tipo 1

Capturas reales del entorno local,30/10/2026, rama feature/examen-u2-punto-2.
Solo punto2. Las capturas de código muestran selecciones reales de VS Code;
el Word usa recortes de estas imágenes para facilitar su lectura, sin alterar código.

- 01: precisión media e intervalo/distancia nativos.
- 02: filtro que exige simultáneamente30s y50m.
- 03 y03b: timeout inicial de10s y texto exacto del aviso.
- 04,04b y04c: cancelación de escucha/temporizador y llamada al salir del mapa.
- 05 y06: mapa de la versión final instalada y pantalla tras abandonarlo.
- 07: consola real con Logcat; no se insertaron mensajes de cancelación simulados.

`logcat.txt`: registro de PID9385; actualización iniciada21:24:00.227,
GPS detenido21:24:51.950 y actualizaciones nativas detenidas21:24:51.951,
en la hora que registra el emulador. El mensaje posterior del plugin sobre el
engine conectado no indica una escucha activa: el plugin confirma que las
actualizaciones de posición quedaron detenidas. No se apaga el GPS global.

`pruebas.txt`:29 pruebas aprobadas, incluyendo límites, timeout, descarte de
coordenadas antiguas y cancelación. `analisis.txt`: sin incidencias.
`compilacion.txt`: APK debug generado; instalado en emulator-5554 con respuesta Success.
Java solo en la sesión: JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\Temp\eh-java.

Comando de pruebas, desde apps/mobile:

```powershell
flutter test --no-pub test/examen_location_tracking_test.dart test/examen_map_location_screen_test.dart test/current_location_test.dart test/explore_filter_draft_test.dart test/explore_map_test.dart test/architecture_test.dart --reporter expanded
```

Word propio en raíz: SI988-EXPRAC-U2-ColquePonceSergioAlberto-Punto2.docx.
Cuatro páginas revisadas con el render nativo de Word. Incorporar su apartado
al documento final único del examen; no es el examen completo ni desarrolla3–5.
Validación docente en tiempo real y envío al Aula Virtual a cargo del estudiante.
