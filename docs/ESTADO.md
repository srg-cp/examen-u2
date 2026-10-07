# Estado del proyecto

Última actualización: 7 de octubre de 2026, America/Lima.

## Hechos comprobados

- Carpeta actual: `C:\Users\Administrator\Documents\projects\entreHuellas`.
- Comprobación inicial del chat 00: `main`, commit de partida `8c5fdee` (`init`), árbol limpio. El proyecto ya tenía commits y una app Flutter multiplataforma con una pantalla `Hello World!`; el estado previo del 4 de octubre quedó desactualizado.
- La app se conserva en `flutter_application_entrehuellas`, según la decisión de ubicación del 6 de octubre de 2026. No se creó `apps/mobile` ni se regeneraron las plataformas.
- Flutter 3.35.3 stable / Dart 3.9.2. No se actualizó el SDK.
- `flutter doctor`: Android SDK 36.1.0-rc1, Command-line Tools ausentes y licencias de estado desconocido. `flutter devices`: Windows, Chrome y Edge; ningún Android conectado.
- Identificador Android conservado: `com.example.flutter_application_entrehuellas`, provisional. El proyecto mantiene firma debug para release; distribución pendiente.
- No se consultó ni modificó el remoto en esta tarea. No se realizaron commit, push, issues, PR ni despliegues.

## Completado

- Chat **00 - Proyecto y estructura**: preparación local de arquitectura. No corresponde al cierre de HU-01 / RF-01,34.
- Clean Architecture por funcionalidad con `presentation`, `domain` y `data`. Entidad/contrato de sesión independientes del SDK, repositorios y fuentes de datos inyectados, casos de uso y estado de presentación.
- Riverpod 3.3.2, go_router 17.2.3 y supabase_flutter 2.18.0, resueltos con el SDK instalado y registrados en `pubspec.lock`. Se conservaron los registros de plugins generados para macOS/Windows.
- Inicio, tema Material 3, pantalla de acceso y navegación `/` -> `/access` con regreso. Rutas desconocidas permiten volver al inicio sin mostrar la URL.
- Bootstrap valida configuración pública e inicializa Supabase con PKCE antes de montar Riverpod. Estados explícitos: falta configuración, configuración inválida, fallo de arranque y SDK preparado. Este último no acredita conectividad ni credenciales remotas válidas.
- `AuthViewModel` observa cambios de identidad mediante `WatchAuthSession` y el contrato del repositorio; las pantallas no llaman al SDK. Identidad de sesión sin tokens en `domain/entities`.
- Configuración vía `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`, usando `--dart-define-from-file`. Ejemplo vacío en `config/supabase.local.example.json`; `config/supabase.local.json` comprobado como ignorado por Git. Solo se aceptan URL HTTPS y claves `sb_publishable_...`.
- Android registra INTERNET y `entrehuellas://login-callback/`. iOS registra el esquema. Manejador de deep links de Flutter desactivado en ambos para que Supabase/app_links gestione Auth sin duplicar el callback en go_router.
- CI local preparado en `.github/workflows/flutter.yml`, Flutter 3.35.3, formato/análisis/tests y lockfile. No ejecutado en GitHub.
- Actualizados AGENTS, README, arquitectura y guía para conservar la ubicación existente. Añadida `docs/CONFIGURACION.md` con preparación de Supabase y pruebas móviles pendientes. Las plantillas previas se conservaron.

## Refuerzo de la base, 7 de octubre de 2026

- Se estableció una estructura de arquitectura común para el MVP y los incrementos posteriores: operaciones de dominio mediante casos de uso, entidades y contratos independientes de UI/backend. La decisión quedó registrada en AGENTS, arquitectura y guía.
- Se conservó `main`, todo el trabajo local del chat anterior y `.vscode/settings.json` existente. No hubo commit/push ni cambios de infraestructura.
- `AuthSession` se organizó en `domain/entities`, `AuthRepository` en `domain/repositories` y se añadió `domain/use_cases/WatchAuthSession`. El caso de uso elimina identidades consecutivas repetidas, mantiene transiciones y propaga errores. Se actualizaron los imports y la inyección de Riverpod.
- Se añadió prueba de dependencias arquitectónicas para imports/exports de dominio y acceso directo desde presentación a data/SDKs. Se probaron deduplicación de identidad, cambio de usuario, cierre/reentrada y propagación de errores.
- Se detectó que `config/supabase.local.json` ya existe, sin leer ni modificar sus valores. Se añadieron perfiles de VS Code para desarrollo local y sin Supabase, abriendo la raíz o la carpeta Flutter; sin credenciales en launch.json. JSON y rutas de entrada comprobados. F5 interactivo no ejecutado.
- Validación del refuerzo: `dart format lib test` completado (20 archivos), `flutter analyze --no-pub` sin incidencias, `flutter test --no-pub`: **15 pruebas aprobadas** y `git diff --check` correcto. No se repitió build web; la compilación anterior consta debajo. Android y Supabase remoto siguen pendientes.

