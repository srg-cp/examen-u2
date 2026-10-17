# Entre Huellas: instrucciones del proyecto

## Contexto

Construimos el MVP de recuperación colaborativa. Android primero. La arquitectura acordada es Clean Architecture por funcionalidad con Flutter, MVVM, Riverpod, casos de uso, repositorios y Supabase como backend. La web QR forma parte del MVP. Los motivos y las consecuencias se registran en [ADR-001](docs/decisiones/001-arquitectura-aplicacion.md).

Las instrucciones explícitas del usuario prevalecen sobre este documento. El plan maestro PDF es referencia de producto; sus propuestas técnicas se actualizan con las decisiones registradas aquí.

## Inicio y alcance

- Leer `docs/REGLAS_ARQUITECTURA.md` (norma obligatoria), `docs/ESTADO.md`, `docs/ARQUITECTURA.md` y la sección del sprint pertinente en `docs/GUIA_MVP.md`.
- Comprobar rama, cambios locales y estado real antes de editar. Conservar el trabajo existente.
- Usar las HU y RF originales para trazabilidad; separar el número de historia del número de issue de GitHub.
- Implementar un incremento completo con criterios de aceptación. No ampliar el MVP por la existencia de funciones futuras en el PDF.
- Por decisión explícita del usuario del17 de octubre de2026, las aplicaciones
  se organizan en `apps/mobile` (Flutter existente) y `apps/platform` (Vue/Nuxt).
  Esta instrucción sustituye la ubicación en la raíz acordada el6 de octubre.
  No recrear los proyectos ni cambiar identificadores de paquete por moverlos.

## Implementación

- Web, decisión explícita del17/10/2026: Vue + Nuxt + TypeScript en una sola
  aplicación para público, usuarios y administración, organizada por funcionalidad
  y permisos de servidor. Flutter permanece en móvil. No separar proyectos por
  roles ni crear pantallas/guards ficticios antes de implementar autorización.
  SSR, generación estática o cliente se eligen por recorrido. Seguir ADR-058;
  ningún secreto en app/public/shared cliente, payload SSR o NUXT_PUBLIC.

- Cumplir [las reglas de oro de arquitectura](docs/REGLAS_ARQUITECTURA.md). Ningún incremento está completo si rompe sus fronteras. Registrar cambios de reglas como decisiones arquitectónicas versionadas y actualizar documentación/comprobaciones; no introducir excepciones implícitas por alcance MVP o urgencia.

- Presentation contiene pantallas, ViewModels y estado; data contiene implementaciones de repositorios y acceso a datos. Las operaciones del producto se expresan mediante casos de uso de dominio consumidos por ViewModels.
- Clean Architecture por funcionalidad: `domain/entities`, `domain/repositories` (contratos) y `domain/use_cases` independientes de Flutter, Riverpod y Supabase. Los casos de uso expresan operaciones concretas y reglas; no crear clases base genéricas ni funcionalidades vacías. Bootstrap/main inyectan implementaciones; `app` contiene bootstrap, aplicación y router.
- El alcance MVP limita las funcionalidades, no la separación de responsabilidades ni su calidad. Mantener el test de dependencias arquitectónicas al añadir funcionalidades.
- `presentation` organiza `screens`, `view_models`, `state` y `widgets` según componentes reales. La pantalla observa el estado del ViewModel; no obtiene repositorios ni combina directamente providers de infraestructura. Riverpod/AsyncValue pertenece a presentación/inyección, nunca al dominio.
- `data` organiza `data_sources`, `models` (DTO) y `repositories`. El SDK se encapsula en fuentes de datos; el repositorio mapea DTO a entidades y fallos externos a fallos de dominio. No propagar mensajes/tokens del SDK hacia la UI.
- Los providers de cada funcionalidad declaran contratos/casos de uso sin importar implementaciones ni pantallas. Bootstrap/main inyectan las implementaciones. Presentation no importa `app`; data no importa presentation/providers/app. Liberar suscripciones de presentación con autoDispose y comprobar recuperación tras error.
- Los widgets consumen ViewModels. El SDK de Supabase se usa detrás de repositorios o servicios, sin llamadas de negocio desde widgets.
- El acceso comienza en login; después mostrar las tres etapas de onboarding hasta completarlo; no se ofrece Omitir. Persistir la finalización por cuenta mediante los casos de uso y RPC protegida; no usar un indicador global por instalación. Seguir ADR-004.
- Nunca usar SnackBar en la UI del proyecto, directamente ni mediante wrappers/paquetes. No sustituirlo por una barra inferior equivalente. Por instrucción explícita del usuario, ADR-007 permite toast superior propio para éxito confirmado y ADR-009 lo amplía a errores de foto de perfil; ADR-013 permite también errores de eliminación de mascotas en el mismo toast superior; ADR-016 permite validación y errores de guardado/fotos en Registrar/Editar mascota con shake danger, sin mensajes debajo. Los demás errores/validación permanecen contextuales según ADR-005. Mantener las comprobaciones y el ciclo de vida del aviso.
- Antes de cualquier cambio visual, leer y cumplir [la regla de oro de UI y UX](docs/REGLAS_UI_UX.md). La referencia aprobada es el flujo actual de acceso/cuenta/códigos/contraseña; no reutilizar la dirección antigua ni el Inicio retirado como modelo. Consultar `docs/DISENO_UI.md` para implementación/revisión. Reutilizar componentes, dimensiones, estados y efectos; revisar renders normales/pequeños con texto ampliado, sin acciones vacías ni datos simulados.
- Retorno/cierre superior de pantallas: usar GlassNavigationButton compartido, circular glass flotante sobre el scroll, sin franja opaca; chevrón para volver y X para cerrar. Respetar insets, tooltip y área táctil. Seguir ADR-015 y REGLAS_UI_UX.
- Aplicar cover reveal seguido de stagger reveal en entradas de pantalla y cambios discretos de etapa, con cabeceras persistentes fuera del efecto y movimiento reducido respetado. No repetir efectos con edición/teclado/contadores/reenvío ni durante cada frame de un gesto; seguir ADR-006.
- Nunca indicar carga de botones mediante etiquetas con puntos suspensivos (`...` o `…`). Mantener la etiqueta y usar `LoadingShimmer` compartido durante trabajo real, con semántica de progreso y bloqueo de dobles envíos; sin spinner en botones ni shimmer por simple deshabilitación/cooldown. Mantener la comprobación automática y seguir ADR-006.
- Carga de contenido según ADR-011: skeleton en carga inicial, contenido conservado con progreso fino superpuesto durante refresh explícito de la misma cuenta. Sin textos visibles de carga ni indicadores circulares; labels accesibles permitidos. Ocultar datos anteriores al cambiar identidad y distinguir error de vacío confirmado.
- La configuración de acceso, permisos y reglas críticas se valida en Supabase: grants, RLS, restricciones y funciones autorizadas.
- Separar datos públicos del QR de coordenadas y documentos privados. La RLS controla filas; no sustituye el control de columnas expuestas.
- Versionar migraciones, políticas y funciones. No mantener cambios de esquema solamente en el Dashboard.
- Organizar fuentes SQL en `database` según `database/README.md` y ADR-002: directorios por tipo de objeto y numeración global `001_...sql`. Los scripts del incremento generan una migración en `supabase/migrations`; no mantener copias editables independientes ni reescribir SQL aplicado. Usar `database/scripts/Build-Migration.ps1` con los planes versionados y validar la migración en desarrollo antes del despliegue. `database/functions` es SQL; `supabase/functions` contiene Edge Functions.
- SQL usa identificadores en inglés con `snake_case`; Dart conserva `camelCase`/`PascalCase`. Generar `database/run_all.sql` con `database/scripts/Build-RunAll.ps1`, sin editar el resultado manualmente. Seguir ADR-003 y probar repetición/permisos al ampliar su alcance.
- La app usa clave publicable y sesión de usuario. Credenciales SQL, claves secretas y service_role permanecen en servidor.
- Guardar envíos offline con identificador estable; el servidor deduplica y valida reintentos. Diferenciar borrador, pendiente y publicado.
- Guardar la notificación antes de intentar push. Registrar fallo y permitir reintento.
- Mantener el alcance sin ASP.NET Core, SignalR, Redis ni workers de IA. Registrar una decisión arquitectónica si una necesidad posterior cambia este acuerdo.

