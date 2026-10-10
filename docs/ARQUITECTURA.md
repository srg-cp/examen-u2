# Arquitectura de Entre Huellas

Norma obligatoria: [REGLAS_ARQUITECTURA.md](REGLAS_ARQUITECTURA.md). Define patrones, responsabilidades, dependencias, SOLID y criterios de revisión. Este documento conserva la descripción y las decisiones concretas de implementación.

Norma visual obligatoria: [REGLAS_UI_UX.md](REGLAS_UI_UX.md), basada en las pantallas de acceso aprobadas. AppPageLayout y primaryActionButtonStyle se comparten en core; los nombres de Auth delegan en ellos y mantienen compatibilidad. Inicio reutiliza core sin importar presentación de Auth. Su UI anterior queda retirada; sesión y casos de uso se conservan.

La aplicación utiliza **Clean Architecture por funcionalidad**, MVVM, Riverpod y Supabase. La elección responde a la necesidad de separar las reglas de recuperación, el estado de las pantallas y la coordinación de fuentes remotas/locales. La justificación, las alternativas y los costos están registrados en [ADR-001: arquitectura de la aplicación](decisiones/001-arquitectura-aplicacion.md).

La decisión del 4 de octubre de 2026 estableció Flutter + Supabase como base técnica y pospuso una API ASP.NET Core. La organización de capas y contratos quedó definida el 7 de octubre de 2026.

## Organización

La presentación inicial usa StartupReveal compartido desde el builder de MaterialApp.router. Monta el Router visual después de la secuencia de marca; las suscripciones y reglas de sesión siguen en sus ViewModels/casos de uso. No altera destinos ni concede acceso durante el arranque. Recursos Android versionados armonizan splash nativo y Flutter; texto animado pertenece a Flutter, no al SDK de autenticación.

Una sola base de código versionada, con carpetas simples. No se requiere una herramienta de monorepo.

```text
entreHuellas/
  AGENTS.md
  README.md
  docs/
  .github/
  flutter_application_entrehuellas/  # App Flutter existente; Android primero
  apps/
    public-web/             # Web QR ligera, se crea en S4
  database/                 # Fuentes SQL numeradas por tipo de objeto
    tables/
    functions/
    policies/
    grants/
    tests/                  # Pruebas SQL; resto del árbol en database/README.md
  supabase/
    migrations/             # Paquetes de cambios generados desde database
    functions/              # Integraciones y operaciones server-side necesarias
```

La app existente se conserva en `flutter_application_entrehuellas`, según la decisión de ubicación del 6 de octubre de 2026. `apps/public-web` y las Edge Functions se crearán cuando su sprint los requiera. `supabase/migrations` ya contiene el primer paquete SQL generado.

`database` guarda las fuentes SQL en carpetas por objeto, con secuencia global `001_...sql`. Las migraciones agrupan cambios en orden de dependencia; sus fuentes y su historial no se modifican después de aplicarlos. La estructura inicial y la separación entre SQL y Edge Functions se describen en [database/README.md](../database/README.md) y [ADR-002](decisiones/002-organizacion-database.md). El incremento de perfiles 001–007 y el generador PowerShell están preparados. La migración y sus pruebas de permisos deben ejecutarse en Supabase de desarrollo; no se han desplegado.

En `flutter_application_entrehuellas/lib`:

```text
app/                        # App, router y bootstrap de implementaciones
core/                       # Configuración, errores, base local y tema
features/
  auth/
    presentation/
      screens/              # AccessScreen: renderiza el estado del ViewModel
      view_models/          # AuthViewModel y LoginViewModel: sesión y acciones
      state/                # AuthViewState y LoginViewState: estado de presentación
      widgets/              # Formulario de credenciales, botones sociales y marca
    domain/
      entities/             # AuthSession, identidad sin tokens
      repositories/         # Contratos AuthRepository y AccessRepository
      use_cases/            # WatchAuthSession, SignIn y SignOut
      failures/             # AuthFailure, independiente del SDK
    data/
      data_sources/         # Contrato remoto y adaptador de Supabase Auth
      models/               # AuthSessionDto: proyección externa sin tokens
      repositories/         # AuthRepositoryImpl y UnavailableAuthRepository
    providers/              # Declaraciones DI basadas solo en contratos
  home/
    presentation/screens/   # Base autenticada; acciones mediante ViewModels
  onboarding/              # presentation/domain/data/providers; entrada y tres etapas
  pets/
  cases/
  sightings/
  map/
  notifications/
  moderation/
```

