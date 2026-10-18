# Seguimiento y alertas

HU-12.1/#40, HU-12.2/#41 y HU-12.3/#42; RF-16,17,18. Implementación local
Android/SQL/Edge.027 aplicado según confirmación del usuario; historias abiertas,
demo real y activación de push pendientes, sin inspección remota independiente.

## Qué hace y recorrido

- Ficha disponible → Seguir caso / Dejar de seguir. Separado del marcador Guardados.
- Perfil → Ubicaciones de interés → Seguir zona / Dejar de seguir, sobre zonas reales.
- Campana de Inicio → Alertas → bandeja paginada → Marcar leída / Abrir caso.
- Desde Alertas se abren preferencias existentes y Activar avisos en este teléfono.
- Un push abre la bandeja después de login/onboarding; no omite autorización.

## Reglas, campos y persistencia

Seguimiento por cuenta/origen/UUID, versión y UUID de orden. Sin activación
automática para guardados o zonas previas; sin GPS continuo. Recepción depende
de enabled, tipo y canales de las preferencias. Zonas comparadas en servidor
con ubicación pública aproximada; coincidencias se deduplican.

Publicaciones pertinentes notifican seguidores de zonas. Novedades de casos
(avistamientos, avisos vinculados y revisión) y cierre notifican responsable y
seguidores del caso, según preferencias. No se generan nuevas alertas de
búsqueda cuando el caso está cerrado. Instalación no fabrica historial.

Notificación y trabajo push se guardan juntos. Push solo también conserva un
recibo en bandeja. Sin datos privados en títulos/payload: nunca coordenadas,
comentarios, fotos, motivos o datos de cuenta. Bandeja pagina20, máximo50 por RPC,
cursor ID descendente; lectura persistida por cuenta e idempotente.
Abrir consulta autorización actual; caso retirado puede no estar disponible.

Tablas de suscripciones/órdenes/notificaciones/dispositivos/outbox con RLS y
sin grants directos. RPC de cliente usan auth.uid(); claim/finish solo service_role.
Firebase no sustituye Supabase Auth. Token limitado a10 activos por cuenta,
reasignado al cambiar cuenta y desactivado al recibir UNREGISTERED.

## Errores y reintentos

Toast superior compartido, skeleton inicial y shimmer en operaciones/refresh;
contenido conservado solo para la misma identidad. Reintentar consulta tras error.
No confirmar seguimiento ni leído antes del recibo persistido. Respuesta ambigua
repite misma orden; conflicto requiere consulta; cambio de identidad oculta datos.

FCM caído conserva bandeja y trabajo pendiente con backoff. Claim vencido se
recupera, lease obsoleto no confirma otro intento. Revalidación de preferencias,
estado y seguimiento antes de reclamar. Sin dispositivo se difiere1 hora.
Aceptación de FCM no garantiza entrega; se admite repetición del push tras acuse
perdido, sin duplicar bandeja, con tag estable y TTL60s. Detalle en ADR-067.

## Dependencias y activación

HU-02 zonas/preferencias y HU-05/06/10/11;026 ya confirmado por usuario.
027 ya aplicado según usuario; actualizar Flutter y activar Edge/planificador
según [CONFIGURACION](../CONFIGURACION.md). Configuración Firebase local no incluida.
No requiere actualizar Nuxt para crear avisos: triggers cubren las escrituras
web/app existentes. Flutter sin Firebase configurado conserva bandeja/seguimiento.

## Validación

Pruebas locales de permisos/deduplicación/páginas/lectura/CAS/leases y proveedor
simulado; ViewModels/arquitectura/navegación y renders390×844/320×350 con texto2.
Resultados definitivos y logs en [ESTADO](../ESTADO.md).
Pendiente: demo hosted con027, dos sesiones concurrentes, Android con permisos/token real,
app terminada, cambio de cuenta/logout offline y FCM caído/restaurado; sin cierre
de issues ni certificación de entrega. Build Android no acreditado por pruebas Dart.
