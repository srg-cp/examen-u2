# Entre Huellas: instrucciones del proyecto

## Contexto

Construimos el MVP de recuperación colaborativa. Android primero. La arquitectura acordada es Flutter + Riverpod + MVVM + repositorios por funcionalidad y Supabase como backend. La web QR forma parte del MVP.

Las instrucciones explícitas del usuario prevalecen sobre este documento. El plan maestro PDF es referencia de producto; sus propuestas técnicas se actualizan con las decisiones registradas aquí.

## Inicio y alcance

- Leer `docs/ESTADO.md`, `docs/ARQUITECTURA.md` y la sección del sprint pertinente en `docs/GUIA_MVP.md`.
- Comprobar rama, cambios locales y estado real antes de editar. Conservar el trabajo existente.
- Usar las HU y RF originales para trazabilidad; separar el número de historia del número de issue de GitHub.
- Implementar un incremento completo con criterios de aceptación. No ampliar el MVP por la existencia de funciones futuras en el PDF.
- La creación de la app se hará en `apps/mobile`. Crear los demás componentes cuando su sprint los necesite.

## Implementación

- Presentation contiene pantallas, ViewModels y estado; data contiene repositorios y acceso a datos. Extraer dominio/casos de uso cuando exista lógica compartida o compleja.
- Los widgets consumen ViewModels. El SDK de Supabase se usa detrás de repositorios o servicios, sin llamadas de negocio desde widgets.
- La configuración de acceso, permisos y reglas críticas se valida en Supabase: grants, RLS, restricciones y funciones autorizadas.
- Separar datos públicos del QR de coordenadas y documentos privados. La RLS controla filas; no sustituye el control de columnas expuestas.
- Versionar migraciones, políticas y funciones. No mantener cambios de esquema solamente en el Dashboard.
- La app usa clave publicable y sesión de usuario. Credenciales SQL, claves secretas y service_role permanecen en servidor.
- Guardar envíos offline con identificador estable; el servidor deduplica y valida reintentos. Diferenciar borrador, pendiente y publicado.
- Guardar la notificación antes de intentar push. Registrar fallo y permitir reintento.
- Mantener el alcance sin ASP.NET Core, SignalR, Redis ni workers de IA. Registrar una decisión arquitectónica si una necesidad posterior cambia este acuerdo.

## Validación y relevo

- Ejecutar las comprobaciones pertinentes a lo modificado. Para Flutter: formato, análisis y pruebas significativas; para datos: permisos entre usuarios, invariantes y reintentos.
- Reportar pruebas ejecutadas y pendientes; no afirmar que un build o una política funciona sin comprobarlo.
- Al terminar, actualizar `docs/ESTADO.md` con resultados, bloqueos y siguiente paso. Registrar modificaciones de alcance en la guía.
- Comunicar en español. Incluir resultado, validación y limitaciones materiales.
- La publicación, despliegue y acciones en GitHub siguen la autorización del usuario en la tarea actual; esta guía no concede por sí sola autorización para ejecutarlas.