`presentation` contiene pantallas, ViewModels y estado; `domain/entities` contiene los conceptos del producto, `domain/repositories` sus contratos de acceso a datos y `domain/use_cases` las operaciones que consume el ViewModel. `data` implementa los contratos y transforma tipos externos en entidades. El dominio depende solo de Dart y otros componentes de dominio, sin Flutter, Riverpod ni SDKs. Esta estructura se mantiene durante la entrega del MVP y en los incrementos posteriores.

Un caso de uso recibe los contratos que necesita por constructor, expresa una operación y contiene sus reglas. La presentación decide cómo mostrar carga/error/datos; no decide permisos ni transiciones críticas. Al incorporar nuevas operaciones se implementan sus casos de uso y pruebas. En `data`, el adaptador consulta el SDK y proyecta DTO sin tokens, y el repositorio los convierte en entidades; esta frontera permite sustituir el adaptador y comprobar el repositorio sin Supabase. Un DTO representa el formato/proyección de una fuente, una entidad representa un concepto del producto. No crear carpetas vacías, clases base genéricas ni duplicar todos los objetos por defecto. Las funcionalidades futuras del árbol se incorporan al implementar su sprint.

Ejemplo implementado: `WatchAuthSession` observa la identidad y elimina eventos consecutivos equivalentes, incluyendo renovación de tokens para el mismo usuario. Conserva cambio de usuario, cierre y nuevo acceso. Tras un error acepta el siguiente valor aunque coincida con el anterior, para recuperar la UI; cada suscripción tiene su propio historial y transmite cancelación/pausa/reanudación al origen. `AuthSession` es inmutable y compara por `userId`; no representa el perfil ni las credenciales. Los fallos de observación se propagan como error, sin convertirlos en cierre de sesión.

`app/bootstrap.dart` y `main.dart` componen la app: validan configuración, inicializan Supabase una vez, construyen adaptador/repositorio e inyectan los contratos con overrides de Riverpod. `features/auth/providers` declara el repositorio y el caso de uso sin importar implementaciones; requiere que se inyecte el repositorio al arrancar. El arranque no configurado inyecta explícitamente `UnavailableAuthRepository` y `UnavailableAccessRepository`. `core/config/startup_state_provider.dart` expone el estado de arranque. Los providers pueden sustituirse en pruebas sin un servidor real. Presentación ya no depende del módulo de composición `app`.

## Presentation y data: reglas concretas

La norma de transiciones/carga está en [ADR-006](decisiones/006-transiciones-y-carga-con-shimmer.md). LoadingShimmer usa un CustomPainter con controlador local a presentación: mantiene la etiqueta y el tamaño del botón, anuncia progreso real por semántica, bloquea interacción y detiene/libera el ticker al finalizar/desmontar. Sin dependencias nuevas ni estados SDK en UI; movimiento reducido mantiene un brillo estático. El estado de registro/recuperación distingue verificación de OTP para iluminar únicamente el control correspondiente. Nuevas claves de etapa para éxito/error activan cover → stagger sin cambiar reglas de Auth ni repetir efectos en la misma etapa.

### Recuperación de contraseña (HU-01 / RF-01,34)

PasswordRecoveryRepository declara solicitud, verificación de código, actualización, fin del flujo y observación de RecoveryAccess. RequestPasswordRecovery valida/normaliza correo; VerifyRecoveryCode valida seis dígitos y delega verificación con OtpType.recovery; ResetPassword valida longitud y confirmación sin recortar la contraseña. WatchRecoveryAccess y EndPasswordRecovery expresan observación/cierre. PasswordRecoveryRepositoryImpl transforma DTO y fallos; SupabasePasswordRecoveryDataSource encapsula resetPasswordForEmail, verifyOTP, updateUser, signOut y eventos del SDK. Bootstrap inyecta la implementación y su alternativa no configurada, sin nuevos objetos SQL.

RecoveryAccessViewModel observa el propósito de recuperación separado de AuthSession (que sigue siendo identidad). El router prioriza ready/invalid sobre el destino de onboarding; el evento passwordRecovery del SDK habilita el cambio y se conserva durante tokenRefreshed/userUpdated. signedOut, signedIn o cambio de cuenta lo limpian. El adaptador rechaza actualización sin contexto de recuperación para el mismo usuario; Auth verifica sesión y política en el servidor. La escucha se cancela con autoDispose; se desactiva el reintento automático de Riverpod para mantener errores y aceptar el siguiente evento. Los fallos de observación de login/OAuth normales permanecen en el flujo de Auth.

