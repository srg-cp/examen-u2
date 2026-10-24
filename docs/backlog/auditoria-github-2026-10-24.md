# Auditoría de GitHub — 24 de octubre de 2026

Revisión autorizada por el usuario de los 51 issues originales/derivados y del
tablero EntreHuellas. Se contrastan criterios, estado remoto, fuentes integradas,
PR y fichas funcionales. Esta auditoría no equivale a ejecutar de nuevo las demos
de todas las funcionalidades. Las notas históricas no sustituyen el estado actual.

## Historias que cumplen el cierre

- **HU-15.1 / #47:** SQLite privado por cuenta, UUID estable, campos parciales y
  evidencia conservados. Smoke WRITE→force-stop→READ offline, diez comprobaciones
  SQLite nativas y guardar/retomar desde la app normal en Android emulado.
  [Ficha y límites](../funcionalidades/borradores-locales.md).
- **HU-15.2 / #48:** cola persistente, estados veraces, sincronización automática,
  recibos y aislamiento. 575 pruebas Flutter, análisis limpio, 56 SQL locales,
  seis integraciones reales con cuentas A/B y servidor de desarrollo; diez
  comprobaciones SQLite nativas. Se comprueban respuesta perdida tras commit,
  mismo UUID sin duplicados, contenido incompatible, revocación y cambio de
  identidad. Ciclo de app normal sin red→force-stop→reabrir→recuperar red→publicar.
  Parches 037/038 aplicados por el usuario y comprobados remotamente.
  [Ficha y reproducción](../funcionalidades/envios-pendientes.md).

La integración en main se tramita por PR con cierre de #47/#48. No se acredita
teléfono físico ni reinicio completo de Android: se probó reinicio del proceso
en emulador Pixel_9a/API36/x86_64. No se vuelve a aplicar SQL ni se despliega
backend por esta auditoría. Los logs privados y la configuración de cuentas
permanecen fuera de Git; las herramientas reproducibles se incluyen en el PR.

## Issues abiertos que conservan trabajo pendiente

| Issues | Resultado de la revisión / criterio pendiente |
| --- | --- |
| #19 | Google: retorno OAuth Android con app abierta/cerrada, cancelación y sesión válida; no basta abrir navegador. |
| #24, #25 | Baja y exportación de cuenta: entregas pendientes; no confundir edición de perfil con estas operaciones. |
| #34, #35 | Carteles integrados: falta impresión y escaneo desde otro teléfono; guardar/compartir/cancelar en las hojas nativas Android. El lector web ya existe. |
| #40, #41 | Seguimiento y bandeja implementados, 027 confirmado. Falta demostrar en backend real destinatarios/evento, persistencia, lectura y permisos entre cuentas. FCM no bloquea por sí solo estas derivadas. |
| #42 | Push FCM pospuesto explícitamente por ADR-068; no marcar como implementado ni activar emisor/cron. |
| #13 | Cierre implementado y 028 confirmado. Falta demo remota de autorización/concurrencia, QR actualizado, rechazo de nuevos avistamientos y nuevo episodio. |
| #43 | Denuncias implementadas y 029 confirmado. Falta demo remota de evidencia privada, deduplicación y permisos de denunciante/autor/ajeno/revisor. |
| #44 | Bloqueos implementados e integrados. Pendientes activación/verificación 034/036 y demo remota A/B, contactos/fotos y concurrencia. Alcance ya acordado; retirar needs:refinement. |
| #45 | Moderación web implementada y 030 confirmado. Falta verificar configuración/rol y demo con revisores reales, cuenta ordinaria y concurrencia. |
| #46 | Apelaciones implementadas e integradas. Pendientes activación/verificación 035 y demo de autor/ajeno/revisor reales, historial y reintentos. |
| #49 | Caché offline de fichas HU-15.3 sin implementar; siguiente incremento funcional. Guardar una ficha online no demuestra caché offline. |
| #50, #51 | Estadísticas y controles administrativos sin implementar; #51 requiere acordar funciones controlables. |
| #1, #8, #12, #14, #15, #16 | Épicas abiertas: tienen derivadas pendientes. #15 conserva #49 aunque cierren #47/#48. |

Las historias #43–#46 y las épicas #14/#15 pasan a In progress, conservando
pendientes concretos. #47/#48 pasan a Done tras integrar y verificar CI. Se
sincronizan etiqueta status y campo Status nativo del tablero para los 51 issues.

## Cierres previos contrastados

Ya estaban cerrados con status:done **27 issues**:
#2, #3, #4, #5, #6, #7, #9, #10, #11, #17, #18, #20, #21, #22,
#23, #26, #27, #28, #29, #30, #31, #32, #33, #36, #37, #38 y #39.
Las fichas y auditoría anterior registran integración/aceptación; no se detecta
otra entrega completa abierta además de #47/#48. #5/#6/#9 tienen criterios
aceptados y cerrados, pero cuatro casillas técnicas antiguas cada uno siguen
vacías: se sincronizan sin atribuirles una demo nueva.

Resultado previsto tras integrar: **29 cerrados y 22 abiertos**, contando épicas
y derivadas por separado. No son 29 funcionalidades independientes ni un
porcentaje de avance del MVP. Los cierres anteriores conservan sus límites de
validación documentados; esta revisión no certifica todas las funciones en remoto.
