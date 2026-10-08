# Base de datos de Entre Huellas

Esta carpeta contiene las fuentes SQL de PostgreSQL/Supabase, organizadas por tipo de objeto. El esquema y los permisos se incorporan por funcionalidad. La base de datos se ejecuta en Supabase; este directorio guarda su código versionado.

## Estructura

```text
database/
  extensions/    # Extensiones requeridas
  types/         # Tipos y enumeraciones
  tables/        # Tablas, claves y restricciones
  indexes/       # Índices adicionales
  functions/     # Funciones PostgreSQL y RPC
  triggers/      # Triggers y su vinculación a funciones
  views/         # Vistas y contratos de lectura
  policies/      # Habilitación de RLS y políticas
  grants/        # Privilegios y revocaciones
  seeds/         # Datos de desarrollo sin información privada
  tests/         # Pruebas SQL y PostgreSQL en memoria
  migration_plans/ # Fuentes incluidas en cada incremento
  scripts/       # Generadores PowerShell
  run_all.sql    # Entrada SQL generada y repetible del incremento actual
```

Los `.gitkeep` permiten versionar las carpetas mientras se implementan sus objetos. El incremento de acceso contiene las fuentes 001–007: perfiles, funciones, triggers, RLS, grants y carga de perfiles de cuentas existentes. Su ejecución remota aún no se ha realizado.

## Nombres y orden

Los scripts de esquema utilizan `NNN_descripcion.sql`: número de al menos tres dígitos, guion bajo y descripción en `snake_case`. La secuencia es **global entre las carpetas de esquema**, no se reinicia en cada una. Se compara el número como entero; después de `999` sigue `1000`.

Fuentes del primer incremento de acceso y perfil:

```text
tables/001_create_profiles.sql
functions/002_handle_new_auth_user.sql
functions/003_set_profile_updated_at.sql
triggers/004_profiles_auth_triggers.sql
policies/005_profiles_owner_policies.sql
grants/006_profiles_permissions.sql
tables/007_backfill_existing_profiles.sql
```

El prefijo expresa el orden de dependencias, no el sprint, la HU ni el número de issue. Una extensión o tipo requerido por una tabla debe precederla. Una función debe existir antes del trigger que la utiliza. Las vistas y políticas deben seguir a los objetos de los que dependen.

`seeds` y `tests` tienen sus propias secuencias `001_...sql` y se ejecutan aparte. No forman parte del despliegue normal del esquema. Las carpetas se mantienen organizadas por objeto; no se ejecutan completas por orden alfabético de sus nombres.

## Evolución y migraciones

1. Añadir scripts numerados para el incremento, conservando el SQL en su carpeta. Un script puede crear, alterar o retirar un objeto; describir la operación en el nombre.
2. Revisar dependencias y reunir todos los scripts del incremento en orden numérico en una migración de `supabase/migrations`, antes de aplicarla.
3. Generar esa migración a partir de las fuentes, con referencias a los archivos incluidos. No mantener dos copias editables del mismo SQL. `scripts/Build-Migration.ps1` utiliza un plan de `migration_plans` y registra cada fuente con su SHA256 normalizado.
4. Probar la migración y los permisos en un entorno de desarrollo. Publicar tablas de cliente solo con sus políticas y grants revisados en el mismo incremento.
5. Una vez aplicada, conservar inmutables la migración y sus scripts fuente. Un cambio posterior utiliza otro número y una nueva migración; no reescribir el historial.