PasswordRecoveryViewModel coordina petición, verificación, reenvío con espera, validación/fallos y actualización. Libera temporizador al desmontar/entrar al reset/cerrar; descarta respuestas tardías de solicitud/verificación cuando cambia el contexto. PasswordRecoveryScreen y ResetPasswordScreen reutilizan AuthPageLayout, StaggerReveal, decoración, ShakeField y estilos de botón; EmailCodeConfirmation comparte la ilustración y layout con registro. EmailCodeInput usa una sola entrada real para pegado/autofill/retroceso y seis casillas visuales excluidas de semántica. Los widgets consumen estado/acciones del ViewModel. El resultado confirmado se muestra antes de cerrar sesión local y volver al login; un fallo de cierre permite reintentar.

El propósito de recuperación vive en la instancia de la fuente de datos y el evento del SDK, sin preferencias globales por instalación. La app avanza a reset solo tras recibir sesión válida al verificar OTP: se puede leer el correo en una PC y escribir el código en el móvil, sin compartir el verificador PKCE de la solicitud. Los callbacks existentes siguen siendo compatibles. Si se reinicia después de consumir el código y antes de actualizar contraseña, solicitar uno nuevo. No se cambia el modelo de sesión ni se afirma que los renders prueben correo remoto.

Para registro, RegistrationRepository/DataSource añaden verifyCode y VerifyRegistrationCode valida seis dígitos antes de red. SupabaseRegistrationDataSource usa OtpType.email, sin el tipo signup obsoleto para verificación. Reenvío continúa con resend(type: signup), que es una operación distinta. RegistrationViewModel conserva correo y error contextual si el código falla; solo sesión válida permite el acceso. Ningún OTP se genera, guarda o compara localmente como autorización. El servidor controla caducidad, uso y límites. Fuentes de plantillas con Token en supabase/auth/templates, independientes de SQL.

La transición visual entre etapas pertenece a AuthStageTransition/CoverReveal en core/presentation/widgets, sin cambiar ViewModels ni reglas de Auth. AuthPageLayout permite envolver únicamente título/contenido, conservando la marca fuera de los efectos. CoverReveal usa un clip vertical de una cortina blanca plana; no depende de OriginPageTransition ni captura geometría de botones. Una clave de etapa conserva el contenido anterior durante 320 ms y bloquea interacción/semántica; al completar activa el StaggerReveal del nuevo contenido mediante play. Errores/contador/reenvío mantienen la clave/timeline y no repiten los efectos; controladores se liberan al desmontar y respetan disableAnimations.

PasswordRecoveryScreen comparte solicitud, OTP y reset bajo la misma cabecera; ResetPasswordScreen delega la entrada de callbacks externos con resetMode. El router mantiene la página de recuperación visible al llegar RecoveryAccess.ready/invalid y sigue redirigiendo intentos de salir hacia destinos autenticados al reset. Al refrescar una página añadida con push, GoRouter puede reconstruir el URI del login de base: se comprueban la restauración, el URI de base y el último match visible para conservar la cabecera, sin autorizar una navegación nueva a Inicio. Los tests verifican identidad de render del logo y secuencia cover → stagger, junto a las restricciones de navegación existentes.

El tema, los componentes visuales compartidos y la composición de las pantallas se describen en [DISENO_UI.md](DISENO_UI.md). Los cambios de estilo conservan el mismo recorrido de casos de uso y estado; no añaden dependencias de infraestructura a los widgets.

