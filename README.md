# Entre Huellas

MVP para publicar mascotas perdidas o encontradas, compartir una ficha mediante QR, recibir avistamientos y gestionar la recuperación.

## Base técnica

- Android con Flutter.
- Clean Architecture por funcionalidad, MVVM y Riverpod.
- Casos de uso y contratos en dominio; repositorios y fuentes de datos en data.
- Supabase Auth, PostgreSQL/PostGIS, Storage y funciones cuando sean necesarias.
- SQLite para borradores y caché.
- Web pública ligera para abrir el QR sin instalar la app.

Las reglas de recuperación, la interfaz y el acceso a datos se separan para poder evolucionar y probar cada parte. Esta organización contempla la incorporación de almacenamiento local y el control de los datos públicos del QR. Los motivos y las alternativas están en [la decisión de arquitectura](docs/decisiones/001-arquitectura-aplicacion.md).

## Documentación

- [Guía de trabajo, chats, sprints y GitHub](docs/GUIA_MVP.md).
- [Reglas de oro de arquitectura — norma del proyecto](docs/REGLAS_ARQUITECTURA.md).
- [Arquitectura del sistema](docs/ARQUITECTURA.md).
- [Diseño y componentes de interfaz](docs/DISENO_UI.md).
- [ADR-001: motivos y alternativas de arquitectura](docs/decisiones/001-arquitectura-aplicacion.md).
- [Organización y numeración del SQL](database/README.md).
- [ADR-002: fuentes SQL y migraciones](docs/decisiones/002-organizacion-database.md).
- [ADR-003: entrada SQL repetible y nombres](docs/decisiones/003-ejecucion-sql-idempotente.md).
- [Estado actual y siguiente paso](docs/ESTADO.md).
- [Configuración de Supabase y validación](docs/CONFIGURACION.md).
- [Fuentes y regeneración del icono Android](logo/README.md).
- [Instrucciones para agentes](AGENTS.md).

## Estado

La app existente se conserva en `flutter_application_entrehuellas`. Incluye Clean Architecture por funcionalidad (`presentation`, `domain`, `data`), Riverpod, go_router y arranque configurable de Supabase. Sin configuración se muestra el login y el estado del servicio. El login completo pertenece a HU-01.

El dominio organiza entidades, contratos de repositorios y casos de uso; el ViewModel consume `WatchAuthSession`. En VS Code, los perfiles **Entre Huellas - desarrollo local** y **Entre Huellas - sin Supabase** permiten iniciar con F5. El perfil local requiere crear/completar el archivo de configuración una sola vez.

Repositorio: [srg-cp/entrehuellas](https://github.com/srg-cp/entrehuellas).

Desde la carpeta de la app: `flutter pub get --enforce-lockfile` y `flutter run -d chrome`. Para Supabase y el deep link `entrehuellas://login-callback/`, seguir [la configuración](docs/CONFIGURACION.md). El estado registra la validación y los requisitos Android pendientes.

El login actual incluye correo/contraseña y Google con Supabase Auth. El SQL de perfiles está preparado en [database](database/README.md); la entrada manual repetible es [run_all.sql](database/run_all.sql), con migración conservada para el historial y ejecución remota pendiente. Consultar [configuración y prueba del acceso](docs/CONFIGURACION.md). HU-01 sigue en curso.

El recorrido actual empieza por login. Después muestra las tres etapas de onboarding si esa cuenta aún no lo completó u omitió; de lo contrario entra directamente a la app. Aplicar el `run_all.sql` actualizado para activar la persistencia por cuenta. [Decisión del recorrido](docs/decisiones/004-onboarding-por-cuenta.md).