## Revisión de presentation y data, 7 de octubre de 2026

- Se mantuvieron la rama `main`, todos los cambios previos, configuración local y plataformas existentes. No se leyeron valores de configuración ni se realizaron acciones GitHub.
- Presentation se organizó en `screens`, `view_models`, `state` y `widgets`. `AccessScreen` observa solo `AuthViewModel`, que entrega `AuthViewState` con arranque y AsyncValue de sesión. Los mensajes de UI se trasladaron de core a presentación. Home sigue sin ViewModel porque no tiene operaciones ni datos de negocio.
- Data se organizó en `data_sources`, `models` y `repositories`. `SupabaseAuthDataSource` encapsula el SDK y expone DTO sin tokens; `AuthRepositoryImpl` transforma DTO a entidades y errores síncronos/de stream a `AuthFailure`. El repositorio puede seguir observando después de un error.
- Declaraciones DI de auth en `features/auth/providers/auth_providers.dart`, sin dependencias de data/presentation. `main` y bootstrap inyectan implementaciones. Se retiró `app/providers.dart`; presentación ya no depende de app. Arranque no configurado evita resolver/observar auth.
- ViewModel/stream de sesión usan autoDispose. Se desactivó el reintento automático del provider de stream; la recuperación mediante un evento posterior conserva la suscripción. El caso de uso transmite cancelación/pausa/reanudación y mantiene historial independiente por suscripción.
- Las pruebas detectaron un fallo en la deduplicación previa con `distinct`: después de un error se descartaba una identidad igual a la última válida. Corregido y comprobado tanto para sesión activa como para sesión nula. El error se muestra sin presentar una identidad obsoleta como estado válido.
- Reglas arquitectónicas ampliadas a presentation/data/providers, incluyendo directivas condicionales y `part`. La revisión de directivas complementa el análisis, no sustituye una auditoría completa de símbolos/transitividad.
- Validación: formato correcto (30 archivos), `flutter analyze --no-pub` sin incidencias y `flutter test --no-pub`: **26 pruebas aprobadas**. Incluyen mapeo/error/continuación/cancelación del repositorio, estados y ciclo de vida del ViewModel, recuperación tras errores, suscripciones independientes, adaptador con estado local del SDK y layout 320×350 con escala de texto 2.
- `flutter build web --no-pub`: correcto tras la reorganización; dry run Wasm correcto y mismo aviso no bloqueante de CupertinoIcons ausente. `git diff --check`: correcto.
- Las pruebas del adaptador usan sesión ficticia almacenada solo en el SDK local; no acreditan autenticación remota. No se modificaron dependencias ni se implementó HU-01. Android y Supabase remoto continúan pendientes.

## Validación de la base del 6 de octubre de 2026

Desde `flutter_application_entrehuellas`:

- `flutter pub get --enforce-lockfile`: correcto.
- `dart format --output=none --set-exit-if-changed lib test`: correcto, 17 archivos sin cambios después del formato inicial.
- `flutter analyze`: sin incidencias.
- `flutter test`: **12 pruebas aprobadas**. Cubren arranque sin backend, rechazo de configuración parcial/HTTP/credenciales en URL/query/claves secretas/JWT, navegación y regreso, propagación de sesión y errores desde un repositorio sustituido, estados inválido/fallido y ruta desconocida.
- `flutter build web --no-pub`: correcto; también pasó el dry run Wasm. Aviso no bloqueante sobre fuente CupertinoIcons ausente. Este build de la app Flutter no implementa la web pública QR de S4.
- Manifiesto Android e Info.plist iOS parseados como XML correctamente. Esto no acredita la resolución del enlace en un dispositivo.
- `git diff --check`: sin errores de whitespace. Git avisa de conversión futura LF/CRLF por configuración local.

Las pruebas de sesión usan un repositorio sustituido; no equivalen a acceso contra Supabase. No se ejecutó la app en teléfono/emulador ni en navegador interactivo.

## Norma de arquitectura, 7 de octubre de 2026

- Creado `docs/REGLAS_ARQUITECTURA.md` como norma del sistema: Clean Architecture por funcionalidad, MVVM, Repository, Adapter, casos de uso, inyección, estado inmutable y SOLID.
- Define responsabilidades de presentation/domain/data/providers/composición, dependencias permitidas/prohibidas, calidad por responsabilidades sin límites arbitrarios de líneas, manejo de errores/streams, seguridad y criterios de revisión. Los cambios de reglas se registran como decisiones versionadas.
- Lectura incorporada a AGENTS y enlaces añadidos desde README, arquitectura y guía. Se conservó la app y todo el trabajo local previo en `main`; esta tarea modifica solo documentación.
- Validación documental: coherencia con la implementación actual, enlaces locales y `git diff --check`. No se repitieron pruebas/builds Flutter; la última evidencia de código sigue siendo 26 pruebas aprobadas y build web correcto, descrita arriba. Los controles automáticos existentes son parciales y se complementan con revisión.
- Siguiente paso: aplicar esta norma al implementar HU-01 y mantener las comprobaciones arquitectónicas. Android y Supabase remoto continúan pendientes.