- **MVVM y flujo de datos en una dirección:** `AccessScreen` observa un único `AuthViewState` de `AuthViewModel`. El ViewModel combina arranque y sesión. Las futuras acciones de producto se invocan en el ViewModel mediante casos de uso; navegación simple, estilos y visibilidad corresponden a la pantalla.
- **Estado inmutable:** `AuthViewState` contiene `StartupState` y `AsyncValue<AuthSession?>`. AsyncValue ya representa carga/dato/error; no se introduce otra máquina de estados equivalente. Los mensajes de pantalla pertenecen a presentación. Home, sin reglas ni datos, puede ser un widget simple sin un ViewModel vacío.
- **Ciclo de vida:** ViewModel y stream de sesión usan `autoDispose`. Al dejar de observar la pantalla se liberan sus suscripciones. El stream de sesión no reintenta automáticamente ante errores; puede recuperarse con un evento posterior de la misma fuente. Los reintentos futuros de operaciones se diseñarán según idempotencia.
- **Repository y Adapter:** `SupabaseAuthDataSource` es el adaptador del SDK. `AuthRemoteDataSource` permite sustituir esa fuente. `AuthRepositoryImpl` conoce ese contrato, mapea DTO a entidades y transforma errores síncronos o de stream en `AuthFailure`. No captura secretos en el fallo de dominio; el error no se transforma en sesión nula. El stream puede continuar tras un error.
- **Widgets pequeños y acceso adaptable:** `LoginCredentialsForm`, `SocialSignInButton` y `BrandWordmark` componen el acceso sin obtener datos de infraestructura. La pantalla observa los ViewModels para carga/sesión/error y permite scroll en superficies pequeñas con texto ampliado. Los componentes compartidos se extraen cuando tengan uso real.
- **Pruebas de fronteras:** `test/architecture_test.dart` revisa directivas import/export/part, incluidas alternativas condicionales: dominio sin paquetes/plataformas; presentación sin data, app, repositorios directos ni SDKs; data sin presentación/providers/app; providers sin implementaciones. Los SDKs de datos se permiten en `data_sources` y bootstrap. Esta comprobación de directivas complementa análisis y revisión; no es un análisis completo de todos los símbolos.

