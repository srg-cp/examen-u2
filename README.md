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
- [ADR-001: motivos y alternativas de arquitectura](docs/decisiones/001-arquitectura-aplicacion.md).
- [Organización y numeración del SQL](database/README.md).
- [ADR-002: fuentes SQL y migraciones](docs/decisiones/002-organizacion-database.md).
- [Estado actual y siguiente paso](docs/ESTADO.md).
- [Configuración de Supabase y validación](docs/CONFIGURACION.md).
- [Instrucciones para agentes](AGENTS.md).

## Estado

La app existente se conserva en `flutter_application_entrehuellas`. Incluye Clean Architecture por funcionalidad (`presentation`, `domain`, `data`), Riverpod, go_router y arranque configurable de Supabase. Sin configuración se puede explorar la pantalla inicial y el acceso. El login completo pertenece a HU-01.

El dominio organiza entidades, contratos de repositorios y casos de uso; el ViewModel consume `WatchAuthSession`. En VS Code, los perfiles **Entre Huellas - desarrollo local** y **Entre Huellas - sin Supabase** permiten iniciar con F5. El perfil local requiere crear/completar el archivo de configuración una sola vez.

Repositorio: [srg-cp/entrehuellas](https://github.com/srg-cp/entrehuellas).

Desde la carpeta de la app: `flutter pub get --enforce-lockfile` y `flutter run -d chrome`. Para Supabase y el deep link `entrehuellas://login-callback/`, seguir [la configuración](docs/CONFIGURACION.md). El estado registra la validación y los requisitos Android pendientes.