## Documentación de la decisión arquitectónica, 7 de octubre de 2026

- Añadido `docs/decisiones/001-arquitectura-aplicacion.md` (ADR-001) con contexto, decisión, motivos, alternativas y consecuencias. Relaciona las capas con los recorridos de recuperación, datos públicos/privados, pruebas y la incorporación prevista de almacenamiento local.
- README general, arquitectura, reglas, guía y AGENTS describen Clean Architecture por funcionalidad con MVVM, casos de uso, repositorios, adaptadores e inyección. La configuración describe el recorrido de sesión actual. Se conservaron los registros históricos y sus resultados de validación.
- Sustituido el README genérico de Flutter por instrucciones de desarrollo, configuración, comprobaciones y referencias de arquitectura. Las plantillas de historia/PR incluyen la norma y el registro de cambios arquitectónicos.
- La documentación distingue la base de sesión implementada de los flujos previstos de mascotas, recuperación y almacenamiento local. El registro de decisión incluye los costos de los contratos/mapeos y los límites de una futura sustitución del backend.
- Validación: enlaces locales y coherencia de referencias revisados, `git diff --check` sin errores. Cambios solo documentales; no se repitieron pruebas Flutter. Se conservó el trabajo local en `main` sin acciones GitHub ni configuración remota.

## Organización de la base de datos, 7 de octubre de 2026

- Estado de partida de esta tarea: rama `main`, commit `8503fa3` (`feat: Initialize Supabase and set up authentication structure`), árbol limpio antes de editar. Se conservaron los archivos existentes.
- Confirmado `config/supabase.local.json`: JSON y formato de URL HTTPS/clave publicable compatibles con AppConfig, sin mostrar ni modificar valores. Archivo ignorado por Git. Esto no verifica credenciales remotas ni autenticación.
- Creado `database` con 11 directorios versionables: extensions, types, tables, indexes, functions, triggers, views, policies, grants, seeds y tests. Su README define numeración global `001_...sql`, dependencias, separación de datos de prueba y conservación del SQL aplicado. No se crearon objetos de base de datos ni scripts SQL ficticios.
- ADR-002 registra la organización por objeto y la generación prevista de migraciones de Supabase a partir de las fuentes. Actualizados AGENTS, README, arquitectura, reglas, guía y configuración. El procedimiento de generación se debe implementar y comprobar en S1 antes del primer despliegue.
- Validación: directorios y enlaces locales comprobados, `git diff --check` correcto y protección Git de la configuración local confirmada. No hay SQL nuevo que ejecutar; no se realizaron pruebas de permisos ni se repitieron pruebas Flutter. Supabase CLI y psql no se encontraron en PATH.
- No se ejecutó SQL local/remoto ni se modificó el proyecto Supabase. No hubo commit, push o despliegue en esta tarea.
- Siguiente paso: S1 / HU-01, definir el primer esquema y sus políticas en database, preparar generación/migración y probar permisos con dos usuarios antes de aplicarlo al entorno de desarrollo autorizado.

## Pendiente

- Completar herramientas Android y revisión de licencias. Build APK y ejecución Android **no verificados**; faltan herramientas y dispositivo. iOS no compilado en Windows.
- Verificar el proyecto Supabase de desarrollo configurado en el JSON local y registrar el retorno exacto en Authentication > URL Configuration > Redirect URLs. El archivo local está completado y su formato fue validado; no se verificó ni cambió configuración en Dashboard.
- Probar retorno con app abierta/cerrada y luego correo/OAuth real en S1. No se verificó autenticación ni restauración remota de sesión.
- Implementar HU-01 / RF-01,34: registro/correo/Google, perfil, cierre de sesión, gestión de cuenta; fuentes SQL en database, generación de migraciones/grants/RLS y permisos entre dos usuarios. No hay esquema ni políticas nuevas en esta entrega.
- Revisar identificadores definitivos, firma y requisitos de distribución antes de publicar una app.
- Publicar cambios y ejecutar CI remoto solo cuando la tarea autorice acciones GitHub.

## Siguiente chat

Completar validación Android del chat **00** siguiendo `docs/CONFIGURACION.md`, y continuar con **01 - Acceso y cuenta**, HU-01 / RF-01,34. La base local está preparada; el criterio de salida Android del chat 00 sigue pendiente.

Al iniciar, comprobar Git y herramientas de nuevo y conservar los cambios locales de esta entrega. Usar el prompt de S1 de `docs/GUIA_MVP.md` sin recrear la app.
