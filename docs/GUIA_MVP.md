# Entre Huellas: guía de proyecto, chats, sprints y GitHub

Fecha: 4 de octubre de 2026. Repositorio: https://github.com/srg-cp/entrehuellas.

Esta es la guía del MVP acordado: **Flutter + Supabase**, con Clean Architecture por funcionalidad, MVVM, Riverpod, casos de uso y repositorios. Adapta los sprints S1-S6 y las historias HU-01 a HU-16 del plan maestro v2. La API ASP.NET Core queda como evolución opcional. [ADR-001](decisiones/001-arquitectura-aplicacion.md) registra los motivos y las alternativas de esta organización.

Cada sprint debe cumplir [REGLAS_ARQUITECTURA.md](REGLAS_ARQUITECTURA.md), norma compartida de patrones, dependencias y SOLID. El alcance funcional del sprint no modifica esos límites.

## 1. Cómo dividir el trabajo entre chats

Recomendación: **un chat de coordinación, un chat de configuración y un chat por sprint**. Abrir un chat adicional por una historia grande solo cuando necesite una investigación o implementación independiente.

| Chat | Propósito | Resultado |
| --- | --- | --- |
| Coordinación | Este chat: alcance, arquitectura, prioridades y decisiones. | Documentación coherente y próximo incremento definido. |
| 00 - Proyecto y estructura | Herramientas, app Flutter, carpetas, GitHub y CI. | Base ejecutable y documentada. |
| 01 - Acceso y cuenta | S1, HU-01. | Sesión y perfil con permisos. |
| 02 - Mascotas y zonas | S2, HU-02 a HU-04. | Mascotas, fotografías y preferencias. |
| 03 - Perdidos y encontrados | S3, HU-05 a HU-07. | Casos en lista y mapa con filtros. |
| 04 - QR y avistamientos | S4, HU-08 a HU-10. | Colaboración desde el navegador sin instalar. |
| 05 - Seguimiento y recuperación | S5, HU-11 a HU-13. | Cronología, alertas y cierre. |
| 06 - Validación del MVP | S6, HU-14 a HU-16. | Moderación, offline, métricas y demo. |

Estos nombres son una propuesta de organización; la guía no crea chats automáticamente. Seleccionar el mismo proyecto/carpeta al abrir cada chat nuevo.

