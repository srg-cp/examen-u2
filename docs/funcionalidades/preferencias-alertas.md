# Preferencias de alertas por cuenta

Módulo: `alert_preferences`. HU-02.2 / RF-02,16;
[issue #27](../backlog/027-HU-02.2.md).

## Qué hace y cómo se usa

Desde Perfil se configura si recibir alertas, qué tipos interesan y qué canales
se prefieren. Los tipos son mascotas perdidas, encontradas y novedades de casos;
los canales son dentro de la app y push. Pausar conserva las elecciones.

Estas elecciones se guardan por cuenta. Todavía no crean avisos, envían push,
registran tokens de dispositivo ni solicitan permisos Android. La bandeja y
entrega corresponden a HU-12, después de disponer de casos.

## Reglas, estado y persistencia

Sin configuración guardada: recepción desactivada; tres tipos seleccionados;
canal dentro de la app activo y push desactivado. Para habilitar recepción debe
haber al menos un tipo y un canal. Versión cero representa primera escritura.

SaveAlertPreferences envía la selección completa y versión esperada. El servidor
comprueba sesión, reglas y versión; un reintento idéntico reconoce el resultado,
guardar sin cambios no altera versión y una selección incompatible genera conflicto.
Lectura propia con RLS y RPC protegida; no se acepta un propietario arbitrario.

El editor conserva borrador tras fallo y bloquea dobles envíos. Salir, consultar
versión actual o refrescar cuando se perderían cambios pide confirmación.
Cambio de identidad limpia datos anteriores; una misma cuenta recuperada tras
error puede volver a cargar. Éxito superior solo tras confirmación del servidor;
errores contextuales. No hay cola offline persistente.

## Dependencias y validación

Patch011; ReadAlertPreferences/SaveAlertPreferences y repositorio Supabase.
El usuario reporta parche aplicado y validación de HU-02; las pruebas y pendientes
detallados están en [ESTADO](../ESTADO.md). Verificar cambio de cuenta, pausa,
reapertura, selección inválida y conflictos; no probar recepción real como si
estuviera implementada.

HU-12 deberá consultar preferencias vigentes al generar/reintentar avisos y
persistir la notificación antes de intentar push. [ADR-019](../decisiones/019-preferencias-alertas-por-cuenta.md).