La CLI de Supabase utiliza archivos `<timestamp>_<nombre>.sql` en `supabase/migrations`. Los números `001_...` identifican las fuentes organizadas; la migración registra el incremento que se aplica. [Documentación de migraciones de Supabase](https://supabase.com/docs/guides/local-development/database-migrations).

`database/functions` contiene SQL de PostgreSQL, incluidas RPC. Las Edge Functions son código de servidor y pertenecen a `supabase/functions`; no son archivos SQL.

El generador está preparado; la CLI y la ejecución remota no están configuradas por crear estas carpetas. El diseño se registra en [ADR-002](../docs/decisiones/002-organizacion-database.md).

## Reglas para nuevos scripts

- Usar nombres explícitos de esquema, tabla, restricción y política. Revisar `search_path`, permisos de ejecución y cualquier función `SECURITY DEFINER`.
- Versionar juntos restricciones, RLS, grants y operaciones autorizadas del incremento. Validar actor y transición en servidor.
- Separar datos públicos del QR de datos privados. Una política de filas no controla por sí sola las columnas o archivos que se exponen.
- Conservar identificadores estables y restricciones de deduplicación en operaciones reintentables.
- Incluir pruebas entre usuarios y roles, invariantes y reintentos cuando correspondan al cambio. Registrar resultados en [ESTADO.md](../docs/ESTADO.md).
- No guardar contraseñas, cadenas SQL privadas, tokens o claves de servidor. Los seeds usan datos ficticios de desarrollo.

Estas reglas complementan [REGLAS_ARQUITECTURA.md](../docs/REGLAS_ARQUITECTURA.md). La estructura inicial corresponde a la preparación; el primer esquema funcional pertenece a S1, HU-01 / RF-01,34.

## Ejecutar el incremento de acceso

Desde la raíz del repositorio:

```powershell
./database/scripts/Build-Migration.ps1
```

El plan `migration_plans/001_auth_profiles.json` genera `supabase/migrations/20261007000100_auth_profiles.sql`. Valida nombres, números globales únicos, dependencias por orden numérico y rutas dentro de `database`. La misma entrada produce el mismo archivo; si la migración existe con contenido diferente, rechaza sobrescribirla.

Para la ejecución manual repetible en Supabase de desarrollo, usar **run_all.sql**, como se explica abajo. La migración generada se conserva para el historial de despliegue y se aplica una vez mediante el flujo de migraciones. No ejecutar carpetas por separado, editar artefactos generados ni aplicar la migración inicial después de haber creado sus objetos con run_all. El registro de una aplicación manual en el historial de la CLI se debe conciliar antes de adoptar despliegues con esa CLI.

Supabase Auth gestiona `auth.users`, contraseñas y proveedores. El SQL no crea una tabla de contraseñas ni habilita Google. `public.profiles` referencia la identidad de Auth, guarda nombre y ciudad, crea el perfil por trigger y completa perfiles de cuentas existentes. Solo el propietario puede leer su fila y modificar nombre/ciudad; los clientes no escriben identidad ni timestamps, ni insertan o eliminan perfiles. Los metadatos se usan solo como nombre visible, nunca como autorización.

Después de aplicar, ejecutar aparte `database/tests/001_profiles_permissions.sql` en desarrollo. Comprueba dos usuarios, aislamiento, modificación autorizada, columnas protegidas, acceso anónimo y ejecución de la función privilegiada. Usa usuarios ficticios y termina en `ROLLBACK`. Estas comprobaciones requieren PostgreSQL/Supabase real: el análisis sintáctico local no verifica RLS.

Para probar correo/contraseña, usar una cuenta existente de **Authentication → Users**; puede crearse una cuenta de prueba mediante **Add user**. El registro desde la app aún no está implementado. Para Google y el retorno móvil, seguir [CONFIGURACION.md](../docs/CONFIGURACION.md).

## Entrada manual: run_all.sql

Abrir **Supabase → SQL Editor → New query**, pegar el contenido completo de [run_all.sql](run_all.sql) y ejecutar. Puede repetirse sobre una base compatible: no duplica tablas, funciones, triggers, políticas ni perfiles, y conserva los nombres, ciudades y fechas existentes. También acepta una base donde ya se aplicó la migración inicial de perfiles.

El archivo contiene su propia transacción. Crea objetos ausentes, asegura RLS/permisos y completa perfiles faltantes. Comprueba la estructura esperada de `profiles` antes de modificarla; una incompatibilidad produce error y requiere revisión. No elimina datos ni sustituye las funciones/políticas/triggers de la base inicial; la RPC de onboarding 009 tiene repetición explícita mediante CREATE OR REPLACE. Esto no repara automáticamente definiciones alteradas manualmente; ejecutar las pruebas de permisos y versionar correcciones como nuevas migraciones.

Para regenerarlo desde la raíz del repositorio:

```powershell
./database/scripts/Build-RunAll.ps1
```

Es un archivo generado, no otra fuente editable. El generador comprueba primero la migración existente y añade referencias/hashes de las fuentes. Su alcance actual comprende perfiles y onboarding (001–009); si cambia el plan, exige revisar las nuevas operaciones antes de ampliar la entrada. Seeds y tests no se incluyen. La decisión y límites están registrados en [ADR-003](../docs/decisiones/003-ejecucion-sql-idempotente.md).

## Estándar de nombres y SQL

| Elemento | Regla y ejemplo |
| --- | --- |
| Esquemas, tablas, columnas y objetos | Inglés, minúsculas y `snake_case`, sin identificadores con mayúsculas entre comillas. |
| Tablas | Plural: `profiles`, `pets`, `lost_cases`. |
| Columnas | `display_name`, `created_at`, `owner_id`; `id` para identidad propia. |
| Funciones | Verbo y propósito: `handle_new_auth_user`, `set_profile_updated_at`. |
| Triggers y políticas | Describir entidad/operación: `profiles_set_updated_at`, `profiles_select_own`. |
| Restricciones e índices | Incluir tabla y propósito: `profiles_city_length`; sufijos PostgreSQL `_pkey`, `_fkey`, `_idx` según el objeto. |
| Booleanos | `is_active`, `has_notifications`; expresar una condición. |
| Archivos de esquema | Secuencia global y operación: `008_add_profile_avatar.sql`. |
| Código SQL | Palabras clave en minúsculas siguiendo los scripts actuales; sangría de cuatro espacios y nombres de esquema explícitos. |
| Fechas | `timestamptz` para instantes; generadas en servidor cuando corresponde. |
| Dart | Variables/propiedades `camelCase`, clases `PascalCase`, archivos `snake_case.dart`; el DTO mapea los nombres SQL. |

`snake_case` es nuestra convención de base de datos. PostgreSQL convierte los identificadores sin comillas a minúsculas; `camelCase` obligaría a conservarlos con comillas o perdería las mayúsculas. [Documentación de identificadores](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS).

## Pruebas locales de repetición

Desde `database/tests`, con Node instalado:

```powershell
npm ci --ignore-scripts
npm test
```

Utilizan PostgreSQL en memoria con PGlite y una fixture mínima de Auth: no necesitan claves ni contactan Supabase. Comprueban repetir la entrada sin modificar datos/fechas/objetos, permisos entre usuarios después de repetirla, compatibilidad con la migración anterior y rechazo de una tabla incompatible. La prueba SQL de permisos también debe ejecutarse en Supabase de desarrollo para verificar su entorno real.

## Incremento 008–009: onboarding

El formulario de Crear cuenta usa Supabase Auth y envía `full_name`; el trigger 002 existente crea el perfil. No se añade SQL para guardar contraseñas ni otro insert desde Flutter. Registro y confirmación por correo reutilizan el esquema 001–009 y requieren que esté aplicado en desarrollo.

Añade `profiles.onboarding_completed_at` y `complete_onboarding()`. Solo se permite leer la fecha propia. El cliente no puede escribirla ni reiniciarla directamente: la RPC usa `auth.uid()`, fija fecha de servidor solo si estaba vacía y rechaza falta de sesión/perfil. Comenzar finaliza el recorrido con la misma RPC persistente; la interfaz ya no ofrece Omitir. La fecha pertenece a la cuenta y sobrevive a reinstalación/cambio de dispositivo.

El plan `002_onboarding.json` genera una migración nueva; la inicial permanece intacta. `run_all.sql` ahora incluye ambas fuentes nuevas y acepta tablas de perfiles anteriores (cinco columnas) o actualizadas (seis). La RPC 009 usa `CREATE OR REPLACE` de forma explícita y revisada para repetir su definición; las funciones de la base 001–007 siguen protegidas por existencia. `tests/002_onboarding_permissions.sql` comprueba finalización propia, repetición, prohibición de reinicio y aislamiento de otra cuenta.