## Validación y relevo

- Ejecutar las comprobaciones pertinentes a lo modificado. Para Flutter: formato, análisis y pruebas significativas; para datos: permisos entre usuarios, invariantes y reintentos.
- Reportar pruebas ejecutadas y pendientes; no afirmar que un build o una política funciona sin comprobarlo.
- Al terminar, actualizar `docs/ESTADO.md` con resultados, bloqueos y siguiente paso. Registrar modificaciones de alcance en la guía.
- Por instrucción del usuario, mantener una ficha por funcionalidad en `docs/funcionalidades`, enlazada desde su índice: qué hace, recorrido, reglas/campos, persistencia/permisos, errores/reintentos, dependencias/activación y validación pendiente. Actualizarla en cada incremento; distinguir funcionalidad implementada de historia cerrada y evidencia local de confirmación remota.
- Comunicar en español. Incluir resultado, validación y limitaciones materiales.
- La publicación, despliegue y acciones en GitHub siguen la autorización del usuario en la tarea actual; esta guía no concede por sí sola autorización para ejecutarlas.

- ADR-016, por instrucción explícita del usuario, exige nombre/especie/tamaño/edad/rasgos al guardar mascotas, rasgos hasta200 con contador interior; sexo opcional con Macho inicial. En Registrar/Editar los errores de campos, guardado y fotos usan shake danger y toast superior, sin mensajes debajo; las demás pantallas conservan feedback previo. No inventar datos de fichas antiguas incompletas: completar al editar metadatos y conservar sus operaciones de ciclo de vida.


## Feedback de reportes: corrección del 10 de octubre de 2026

Por instrucción explícita del usuario, los mensajes de error, validación y resultado se muestran en el toast superior compartido, sin texto contextual dentro de la pantalla ni debajo de campos/acciones. Esta instrucción sustituye las restricciones anteriores que reservaban el toast a excepciones y exigían feedback contextual. Etiquetas, datos, estados e instrucciones de privacidad se mantienen. El incremento adapta los flujos de reportes perdidos/encontrados; conserva invalid/ShakeField, acciones de reintento y ciclo de vida del aviso. Las demás funcionalidades existentes se adaptarán al intervenir sus flujos; no se afirma una migración global completada. Véase [ADR-023](docs/decisiones/023-feedback-reportes-toast-superior.md).

## Feedback global y consistencia: instrucción del 11 de octubre de 2026

El usuario extiende el toast superior a errores, validación y resultados de toda la app, sin mensajes bajo inputs ni errorText/helperText. No usar loaders circulares/lineales ni textos de carga: skeleton y LoadingShimmer; ContentRefresh aplica shimmer sobre contenido conservado en refresh. Mantener invalid/ShakeField, semántica, acciones reales y ciclo de vida del toast. Esta instrucción sustituye las reservas contextuales anteriores y la adaptación diferida de ADR-023. Véanse docs/decisiones/027-feedback-global-toast-shimmer.md y028-consistencia-fronteras-y-reutilizacion.md. No permitir presentation/data entre funcionalidades ni core→features; colaboración mediante dominio/providers declarativos.
