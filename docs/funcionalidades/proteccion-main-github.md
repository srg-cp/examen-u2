# Protección de main en GitHub

Configuración operativa solicitada y activada el30/10/2026 en
`srg-cp/entrehuellas`. No añade historias de producto ni cambia el alcance MVP.

## Qué hace y recorrido

Los cambios se publican en otra rama y se integran en `main` mediante pull request.
GitHub exige ese recorrido también para administradores. Bloquea force push y
borrado de `main`; las ramas de trabajo conservan sus operaciones habituales.

Con el árbol limpio, actualizar main y crear una rama `feature/<cambio>`.
Implementar y comprobar; con autorización de publicación, realizar commit y push
de esa rama, abrir PR hacia main, revisar diff/resultados e integrar desde el PR.
Actualizar main local antes del siguiente incremento.

## Persistencia y permisos

[Ruleset26223286](https://github.com/srg-cp/entrehuellas/rules/26223286), nombre
`main: cambios solo mediante pull request`, target `branch`, enforcement `active`.
Incluye únicamente `refs/heads/main`, sin exclusiones y con `bypass_actors: []`.
Reglas: `pull_request`, `deletion` y `non_fast_forward`.

El PR exige cero aprobaciones externas, permitiendo integración individual.
No exige code owners, aprobación del último push ni resolución de conversaciones;
conserva merge/squash/rebase y no añade checks de CI obligatorios. Las comprobaciones
del proyecto siguen siendo necesarias antes de integrar.

La configuración persiste en GitHub, independiente de publicar esta documentación.
Administradores con permisos de configuración pueden editar o desactivar la regla;
no pueden omitirla mientras siga activa con esta lista de bypass vacía.

## Errores y reintentos

Si se rechaza un push a main, conservar los commits en una rama de trabajo,
publicar esa rama y abrir PR. No reintentar con force ni desactivar la protección.
Errores de permisos al administrar la regla requieren una cuenta con acceso admin;
comprobar reglas existentes antes de recrearla para evitar duplicados.

## Activación y validación

Activación remota confirmada mediante GitHub CLI con la cuenta administradora
`srg-cp`. Consultas posteriores del ruleset y reglas efectivas de main confirman
las tres reglas, estado active y `current_user_can_bypass: never`. Consulta de
reglas para `feature/proteccion-main-github` devuelve lista vacía.

No se intentó un push real de prueba ni se creó o integró un PR de prueba.
Pendiente observar el próximo recorrido de publicación autorizado. No cambia
código, permisos de Supabase, despliegues ni funcionalidades de móvil/web.