Se adopta esta organización como convención del proyecto, no como una estructura universal obligatoria en Flutter. Los patrones usados son MVVM, Repository, Adapter, inyección por constructor/providers y estado inmutable. [Las recomendaciones oficiales](https://docs.flutter.dev/app-architecture/recommendations) respaldan separar vistas/ViewModels, repositorios/servicios, inyectar dependencias y probarlos por separado. No se añadió un contenedor DI adicional, herencia base ni generadores para esta sesión sencilla.

`go_router` gestiona `/` (preparación), `/access`, `/onboarding` y `/home`; las rutas se protegen según sesión y finalización. Una ruta desconocida lleva al destino autorizado. El deep link `entrehuellas://login-callback/` pertenece a Supabase/app_links; el manejador nativo de Flutter está desactivado para evitar que el router procese el mismo callback. El SDK usa PKCE y el repositorio transforma sus eventos en identidad de sesión sin exponer tokens. El estado `ready` confirma inicialización local, no conectividad ni validez remota de la clave. La allowlist remota y las pruebas reales se documentan en [CONFIGURACION.md](CONFIGURACION.md).

## Responsabilidades

| Pieza | Uso |
| --- | --- |
| Flutter / MVVM | UI y acciones del usuario separadas del estado de la pantalla. |
| Riverpod | Estado e inyección; Notifier/AsyncNotifier según el flujo. |
| Entidades | Conceptos del producto independientes del formato de persistencia. |
| Casos de uso | Operaciones del producto y sus reglas, usando contratos de repositorios. |
| Repositorios | Contratos en dominio; implementaciones en data coordinan acceso remoto/local y mapeo. |
| Supabase Auth | Cuenta y sesión. |
| PostgreSQL + PostGIS | Persistencia e invariantes; consultas geográficas en servidor. |
| Storage | Medios privados y derivados públicos controlados. |
| Funciones PostgreSQL / RPC | Operaciones atómicas con comprobaciones de actor y transiciones. |
| Edge Functions | Integraciones, secretos y endpoints públicos controlados. |
| SQLite / Drift | Borradores, caché y cola local de envíos. |
| FCM | Push; la bandeja de notificaciones es persistente. |

Flujo habitual: pantalla -> ViewModel -> caso de uso -> contrato de repositorio -> implementación -> fuente de datos -> SDK/backend. Los DTO se transforman en entidades antes de devolverlos al dominio. Las implementaciones dependen del dominio; el dominio no conoce su backend. Una validación cliente ayuda a la experiencia, pero permisos e invariantes deben seguir validados en servidor.

Esta elección concreta adapta los principios de [la guía oficial de arquitectura Flutter](https://docs.flutter.dev/app-architecture/guide): separación de responsabilidades, inyección y capa de dominio. Flutter no impone una única estructura de carpetas; este proyecto adopta los casos de uso como punto de entrada a las operaciones de dominio.

## Reglas del servidor

- Grants y RLS delimitan las operaciones y filas accesibles para visitantes, usuarios y moderadores. Storage también tiene políticas.
- La ficha pública tiene un contrato propio; no se devuelve la tabla privada completa. Las vistas se revisan para que no eludan políticas.
- Una restricción impide dos casos perdidos activos de una mascota. Cambios de estado y auditoría se realizan en una operación autorizada.
- Las funciones RPC que cambian estados verifican permisos y transición. Los privilegios de ejecución y cualquier uso de SECURITY DEFINER se revisan explícitamente.
- Casos y avistamientos usan claves de envío estables y deduplicación del servidor. Un reintento con datos incompatibles debe producir conflicto.
- `observed_at` describe el evento, `created_at` su recepción. Fechas almacenadas en UTC; UI en America/Lima.
- El QR contiene un token opaco revocable. El formulario de visitante valida límites y abuso en servidor.
- Validar fotografías en servidor, eliminar EXIF y controlar qué bytes son públicos. Elegir en S2 una solución compatible con los límites del runtime; procesos pesados necesitan otro mecanismo.
- Las alertas tienen registro persistente y estado de entrega/reintento. Ejecutar una Edge Function una vez no garantiza entrega.
- Las credenciales privilegiadas permanecen fuera de Flutter y la web pública.

## Evolución

Chat, adopciones, refugios, servicios e IA quedan después del MVP. Supabase Realtime puede evaluarse cuando exista un flujo que lo necesite. Una API propia se reconsidera por necesidades medidas, sin rehacer las pantallas si los repositorios conservan sus contratos.

## Referencias

- [Separación de vistas, ViewModels y datos en Flutter](https://docs.flutter.dev/app-architecture/guide).
- [Providers de Riverpod](https://riverpod.dev/docs/concepts2/providers).
- [Autorización con RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).
- [Funciones PostgreSQL llamadas por RPC](https://supabase.com/docs/guides/database/functions).
- [Edge Functions e integraciones](https://supabase.com/docs/guides/functions).
- [Control de acceso de Storage](https://supabase.com/docs/guides/storage/security/access-control).

## Ingreso y sesión

`RegisterScreen` observa `RegistrationViewModel`, que consume `RegisterAccount` y `ResendRegistrationConfirmation`. El dominio valida nombre/correo, longitud mínima y coincidencia de contraseñas sin depender del SDK ni alterar los espacios de contraseña. `RegistrationRepository` es un contrato específico; su implementación mapea `RegistrationResultDto` a `RegistrationOutcome`, diferenciando confirmación pendiente de sesión autenticada. `SupabaseRegistrationDataSource` encapsula signup/resend, metadata y callback. Bootstrap/main inyectan este contrato también en arranque no configurado.

La ruta pública `/register` se permite solo cuando el destino autorizado es login. Una sesión nueva sigue pasando por `EntryViewModel`; la respuesta del formulario no autoriza saltar onboarding. Errores tipados se presentan por campo, con decoración compartida entre login/registro y ShakeField; los fallos de servicio usan texto breve contextual, sin mensajes del SDK. La confirmación permanece dentro de la pantalla de registro y usa enlace, no una simulación OTP. El ViewModel conserva solo email de confirmación/estado, no contraseñas; bloquea duplicados y libera el contador de reenvío con autoDispose.

`LoginViewModel` consume `SignIn` y `SignOut`, bloquea envíos duplicados y publica carga/mensajes seguros. `SignIn` valida correo y presencia de contraseña sin alterar sus espacios. `AccessRepositoryImpl` transforma fallos de `AuthAccessDataSource` a fallos de dominio; `SupabaseAuthDataSource` encapsula ingreso por contraseña, OAuth y salida local. Bootstrap inyecta el repositorio de comandos junto con el repositorio de observación de sesión.

Abrir Google no equivale a estar autenticado. El SDK inicia OAuth con PKCE y el callback móvil; `AuthViewModel` confirma la identidad mediante eventos de sesión. El formulario no guarda contraseñas en providers ni muestra errores internos del SDK. La opción Apple está retirada de esta interfaz por instrucción del usuario; registro por correo está implementado; recuperar contraseña y editar perfil siguen pendientes de HU-01.

### Entrada SQL y nombres

`database/run_all.sql` se genera desde las fuentes del incremento de perfiles para ejecución manual repetible; conserva la migración anterior y evita duplicados. Su generación y límites se registran en [ADR-003](decisiones/003-ejecucion-sql-idempotente.md). El SQL usa identificadores en inglés con `snake_case`; los DTO los mapean a propiedades Dart en `camelCase`. El procedimiento y las pruebas están en [database/README.md](../database/README.md).

### Flujo de entrada y onboarding por cuenta

`EntryViewModel` combina la sesión observada con `CheckOnboarding`. El router escucha su estado para proteger `/home` y `/onboarding`: sin sesión muestra `/access`, con onboarding pendiente muestra `/onboarding`, y con finalización persistida muestra `/home`. La consulta fallida no autoriza omitir el flujo. No se reconstruye el router en cada cambio de sesión.

`OnboardingViewModel` coordina páginas y consume `CompleteOnboarding`; data consulta el perfil y llama a la RPC protegida mediante una fuente Supabase. Bootstrap inyecta el contrato. `BrandWordmark` pasó a core porque lo comparten login y onboarding. La persistencia y los criterios de reentrada se registran en [ADR-004](decisiones/004-onboarding-por-cuenta.md).

Los errores de ingreso se mapean a LoginFieldIssue en LoginViewModel. LoginCredentialsForm consume el estado y delega edición/reintento; ShakeField es un componente visual compartido, sin reglas de autenticación. Se mantiene emailNotConfirmed separado del rechazo genérico en las fronteras de data y dominio.

La UI utiliza feedback contextual y prohíbe SnackBar por [ADR-005](decisiones/005-feedback-sin-snackbar.md). La comprobación en architecture_test.dart protege esta regla junto con los límites de capas.

RegisterScreen compone una única StaggerReveal compartida entre cabecera y RegistrationForm. Cada componente usa StaggerRevealItem con su orden de entrada; el timeline se conserva durante reconstrucciones del ViewModel y respeta movimiento reducido. La animación reside en presentación y no altera casos de uso, estado de autenticación ni persistencia.

AccessScreen y RegisterScreen reutilizan AuthPageLayout para conservar dimensiones y anclaje de marca/título, sin centrar cada formulario por su propia altura. La X de cierre del registro no reserva un AppBar. El router compone OriginPageTransition con el rectángulo visual del control de entrada. Registro retorna mediante pop para completar la animación inversa y conservar el login anterior; solo usa go sin historial. La transición se desactiva con movimiento reducido y no participa de autorización ni lógica de cuenta.

## Perfil de cuenta — HU-01.7 / RF-01

Perfil se implementa en `features/profile`: entidades/fallos/repositorio y ReadProfile/UpdateProfile en dominio; DTO, fuente Supabase y repositorio en data; AsyncNotifier autoDispose, estado y formulario en presentación. Providers declaran contratos/casos de uso y observación de identidad mediante WatchAuthSession. Bootstrap inyecta el repositorio; router compone ProfileEditor dentro del shell Home mediante un parámetro Widget, sin importaciones entre las presentaciones de ambas funcionalidades.

La lectura selecciona únicamente id/display_name/city de la cuenta activa. La escritura reemplaza solamente display_name/city y obtiene la fila confirmada; nunca envía identidad, rol, timestamps u onboarding. Campos opcionales, vacíos normalizados a null, longitud máxima 120 puntos de código acorde a PostgreSQL. La fuente comprueba identidad antes/después de cada respuesta; ViewModel descarta resultados tardíos por generación al cambiar de cuenta y no escribe tras desmontaje. Fallos de fuente se normalizan y el editor conserva cambios durante error/reintento. Lectura fallida permite retry explícito, sin reintentos automáticos ocultos.

El esquema 001–009 ya contempla este contrato: no se modifica SQL aplicado ni se genera una migración sin cambio de esquema. Tests 001 y 003 verifican políticas/grants y edición en PostgreSQL local; ejecución con dos cuentas autenticadas en Supabase sigue siendo verificación separada.

## Perfil como ruta desde avatar

ProfileAvatarButton se compone desde app/router en el parámetro profileAvatar de Home, sin imports de presentación entre funcionalidades. HomeViewModel solo controla tres destinos; la salida de cuenta pasa a ProfileExitViewModel autoDispose y mantiene SignOut de dominio. /home/profile está anidada en /home y protegida por EntryDestination; la ruta superpuesta conserva estado de Inicio al regresar.

ProfileAvatar observa ProfileViewModel, también utilizado por editor: la suscripción de cabecera mantiene perfil vigente mientras vive Home; los resultados de identidad/carga/error no muestran datos de otra cuenta. SupabaseProfileDataSource agrega solamente la URL HTTPS de avatar_url/picture de metadatos propios al DTO; repositorio mapea avatarUri a entidad. Los metadatos no autorizan operaciones ni se exponen íntegros. Escritura de nombre/ciudad y grants/RLS conservan su contrato. No se añade esquema/Storage para carga de fotos en este ajuste.

## Foto de cuenta y correo

ProfilePhotoRepository/ChangeProfilePhoto declaran selección, recuperación y subida concreta. GalleryProfilePhotoSource encapsula image_picker, procesamiento image y marcador de propietario shared_preferences; ProfilePhotoRepositoryImpl normaliza fallos. SupabaseProfileDataSource proyecta email desde Auth y usa Storage privado con ruta estable/URL firmada. ProfilePhotoViewModel autoDispose controla carga/reintento y generaciones por identidad; applyAvatar actualiza solo imagen/correo, conservando el borrador del editor.

Sin email editable ni nueva columna de perfil. Selecciones recuperadas se vinculan a la cuenta original y requieren confirmación explícita. Arquitectura/privacidad/límites en ADR-008; inyección en bootstrap/main. Test de capas amplía SDKs protegidos a image_picker/image/shared_preferences/cross_file.

## Mis mascotas: registro y edición de metadatos

HU-03.1 / RF-03, issue #28, y parte de HU-03.2 / #29: Home recibe PetsSection desde app/router. PetListViewModel/PetDetailViewModel/PetEditorViewModel autoDispose consumen ListMyPets/ReadPet/CreatePet/UpdatePet; data encapsula consultas y RPC mediante SupabasePetDataSource y DTO. Bootstrap inyecta PetRepositoryImpl; sin imports de presentación entre funcionalidades.

Tabla privada pets con RLS/consulta por dueño y escrituras únicamente RPC autorizadas; UUID por borrador, deduplicación de creación y versionado para edición/reintento. Generaciones por identidad y keepAlive limitado a escritura protegen cambios de sesión/cierre. No implementar fotos o QR como parte de este incremento. ADR-010 documenta reglas, contratos y límites.

## Ampliación de ficha y galería privada

[ADR-012](decisiones/012-ficha-y-galeria-privada-mascotas.md) añade tipo/tamaño y galería privada. PetPhotoRepository/ManagePetPhotos y PetPhotosViewModel coordinan selección/consulta/subida/retirada mediante fuentes NativePetGallerySource y SupabasePetPhotoSource; bootstrap inyecta implementaciones. DTO separa metadata/URL de entidades. Metadata confirmada antes de fotos, IDs estables y respuesta confirmada para éxito; actor/generación/keepAlive protegen estados tardíos. Fotos públicas del QR y procesamiento servidor continúan fuera de este incremento.

### Coordinación de carga inicial de ficha y fotos

Los ViewModels de ficha/editor coordinan sus casos de uso existentes de metadatos y fotos en paralelo. La pantalla observa una única carga inicial hasta finalizar ambas consultas. La inicialización de PetPhotosViewModel se comparte por Future dentro de su ciclo de cuenta/mascota y se reinicia al reconstruirse por sesión; la galería reutiliza el resultado y conserva reintento explícito de sus errores. No cambia contratos de dominio ni acceso a SDK desde presentación. ADR-011 documenta la continuidad visual y sus pruebas.

## Archivo reversible de mascotas — contrato backend

ADR-014 establece archive_pet/restore_pet y borrado definitivo sin historia de casos. SQL030–033 aporta estado de archivo e indicadores protegidos del ciclo de casos; las RPC validan dueño, bloqueo de fila, versión y reintentos. El módulo de casos S3 debe mantener los indicadores de forma atómica. No se añadieron casos/adopciones ni componentes vacíos de Flutter; la integración de entidad/DTO/casos de uso/ViewModels/listados archivados queda pendiente del siguiente incremento solicitado.

ADR-015 establece GlassNavigationButton en core como control visual común de retorno/cierre de pantallas; PetScreenShell, AppPageLayout y ProfileScreen lo componen sin modificar ViewModels, dominio o datos.