Mantener los archivos como registro compartido. Codex puede cargar instrucciones del proyecto desde `AGENTS.md`; las decisiones y avances que necesita el siguiente chat deben quedar escritos, sin depender de que tenga el historial anterior. [Instrucciones de proyecto en Codex](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

Trabajar de forma secuencial inicialmente: cerrar y validar el incremento anterior antes de comenzar uno dependiente. Si dos chats necesitan editar a la vez, usar ramas y worktrees separados; una rama diferente en la misma carpeta no crea dos copias independientes de los archivos. [Worktrees en Codex](https://learn.chatgpt.com/docs/environments/git-worktrees).

## 2. Qué construimos primero

El recorrido del MVP es:

1. El usuario inicia sesión y registra una mascota.
2. Publica un caso perdido o encontrado con fotos, hora y zona.
3. Comparte un cartel con QR.
4. Un ciudadano abre la web y reporta un avistamiento.
5. El responsable recibe ayuda en su bandeja, revisa evidencia y cierra el caso.
6. El QR muestra el estado actualizado, con moderación y manejo de conectividad.

Además: preferencias de zonas, datos públicos separados de privados, gestión de cuenta, auditoría y métricas mínimas. Chat completo, salud, cuidadores compartidos, refugios, adopciones, reservas e IA se planifican después del MVP.

Los seis sprints son una secuencia de entregas. Si se conserva la duración de dos semanas del plan, representan doce semanas referenciales. La fecha de entrega y la capacidad semanal todavía deben confirmarse; el chat 00 es preparación, no una promesa de plazo adicional fijo.

## 3. Estado de partida histórico (4 de octubre de 2026)

- Git estaba inicializado. Se configuró `origin` y la rama local `main`.
- El repositorio remoto respondió sin referencias al consultarlo: vacío en esa comprobación.
- La documentación de arranque está creada. Todavía no hay app Flutter ni configuración Supabase.
- Flutter 3.35.3 y Dart 3.9.2 están instalados. No se cambió su versión.
- Para Android faltan Command-line Tools y revisar/aceptar las licencias del SDK.
- GitHub CLI no está en PATH. Se puede trabajar con Git y la interfaz web.
- No se realizaron commit, push, creación de issues, despliegues ni configuración de cuentas externas durante la preparación de esta guía.

## 4. Chat 00: proyecto y estructura

La app existente se conserva en `flutter_application_entrehuellas`, según la decisión del 6 de octubre de 2026. Esa carpeta reemplaza la ubicación propuesta `apps/mobile`. La estructura utiliza `presentation`, `domain` y `data` por funcionalidad, con MVVM y Riverpod. La base de navegación y configuración está implementada; consultar [ESTADO.md](ESTADO.md) para validación real y [CONFIGURACION.md](CONFIGURACION.md) para comandos y deep links. La sección anterior conserva el estado histórico de la preparación.

Orden de trabajo:

Decisión del 7 de octubre de 2026: mantener una base de arquitectura sólida independientemente del alcance MVP. Dominio organiza `entities`, `repositories` y `use_cases`; los ViewModels consumen casos de uso y data implementa los contratos. Se prepara ejecución F5 con configuración local para no repetir argumentos durante el desarrollo. No se amplía el alcance funcional de HU-01 ni se añaden servicios al backend.

Revisión de presentation/data del mismo día: presentación organiza screens/view_models/state/widgets y observa un estado único; data separa data_sources/models/repositories, encapsula el SDK y transforma fallos en errores de dominio. Providers declaran contratos y bootstrap inyecta implementaciones. Añadir pruebas de recuperación tras error y liberación de suscripciones a los criterios técnicos de cada flujo observable. Detalles en [ARQUITECTURA.md](ARQUITECTURA.md).

La base de Inicio y Acceso incorpora la dirección visual de [DISENO_UI.md](DISENO_UI.md): tarjetas redondeadas, marca, ilustración y acciones principales. El acceso se ajustó después al mockup de login e incorporó correo/contraseña y Google, con SQL de perfiles preparado. Registro y recuperación están implementados localmente; edición de perfil y validación remota siguen pendientes en HU-01; los demás recorridos se incorporan en sus sprints.

1. Leer `AGENTS.md` y los documentos; comprobar Git y conservar los archivos existentes.
2. Completar el entorno Android. En Android Studio, abrir SDK Manager y revisar SDK Tools: instalar **Android SDK Command-line Tools**, comprobar Platform-Tools, Build-Tools y una plataforma compatible. El usuario revisa los términos con `flutter doctor --android-licenses`. Volver a ejecutar `flutter doctor` y detectar un teléfono o emulador. [Configuración Android oficial](https://docs.flutter.dev/platform-integration/android/setup).
3. Elegir una versión de Flutter y dependencias compatibles. La instalada es un punto de partida; cualquier actualización se evalúa y documenta.
4. Conservar la app existente en `flutter_application_entrehuellas` y organizar `lib/app`, `lib/core` y funcionalidades con `presentation`, `domain` y `data`. Revisar el identificador Android provisional antes de distribuir.
5. Incorporar inicialmente Riverpod, go_router y supabase_flutter. Añadir Drift/SQLite cuando se implemente el almacenamiento local. Cada paquete debe resolver una necesidad concreta.
6. Preparar configuración con ejemplos sin credenciales. Verificar la app con una pantalla inicial y estado explícito de configuración si Supabase aún no existe.
7. Crear CI con formato, análisis y pruebas pertinentes. Documentar los comandos y fijar la versión de Flutter usada por CI.
8. Revisar los archivos, realizar el primer commit y publicar la base cuando la solicitud de ejecución incluya esas acciones.

La app ya existe: no ejecutar `flutter create` sobre ella. Para trabajar desde la raíz:

```powershell
Set-Location flutter_application_entrehuellas
flutter pub get --enforce-lockfile
```

El identificador conservado es `com.example.flutter_application_entrehuellas`; sigue pendiente elegir el definitivo antes de distribuir.

**Criterio de salida:** app inicial ejecutada en Android, estructura comprensible, versión registrada, comprobaciones pertinentes pasando y procedimiento para configurar Supabase documentado. Si Android sigue bloqueado, registrar lo que se verificó por otra vía y mantener el build Android pendiente.

### Prompt listo para pegar en el chat 00

```text
Configura el proyecto Entre Huellas en la carpeta local de este proyecto.
Lee AGENTS.md, docs/ARQUITECTURA.md, docs/ESTADO.md y la sección 4 de docs/GUIA_MVP.md.

El repositorio es https://github.com/srg-cp/entrehuellas. Origin y la rama main ya fueron configurados; compruébalos sin volver a clonar encima de la carpeta.

Continúa sobre la app Flutter existente en flutter_application_entrehuellas. Lee docs/REGLAS_ARQUITECTURA.md y conserva las capas presentation, domain y data por funcionalidad, MVVM, Riverpod, casos de uso, repositorios, go_router y supabase_flutter. Mantén Supabase como backend del MVP. Prepara configuración de ejemplo sin secretos, el deep link entrehuellas://login-callback/ y CI para formato, análisis y pruebas pertinentes.

Revisa Flutter y Android. Ya se detectaron Command-line Tools y licencias pendientes. Ayúdame a resolver los pasos que requieran mi intervención mientras avanzas con lo independiente. Registra la versión de SDK y el identificador Android elegidos.

Implementa y verifica una pantalla inicial. Conserva la documentación existente. Cuando las comprobaciones pertinentes pasen, realiza el primer commit y publícalo en mi repositorio; no despliegues servicios. Si la autenticación bloquea el push, deja el commit listo y explica el paso pendiente sin pedir credenciales en el chat.

Actualiza docs/ESTADO.md con cambios, pruebas, bloqueos y el siguiente paso. Indica si la ejecución/build Android fue realmente verificada.
```

## 5. Sprints e historias del MVP

El alcance implementado y el funcionamiento de cada módulo se consultan en
[Funcionalidades](funcionalidades/README.md). Mantener sus fichas en cada
incremento, incluyendo reglas, persistencia, errores, activación y validación;
la existencia de una ficha no implica cierre de la HU ni ampliación del MVP.

Se conserva la numeración original para relacionar implementación, informe académico y pruebas. El chat 00 prepara la base técnica que el plan original situaba dentro de S1.

### S1 - Acceso y cuenta

- Dirección visual obligatoria: [REGLAS_UI_UX.md](REGLAS_UI_UX.md), basada en acceso/cuenta/OTP/contraseña aprobados. Retirado Inicio anterior; destino provisional conserva bienvenida y cierre real, sin ampliar funcionalidades.

- **HU-01 / RF-01,34:** acceso por correo/Google, sesión, perfil y gestión de cuenta. Inicio válido crea o recupera un único perfil; otro usuario no puede editarlo. Solicitud de baja trazable y exportación básica de los datos del usuario según el alcance acordado.
- Crear o identificar el proyecto Supabase de desarrollo, configurar Auth y versionar esquema, permisos y migraciones. Las fuentes SQL se organizan en `database` según [su convención](../database/README.md); preparar la generación ordenada de migraciones antes del primer despliegue.
- Comprobar sesión inválida, cierre de sesión y acceso cruzado con dos cuentas. Resolver los enlaces de retorno/confirmación de correo necesarios para Android.
- **Demo:** entrar, ver perfil, cerrar sesión y verificar permisos.
- Onboarding actualizado el 8 de octubre: sin Omitir, tres indicadores de progreso y botón de ancho completo con flecha. La cuenta pendiente entra a la app tras Comenzar en la tercera etapa; un fallo de guardado permite reintentar. Se conservan finalizaciones anteriores.
- Incremento de registro: Crear cuenta desde login, validar cuatro campos, registrar con Supabase Auth, confirmar por código de seis dígitos o recibir sesión si Auth autoconfirma, reenviar con espera de 60 segundos y entrar al onboarding solo con sesión. Sin casilla de Términos/Privacidad hasta contar con documentos, por decisión del usuario. Implementación local preparada; validar entrega SMTP y callback real en Android antes de dar por cerrado HU-01.
- Incremento de recuperación, 8 de octubre: desde ¿Olvidaste tu contraseña?, solicitar código por correo, mostrar seis casillas sin revelar existencia de cuenta y reenviar tras 60 segundos. La verificación OTP de recuperación abre Nueva contraseña antes de onboarding/Inicio; valida contraseña/confirmación y política del servidor. Guardar muestra éxito; al regresar o cancelar se cierra la sesión de recuperación. Implementación y pruebas locales; quedan SMTP, verificación real de códigos leídos en PC e introducidos en Android, códigos vencidos y reingreso con contraseña nueva. Sin nuevas tablas.

Prompt:

```text
Implementa S1 de Entre Huellas según docs/GUIA_MVP.md: HU-01, RF-01 y RF-34. Lee AGENTS.md y docs/ESTADO.md. Usa Supabase Auth y repositorios; versiona esquema y políticas. Implementa cuenta y sesión con criterios verificables. Si faltan URL/configuración del proyecto, solicita solo lo necesario y avanza con código, migraciones y pruebas independientes. Actualiza el estado con la demo y la validación real.
```

### S2 - Mascotas, fotos y zonas

- **HU-02 / RF-02,16:** guardar zonas, radio y preferencias; admitir selección manual con GPS denegado y conservarlas tras reiniciar.
- **HU-03 / RF-03:** registrar y editar una mascota propia con los campos mínimos; acceso de otro usuario rechazado.
- **HU-04 / RF-03:** gestionar fotos, principal y miniaturas; controlar formato/tamaño, políticas de Storage y eliminación de EXIF en los bytes públicos.
- La solución de procesamiento de fotos debe comprobarse con los límites del runtime antes de cerrar la historia. Validar al cargar desde cámara o galería y con permisos denegados.
- **Demo:** dos usuarios, mascota privada al editar, fotografía pública permitida y zona manual persistente.

Prompt:

```text
Implementa S2 de Entre Huellas: HU-02 a HU-04 y sus criterios en docs/GUIA_MVP.md. Lee las instrucciones y el estado. Crea mascotas, fotos y zonas con Supabase y permisos por propietario. Incluye alternativas cuando se deniega GPS/cámara y comprueba los bytes públicos de las fotos. Verifica acceso cruzado y persistencia. Actualiza docs/ESTADO.md con resultados y decisiones.
```

### S3 - Casos perdidos y encontrados

- **HU-05 / RF-05:** publicar perdido con fecha y zona; restricción de un caso activo por mascota y creación idempotente.
- **HU-06 / RF-06:** publicar encontrado sin propietario conocido ni `pet_id` obligatorio.
- **HU-07 / RF-13:** lista y mapa con filtros coherentes y paginación; coordenadas públicas aproximadas y datos privados protegidos.
- Seleccionar el proveedor de mapas por requisitos y condiciones; habilitar PostGIS y consultar cercanía en servidor.
- Preparar desde este sprint claves estables de envío para que S6 pueda implementar la cola local sin cambiar el contrato.
- **Demo:** publicar ambos tipos, repetir un envío, filtrar y comprobar respuestas públicas.

Prompt:

```text
Implementa S3: HU-05 a HU-07 de docs/GUIA_MVP.md. Usa repositorios, Supabase y PostGIS. Cubre perdido/encontrado, lista/mapa, filtros y paginación. Impide dos casos perdidos activos por mascota, deduplica reintentos en servidor y protege coordenadas privadas. Verifica concurrencia y privacidad, documenta el proveedor de mapas elegido y actualiza el estado.
```

### S4 - Cartel, QR y avistamientos

- **HU-08 / RF-08,37:** cartel PDF legible, QR y compartir. Se puede generar en Flutter para el MVP; conservar enlace estable y permitir reintento de la generación.
- **HU-09 / RF-09:** crear `apps/public-web` cuando haga falta; web ligera que abre el QR y muestra estado sin instalar la app. Token revocado no revela identidad privada.
- **HU-10 / RF-11:** avistamiento desde web/app con hora del evento y punto manual, foto opcional; rechazo de fecha futura y deduplicación del envío.
- El flujo público tiene permisos acotados y validación de abuso en servidor. Acordar hosting y URL estable antes de imprimir un QR que se usará fuera de pruebas.
- **Demo:** escanear en un segundo teléfono sin app y reportar; comprobar la persistencia y la separación de campos públicos/privados.

Prompt:

```text
Implementa S4: HU-08 a HU-10 de docs/GUIA_MVP.md. Crea cartel PDF/QR y una web pública ligera en apps/public-web. El visitante debe consultar y reportar sin instalar Flutter. Implementa tokens revocables, punto manual, hora observada, permisos públicos limitados, controles de abuso y reintentos idempotentes. Prepara el resultado para revisar y documenta la configuración/hosting pendiente antes de publicar. Verifica el recorrido con otro teléfono y actualiza el estado.
```

### S5 - Seguimiento, alertas y cierre

- **HU-11 / RF-12,14:** revisar avistamientos, guardar actor/motivo y ordenar cronología por hora real.
- **HU-12 / RF-17,18:** zonas/casos seguidos, selección de destinatarios, bandeja persistente y push. Persistir trabajo de notificación con mecanismo de reintento; integrar FCM mediante operación server-side.
- **HU-13 / RF-07:** responsable autorizado cierra en una operación atómica con historial; QR actualizado y nuevas alertas de búsqueda detenidas.
- **Demo:** dejar fallar el push y encontrar la alerta en bandeja; cerrar, reabrir QR y comprobar que un usuario ajeno no puede cerrar.

Prompt:

```text
Implementa S5: HU-11 a HU-13 de docs/GUIA_MVP.md. Agrega revisión/cronología, bandeja persistente, FCM y cierre autorizado. Guarda las alertas y su trabajo de envío antes del push, con reintentos y deduplicación. Valida estados en Supabase y actualiza el QR al resolver. Prueba fallo del proveedor, usuario no autorizado y cierre concurrente. Actualiza docs/ESTADO.md.
```

### S6 - Moderación, offline y validación

- **HU-14 / RF-22,23,33:** denuncia, bloqueo, ocultamiento por moderador con motivo y auditoría; vía de apelación mínima.
- **HU-15 / RF-32:** borrador y caché local con Drift/SQLite, cola de envíos y estados visibles. Cortar conexión y reiniciar no pierde el borrador; reenvío no duplica ni confirma publicación antes de respuesta del servidor.
- **HU-16 / RF-35,40:** métricas agregadas y controles administrativos mínimos, accesibles solo por roles autorizados. Definir con el usuario una interfaz mínima para esta operación.
- Probar el recorrido Android/web, permisos, reintentos, conectividad y errores principales. Ensayar recuperación de datos y archivos, preparar versión de prueba y manual de demo.
- **Demo:** recuperación completa, conexión interrumpida, moderación y métricas sin información privada.

Prompt:

```text
Completa S6 del MVP: HU-14 a HU-16 según docs/GUIA_MVP.md. Implementa moderación/bloqueo/auditoría, borradores/caché y cola SQLite, y métricas/administración mínimas. Verifica reinicio sin conexión, reenvío sin duplicados y permisos de usuario/visitante/moderador. Ejecuta el recorrido Android y web, documenta restauración y prepara distribución de prueba y demo. Corrige fallos bloqueantes y registra lo que no se verificó. Actualiza docs/ESTADO.md sin marcar completo trabajo pendiente.
```

La seguridad, pruebas y documentación acompañan cada sprint; S6 reúne la validación final.

## 6. GitHub con un flujo sencillo

Cada issue #1–#51 tiene su archivo en [backlog](backlog/README.md), con snapshot de criterios, estado y motivo. La clasificación está sincronizada entre etiquetas status y el campo Status nativo del [tablero EntreHuellas](https://github.com/users/srg-cp/projects/3/views/1). Distinguir Backlog de Ready, implementación de revisión y evidencia local de Done; actualizar tarjeta, etiqueta y documentación juntas. La sincronización inicial está comprobada y no es automática.

Usar `main` como base integrada y una rama por historia o conjunto coherente de cambios. Inicialmente no hace falta mantener una rama `develop` adicional. El repositorio local ya tiene commits; comprobar las referencias y la autenticación del remoto antes de publicar cambios. Los incrementos siguen ramas y pull requests según la autorización de cada tarea.

Crear un issue por HU y milestones S1-S6. La plantilla de historia está en `.github/ISSUE_TEMPLATE/historia.md`. No hace falta un tablero adicional para empezar; se puede añadir si mejora la coordinación.

Actualización del 8 de octubre de 2026: conservar las 16 HU originales y sus issues #1–#16. Doce pasan a historias agrupadoras; 35 derivadas HU-XX.n (#17–#51) y cuatro originales sin dividir forman 39 entregas ejecutables. Todas mantienen formato de historia de usuario y están asignadas a `srg-cp`. El [desglose versionado](BACKLOG_MVP.md) conserva RF, criterios, dependencias y validación. No sumar esfuerzo de agrupadoras y derivadas, ni reutilizar estimaciones originales como estimaciones nuevas. Cerrar una agrupadora solo después de sus derivadas y su validación integrada; los sprints siguen siendo objetivos. La reorganización no añade alcance funcional ni acredita criterios pendientes.

Precisión académica del mismo día: las 12 agrupadoras se identifican como **épicas** en GitHub; las otras 39 son **historias de usuario ejecutables** con escenarios específicos de validación. HU-XX.n es una convención documentada para conservar trazabilidad, no una exigencia universal. #44 (interacciones afectadas por bloqueo) y #51 (funciones controlables/interfaz administrativa) requieren refinamiento antes de comprometer implementación. #25 concreta la exportación básica como JSON UTF-8 de perfil y solicitudes/estados de baja propios. La prioridad se conserva como referencia de la HU original y las estimaciones deben acordarse por entrega; no se afirma adecuación a una rúbrica docente no recibida.

Ejemplos de ramas: `chore/project-setup`, `feat/hu-01-auth`, `feat/hu-05-lost-cases`, `fix/qr-revoked-token`. El número HU no es el número del issue.

Secuencia: issue con criterios -> rama -> implementación y comprobaciones -> commit -> push -> PR -> revisión -> integración. Para trabajo individual, revisar el diff y los resultados antes de integrar. [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).

Ejemplo después de tener un `main` publicado y cuando la carpeta esté limpia. Si hay cambios pendientes, resolver su destino antes de cambiar de rama:

```powershell
git status
git switch main
git pull --ff-only origin main
git switch -c feat/hu-01-auth
```

Tras implementar, seleccionar los archivos del cambio con `git add <rutas>` y revisar `git diff --cached`. Luego:

```powershell
git commit -m "feat(auth): implementar acceso y sesión"
git push -u origin feat/hu-01-auth
```

Abrir la PR en GitHub utilizando `.github/pull_request_template.md`; vincular el issue real. Integrarla cuando sus criterios y checks estén resueltos. Después actualizar `main` local antes del siguiente incremento.

El repositorio ya tiene `origin`; no repetir `git remote add` ni clonar sobre la carpeta. Antes del primer push, confirmar identidad Git y autenticación. Usar el inicio de sesión del gestor de credenciales o herramientas de GitHub; mantener tokens fuera de mensajes y archivos versionados.

Los comandos de la guía son pasos para ejecutar en los chats correspondientes; su presencia no significa que ya se ejecutaron. El primer prompt autoriza explícitamente commit/push. Las siguientes tareas deben indicar las acciones de GitHub que se esperan.

## 7. Qué debe registrar cada chat

Al empezar: leer estado y comprobar rama/archivos. Al terminar: actualizar `docs/ESTADO.md` con:

```text
Sprint / HU:
Rama y commit, si existe:
Issues / PR, si existen:
Comportamiento completado:
Migraciones y configuración:
Pruebas ejecutadas y resultados:
Pendientes o bloqueos:
Decisiones nuevas:
Siguiente paso concreto:
```

Una historia está terminada cuando sus criterios están verificados, los permisos y errores pertinentes están cubiertos, los cambios de datos están versionados y se puede demostrar el resultado. Una interfaz con datos simulados se identifica como tal; no equivale al flujo integrado.

Para trabajos de implementación con Flutter, ejecutar según corresponda desde `flutter_application_entrehuellas`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Usar `test` cuando exista; crear pruebas para comportamientos relevantes. El build Android y las pruebas en teléfono/emulador se realizan al cerrar incrementos que los requieran. Las comprobaciones del cliente no sustituyen pruebas de RLS, restricciones y RPC con usuarios distintos.

Las fuentes SQL se guardan en `database` por objeto y con numeración global; las migraciones de despliegue se generan en `supabase/migrations`, según [ADR-002](decisiones/002-organizacion-database.md). La generación está preparada mediante `database/scripts/Build-Migration.ps1`; validar migración y permisos en desarrollo antes de desplegar. Elegir en S1 el flujo posterior de CLI/entornos. El stack local completo necesita sus dependencias propias y no es condición para redactar las fuentes iniciales. [Migraciones oficiales](https://supabase.com/docs/guides/local-development/database-migrations).

## 8. Prompt para una historia independiente

```text
Trabaja en la historia HU-XX del sprint Sx de Entre Huellas.
Lee AGENTS.md, docs/REGLAS_ARQUITECTURA.md, docs/ESTADO.md, docs/ARQUITECTURA.md y los criterios de docs/GUIA_MVP.md.
Issue de GitHub: [enlace si existe]. Rama: [rama, si ya está creada].
Implementa el comportamiento completo con Supabase y validación pertinente.
Conserva el trabajo existente y registra pruebas y pendientes.
Actualiza docs/ESTADO.md para que el siguiente chat pueda continuar.
Acciones GitHub autorizadas en esta tarea: [indicar commit, push, issue o PR que se espera].
```

Si la tarea implica varios chats activos, acordar quién integra y usar worktrees. Para el arranque, mantener una sola implementación activa reduce el trabajo de integración.

## 9. Próximo paso inmediato

Completar herramientas Android, conectar un teléfono/emulador y validar apertura del deep link sobre la base del chat 00. Identificar el proyecto Supabase de desarrollo e iniciar **01 - Acceso y cuenta**, HU-01 / RF-01,34. El ingreso por correo/Google ya está implementado y el SQL de perfiles preparado; aplicar y validar en desarrollo, y completar registro, recuperación y perfil en HU-01. Las acciones GitHub requieren autorización en la tarea actual.

### Incremento de HU-01, 7 de octubre de 2026

Ingreso por correo/contraseña y Google implementado con casos de uso, repositorios y ViewModel. Fuentes de perfil 001–007, plan y generador de migración preparados. Se conserva HU-01 / RF-01,34 (issue GitHub #1) abierta: falta aplicar y comprobar SQL/RLS, ejecutar el retorno OAuth real y completar registro, recuperación y perfil. Apple está retirado de la interfaz por instrucción del usuario; no amplía los criterios de este incremento. Procedimiento: [CONFIGURACION.md](CONFIGURACION.md) y [database/README.md](../database/README.md).

La entrada manual del esquema de perfiles es ahora `database/run_all.sql`, generada y repetible. Seguir [ADR-003](decisiones/003-ejecucion-sql-idempotente.md); no reemplaza migraciones ni amplía las funcionalidades de HU-01. Al añadir otro incremento, revisar su ejecución repetida y sus permisos antes de ampliar el generador.

### Corrección del recorrido de acceso

Por instrucción del usuario, el orden es login → onboarding de tres pasos → app. No hay bienvenida pública anterior al login ni pantalla intermedia de sesión activa. El onboarding se muestra hasta completarlo u omitirlo y su finalización pertenece a la cuenta, no a la instalación. El retorno de una sesión existente que ya lo completó abre la app directamente. Este incremento de HU-01 incorpora la persistencia y RPC de finalización; no agrega funcionalidades de mascotas, registro o perfil fuera del alcance actual.

### Diseño navegable de Inicio, 8 de octubre de 2026

Por aprobación explícita del usuario, Inicio incorpora cápsula liquid glass (Inicio, Explorar, Mis mascotas, Perfil), botón Reportar separado y panel con los dos tipos de reporte. Incremento de presentación sobre el destino autenticado: no altera el alcance ni completa historias de mascotas/casos/alertas. Sus módulos muestran disponibilidad pendiente; no se simulan datos ni publicación. El cierre de sesión real permanece en Perfil; login/onboarding y permisos conservan sus criterios. Composición y verificación en REGLAS_UI_UX, DISENO_UI y ESTADO.

### Incremento de Perfil — HU-01.7 / RF-01, issue #23

Implementación local de consulta/edición de nombre visible y ciudad desde Perfil, con persistencia Supabase, validación de campos opcionales, respuesta confirmada, conservación del formulario ante fallos y recuperación. Usa esquema y permisos 001–009 existentes; no amplía a baja/exportación ni inicia mascotas. Debe demostrarse con dos cuentas autenticadas y Android antes de cerrar los criterios remotos. La prueba anónima remota y pruebas PostgreSQL locales no sustituyen esa demo. Procedimiento actualizado en CONFIGURACION.

### Cambio de acceso a Perfil

Por aprobación del usuario, Perfil pasa de sección inferior a ruta protegida superpuesta abierta desde avatar de cabecera. Conserva editor/persistencia de HU-01.7. Logo y alertas permanecen arriba; barra principal queda Inicio/Explorar/Mis mascotas. Se añade lectura de foto de metadatos propios cuando existe e iniciales de respaldo, sin cambiar esquema ni iniciar un flujo de subida de fotografías desde galería.

### Ampliación autorizada de HU-01.7: foto y correo

Usuario solicita foto propia desde galería y correo visible de solo lectura. ADR-008 registra este alcance de cuenta, separado de HU-04 (fotografías de mascotas). Incluye selección/normalización, bucket privado/políticas, reintento y recuperación de selección por cuenta. No se cierra issue #23 ni se modifica GitHub con esta entrega; falta activación SQL y demo integrada Android/Storage. No iniciar funciones de mascotas por este cambio.

### Incremento autorizado: Mis mascotas y ficha editable

Se implementa HU-03.1 / #28 y edición de metadatos de HU-03.2 / #29: nombre/especie, opcionales desconocidos, listado/detalle/edición privados, persistencia y reintentos con ID estable/versión. Fotografías (#30/#31), zonas y casos mantienen sus incrementos posteriores. #29 no se completa sin fotos ni #28 sin demo remota/Android. No cerrar historias por pruebas con sustitutos. Contratos y límites en ADR-010.

### Ampliación autorizada de ficha y galería — 9 de octubre de 2026

Usuario solicita retorno superior, tipo concreto para Otra especie, tamaño horizontal y fotos. ADR-012 amplía HU-03.1/#28, HU-03.2/#29 y parte de HU-04.1/#30: galería privada del dueño con hasta tres fotos, normalización cliente, persistencia/reintentos/retirada y permisos por mascota. Fotos confirmadas en ficha y portada de listado. No publicar originales ni completar miniaturas/sanitización servidor/cámara por este ajuste: esos criterios de #30 siguen pendientes junto con demo real Android/Supabase. Nuevo plan/patch 006, sin reescribir SQL anterior ni cambiar estados GitHub en esta tarea.

### Archivo reversible y eliminación definitiva — 9 de octubre de 2026

Por aceptación del usuario, HU-03 / RF-03 añade archivo/restauración como alternativa habitual al borrado. Se entrega ahora el contrato SQL008: conservar ficha/fotos, bloquear archivo con casos activos y borrado con historial. Sin ampliación a adopciones/reportes en este incremento. Integración Flutter y demo remota pendientes; S3 debe mantener indicadores de historia/casos activos bajo bloqueo en la misma transacción. Detalles en ADR-014 y CONFIGURACION.

## Ajuste solicitado de registro/edición de mascotas — 9 de octubre de 2026

HU-03 / RF-03 (issues#28/#29 separados de la numeración HU): nombre/especie/tamaño/edad/rasgos obligatorios al guardar, descripción1–200 con contador, sexo opcional con valor inicial y placeholder de especie no seleccionable. Selector de fotos privado de hasta160, conservando alcance HU-04.1/#30 y sus pendientes. Feedback del editor mediante shake danger y toast superior sin errores debajo, según ADR-016. Plan009 añade validación protegida de metadatos; preserva fichas antiguas y su ciclo de vida. No cierra HU/issues ni activa SQL remoto por pruebas locales.

### Fotos como borrador hasta confirmación — 9 de octubre de 2026

Corrección de HU-03.2/#29 y galería privada HU-04.1/#30: selección/retirada se mantienen locales hasta Registrar mascota/Guardar cambios; cancelar conserva fotos confirmadas. ADR-017 documenta reintento y límites del guardado parcial tras confirmación. No añade sincronización offline persistente, atomicidad de Storage ni migración SQL.

### Integración de archivo/restauración — 9 de octubre de 2026

HU-03 / RF-03 (issues #28/#29): Mis mascotas incorpora Activas/Archivadas y la ficha permite Archivar con confirmación o Restaurar, conservando fotos y metadatos. Eliminar sigue disponible por swipe y rechaza historial/casos activos mediante dominio y servidor. Los casos S3 siguen pendientes y deben mantener indicadores atómicamente según ADR-014. No añade SQL ni cierra automáticamente HU/issues: validación autenticada Android/Supabase y criterios restantes de fotos HU-04 siguen pendientes.

### Zonas de interés implementadas localmente — HU-02.1 / RF-02,16

Primer incremento de la rama `feature/interest-zones`: selección manual en mapa, radio0.1–50km, listado/edición/eliminación privados por cuenta y alternativa de coordenadas. Contrato versionado e idempotente en SQL036–039/plan010, según ADR-018. Sin GPS ni push; HU-02.2 se desarrolla como segundo incremento separado. Las pruebas locales no cierran issue#26 ni S2; patch010 aplicado según usuario del 10 de octubre y demo integrada con dos cuentas en Supabase/Android pendiente.

### Preferencias de alertas — HU-02.2 / issue #27

Rama `feature/alert-preferences`, segundo incremento de HU-02: recepción general, tipos perdidas/encontradas/novedades de casos y canales bandeja/push, conservados por cuenta. Recepción inicialmente pausada; pausar conserva elecciones y activar requiere tipo/canal. Contrato SQL040–043/plan011 privado/versionado según ADR-019. UI guarda selección y explica que recepción se habilitará con HU-12; sin GPS, permisos/tokens ni envío. No ampliar a email/SMS ni afirmar entrega push. Patch011 aplicado según confirmación del usuario; requiere demo Android/Supabase antes de cerrar criterios. Patch010 de zonas ya aplicado según usuario del 10 de octubre.

### Continuación de HU-04 — 10 de octubre de 2026

En codex/pet-photos se implementan cámara con alternativa de galería, procesamiento servidor de JPEG/miniaturas sin EXIF y selección explícita de principal, conservando borradores hasta Guardar y reemplazo determinista al retirar. SQL044–047/plan012 y Edge pet-photo-process preparados; activación conjunta y demo hosted/Android pendientes. ADR-020 mantiene originales y derivados privados: publicación en S3 solo mediante proyección autorizada de bytes verificados. No añade reportes ni entrega alertas; el siguiente incremento funcional sigue HU-05 tras activar/verificar fotos. Historias no cerradas por evidencia local.

### Publicación de mascotas perdidas — HU-05 / RF-05, issue #5

Implementación local en feature/lost-pet-cases: formulario por mascota propia, fotos elegidas, fecha/hora y punto manual, vista previa pública y Mis casos. Publicación autorizada/versionada/idempotente en SQL048–051/plan013 con caso activo único e historial/contador atómicos. Punto/referencia privados y derivados seleccionados verificados con lectura pública limitada; ADR-021 detalla la proyección. La ficha móvil es protegida; web QR, encontrados, exploración/cercanía PostGIS y cierre siguen sus historias posteriores. Activación patch013 y demo real pendientes; no se cierra HU-05 por evidencia local. [Ficha](funcionalidades/casos-perdidos.md).
