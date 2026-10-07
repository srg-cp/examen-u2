# Arquitectura de Entre Huellas

Norma obligatoria: [REGLAS_ARQUITECTURA.md](REGLAS_ARQUITECTURA.md). Define patrones, responsabilidades, dependencias, SOLID y criterios de revisión. Este documento conserva la descripción y las decisiones concretas de implementación.

La aplicación utiliza **Clean Architecture por funcionalidad**, MVVM, Riverpod y Supabase. La elección responde a la necesidad de separar las reglas de recuperación, el estado de las pantallas y la coordinación de fuentes remotas/locales. La justificación, las alternativas y los costos están registrados en [ADR-001: arquitectura de la aplicación](decisiones/001-arquitectura-aplicacion.md).

La decisión del 4 de octubre de 2026 estableció Flutter + Supabase como base técnica y pospuso una API ASP.NET Core. La organización de capas y contratos quedó definida el 7 de octubre de 2026.

## Organización

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
  supabase/
    migrations/             # Esquema, restricciones, RLS y funciones
    functions/              # Integraciones y operaciones server-side necesarias
    tests/                  # Pruebas de permisos y reglas críticas
```

La app existente se conserva en `flutter_application_entrehuellas`, según la decisión de ubicación del 6 de octubre de 2026. `apps/public-web` y `supabase` se crearán cuando su sprint los requiera.

En `flutter_application_entrehuellas/lib`:

```text
app/                        # App, router y bootstrap de implementaciones
core/                       # Configuración, errores, base local y tema
features/
  auth/
    presentation/
      screens/              # AccessScreen: renderiza el estado del ViewModel
      view_models/          # AuthViewModel: coordina estado con Riverpod
      state/                # AuthViewState: estado inmutable de la pantalla
      widgets/              # AuthSessionStatus: renderiza carga/dato/error
    domain/
      entities/             # AuthSession, identidad sin tokens
      repositories/         # Contrato AuthRepository
      use_cases/            # WatchAuthSession
      failures/             # AuthFailure, independiente del SDK
    data/
      data_sources/         # Contrato remoto y adaptador de Supabase Auth
      models/               # AuthSessionDto: proyección externa sin tokens
      repositories/         # AuthRepositoryImpl y UnavailableAuthRepository
    providers/              # Declaraciones DI basadas solo en contratos
  home/
    presentation/screens/   # Pantalla inicial sin lógica de negocio
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

`app/bootstrap.dart` y `main.dart` componen la app: validan configuración, inicializan Supabase una vez, construyen adaptador/repositorio e inyectan los contratos con overrides de Riverpod. `features/auth/providers` declara el repositorio y el caso de uso sin importar implementaciones; requiere que se inyecte el repositorio al arrancar. El arranque no configurado inyecta explícitamente `UnavailableAuthRepository`. `core/config/startup_state_provider.dart` expone el estado de arranque. Los providers pueden sustituirse en pruebas sin un servidor real. Presentación ya no depende del módulo de composición `app`.

## Presentation y data: reglas concretas

- **MVVM y flujo de datos en una dirección:** `AccessScreen` observa un único `AuthViewState` de `AuthViewModel`. El ViewModel combina arranque y sesión. Las futuras acciones de producto se invocan en el ViewModel mediante casos de uso; navegación simple, estilos y visibilidad corresponden a la pantalla.
- **Estado inmutable:** `AuthViewState` contiene `StartupState` y `AsyncValue<AuthSession?>`. AsyncValue ya representa carga/dato/error; no se introduce otra máquina de estados equivalente. Los mensajes de pantalla pertenecen a presentación. Home, sin reglas ni datos, puede ser un widget simple sin un ViewModel vacío.
- **Ciclo de vida:** ViewModel y stream de sesión usan `autoDispose`. Al dejar de observar la pantalla se liberan sus suscripciones. El stream de sesión no reintenta automáticamente ante errores; puede recuperarse con un evento posterior de la misma fuente. Los reintentos futuros de operaciones se diseñarán según idempotencia.
- **Repository y Adapter:** `SupabaseAuthDataSource` es el adaptador del SDK. `AuthRemoteDataSource` permite sustituir esa fuente. `AuthRepositoryImpl` conoce ese contrato, mapea DTO a entidades y transforma errores síncronos o de stream en `AuthFailure`. No captura secretos en el fallo de dominio; el error no se transforma en sesión nula. El stream puede continuar tras un error.
- **Widgets pequeños y acceso adaptable:** `AuthSessionStatus` muestra carga/sesión/error sin obtener datos. Las pantallas iniciales permiten scroll en superficies pequeñas y con texto ampliado. Los componentes compartidos se extraen cuando tengan uso real.
- **Pruebas de fronteras:** `test/architecture_test.dart` revisa directivas import/export/part, incluidas alternativas condicionales: dominio sin paquetes/plataformas; presentación sin data, app, repositorios directos ni SDKs; data sin presentación/providers/app; providers sin implementaciones. Los SDKs de datos se permiten en `data_sources` y bootstrap. Esta comprobación de directivas complementa análisis y revisión; no es un análisis completo de todos los símbolos.

Se adopta esta organización como convención del proyecto, no como una estructura universal obligatoria en Flutter. Los patrones usados son MVVM, Repository, Adapter, inyección por constructor/providers y estado inmutable. [Las recomendaciones oficiales](https://docs.flutter.dev/app-architecture/recommendations) respaldan separar vistas/ViewModels, repositorios/servicios, inyectar dependencias y probarlos por separado. No se añadió un contenedor DI adicional, herencia base ni generadores para esta sesión sencilla.

`go_router` gestiona `/` y `/access`, con regreso al inicio para rutas desconocidas. El deep link `entrehuellas://login-callback/` pertenece a Supabase/app_links; el manejador nativo de Flutter está desactivado para evitar que el router procese el mismo callback. El SDK usa PKCE y el repositorio transforma sus eventos en identidad de sesión sin exponer tokens. El estado `ready` confirma inicialización local, no conectividad ni validez remota de la clave. La allowlist remota y las pruebas reales se documentan en [CONFIGURACION.md](CONFIGURACION.md).

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
