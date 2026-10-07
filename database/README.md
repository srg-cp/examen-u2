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
  tests/         # Pruebas SQL de permisos e invariantes
```

Los `.gitkeep` permiten versionar las carpetas mientras se implementan sus objetos. No hay tablas, funciones o políticas creadas por esta estructura inicial.

## Nombres y orden

Los scripts de esquema utilizan `NNN_descripcion.sql`: número de al menos tres dígitos, guion bajo y descripción en `snake_case`. La secuencia es **global entre las carpetas de esquema**, no se reinicia en cada una. Se compara el número como entero; después de `999` sigue `1000`.

Ejemplo de un futuro incremento de acceso y perfil, solo ilustrativo:

```text
tables/001_create_profiles.sql
functions/002_handle_new_user.sql
triggers/003_on_auth_user_created.sql
policies/004_profiles_rls.sql
grants/005_profiles_permissions.sql
```

El prefijo expresa el orden de dependencias, no el sprint, la HU ni el número de issue. Una extensión o tipo requerido por una tabla debe precederla. Una función debe existir antes del trigger que la utiliza. Las vistas y políticas deben seguir a los objetos de los que dependen.

`seeds` y `tests` tienen sus propias secuencias `001_...sql` y se ejecutan aparte. No forman parte del despliegue normal del esquema. Las carpetas se mantienen organizadas por objeto; no se ejecutan completas por orden alfabético de sus nombres.

## Evolución y migraciones

1. Añadir scripts numerados para el incremento, conservando el SQL en su carpeta. Un script puede crear, alterar o retirar un objeto; describir la operación en el nombre.
2. Revisar dependencias y reunir todos los scripts del incremento en orden numérico en una migración de `supabase/migrations`, antes de aplicarla.
3. Generar esa migración a partir de las fuentes, con referencias a los archivos incluidos. No mantener dos copias editables del mismo SQL. El procedimiento de generación y su registro de fuentes debe prepararse en S1 antes del primer despliegue.
4. Probar la migración y los permisos en un entorno de desarrollo. Publicar tablas de cliente solo con sus políticas y grants revisados en el mismo incremento.
5. Una vez aplicada, conservar inmutables la migración y sus scripts fuente. Un cambio posterior utiliza otro número y una nueva migración; no reescribir el historial.

La CLI de Supabase utiliza archivos `<timestamp>_<nombre>.sql` en `supabase/migrations`. Los números `001_...` identifican las fuentes organizadas; la migración registra el incremento que se aplica. [Documentación de migraciones de Supabase](https://supabase.com/docs/guides/local-development/database-migrations).

`database/functions` contiene SQL de PostgreSQL, incluidas RPC. Las Edge Functions son código de servidor y pertenecen a `supabase/functions`; no son archivos SQL.

La CLI, la generación de migraciones y la ejecución de SQL no están configuradas por crear estas carpetas. El diseño se registra en [ADR-002](../docs/decisiones/002-organizacion-database.md).

## Reglas para nuevos scripts

- Usar nombres explícitos de esquema, tabla, restricción y política. Revisar `search_path`, permisos de ejecución y cualquier función `SECURITY DEFINER`.
- Versionar juntos restricciones, RLS, grants y operaciones autorizadas del incremento. Validar actor y transición en servidor.
- Separar datos públicos del QR de datos privados. Una política de filas no controla por sí sola las columnas o archivos que se exponen.
- Conservar identificadores estables y restricciones de deduplicación en operaciones reintentables.
- Incluir pruebas entre usuarios y roles, invariantes y reintentos cuando correspondan al cambio. Registrar resultados en [ESTADO.md](../docs/ESTADO.md).
- No guardar contraseñas, cadenas SQL privadas, tokens o claves de servidor. Los seeds usan datos ficticios de desarrollo.

Estas reglas complementan [REGLAS_ARQUITECTURA.md](../docs/REGLAS_ARQUITECTURA.md). La estructura inicial corresponde a la preparación; el primer esquema funcional pertenece a S1, HU-01 / RF-01,34.
