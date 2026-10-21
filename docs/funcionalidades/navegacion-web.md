# Navegación de usuario y recuperación web

Implementación local del 20/10/2026. [ADR-118](../decisiones/118-navegacion-web-y-recorridos-de-recuperacion.md).

## Qué hace y recorrido

Tras login y bienvenida por cuenta, Inicio, Explorar, Mis mascotas y Reportar
comparten barra inferior flotante basada en LiquidNavigation móvil. Cápsula
glass, selección azul, círculo de nueve puntos, nombres accesibles,
foco por teclado y movimiento reducido. Por corrección explícita, solo iconos
en todos los anchos; nombres en semántica. Por petición explícita del20/10,
sin tooltip al mantener el puntero sobre los cuatro controles de la barra web.
Cabecera/marca estable.
El indicador se desplaza con la barra persistente y Reportar se expande desde el
botón. [Transiciones reutilizables](transiciones-web.md), ADR-119, sustituyen
las etiquetas de escritorio y el cambio estático de selección de ADR-118.
El usuario puede desplazar todos los controles y legales por encima de la barra.
Reportar incluye una X glass flotante para cerrar y regresar a Inicio, Explorar
o Mis mascotas según el origen; entrada directa vuelve a Inicio. Reutiliza
GlassNavigationButton y la transición de retorno existente. Si hay cambios,
mantiene la confirmación de salida y bloquea el cierre durante operaciones.

- Explorar: consulta real, filtros de tipo/especie/estado y Ver más con cursor.
  Tarjetas con foto autorizada, rasgos, fecha y zona aproximada. Error no equivale
  a vacío; refresh conserva contenido con shimmer y permite reintento.
- Mis mascotas: consulta del propietario, registrar/editar nombre, especie,
  detalle de otra especie, tamaño, sexo opcional, edad en meses y rasgos.
  Añadir foto usa el verificador existente; reintentar conserva ID y bytes.
- Reportar: pérdida de mascota propia con sus fotos verificadas; posible pérdida
  con 1–3 fotos; avistamiento o custodia vinculados a búsqueda con fotos opcionales.
  Fecha/hora local, mapa compartido y referencia privada. Confirmación solo al
  recibir publicación activa del servidor. Permite Guardar borrador sin publicar.

## Reglas, persistencia y permisos

Campos de mascota según ADR-016: nombre 1–80, especie/tamaño/edad/rasgos
obligatorios; edad 0–600 meses, rasgos hasta 200 con contador interior. Macho
inicial en registro, sexo opcional. No se inventan campos antiguos incompletos.

Coordenadas exactas y referencia se envían solo al caso; Explorar recibe la
proyección pública aproximada existente. No se publica teléfono/perfil/contacto
por añadir mascota o reporte. Las fotos del navegador aceptan JPEG/PNG/WebP hasta
8 MB, se recodifican sin metadatos y pasan por pet-photo-process. Nunca se
interpreta una foto local como verificada antes de la respuesta del servidor.

RPC existentes: explore_cases, create_pet_v2/update_pet_v2, list_open_recovery_searches,
publish_lost_case, prepare_recovery_report/publish_recovery_report. Lectura pets
filtrada por propietario con RLS y columnas explícitas. APIs propias revalidan
sesión/onboarding, actor esperado y origen. Cookies/token permanecen privados.
Proxy de imágenes comprueba sesión y lectura permitida antes del Storage con JWT.

El borrador se guarda explícitamente en IndexedDB por actor, con UUID/fotos,
restaurable hasta siete días; no se comparte entre cuentas desde la UI ni se
sincroniza entre dispositivos. No guarda contraseñas/tokens. Publicar confirmado
intenta borrarlo; un fallo local no invalida la confirmación remota. Reintento
de respuesta incierta conserva exactamente el envío y bloquea edición.

## Errores y reintentos

TopToast compartido; invalid/shake en campos, sin mensajes inferiores. Skeleton
inicial, shimmer en trabajo real/refresh, sin indicadores circulares ni cambios
de etiqueta con puntos suspensivos. Formularios se conservan ante fallo. Estado
de cada ViewModel se libera al desmontar y al cambiar identidad. Salida con datos
pendientes se confirma, sin bloquear la lectura normal de las otras secciones.

## Activación y límites

Requiere configuración Auth/sesión, SQL/RLS y Edge fotográfica ya utilizadas por
móvil, además de NUXT_PUBLIC_MAP_TILE_URL. Sin migraciones nuevas. No se ha aplicado
SQL remoto ni publicado la web. La navegación y su UI no conceden permisos.

Alcance inicial: lista Explorar; hasta 100 mascotas activas propias; alta/edición
y adición de fotos. No incluye mapa de resultados, ficha autenticada completa,
retirada/ordenación de fotos, mascotas archivadas/baja, seguimiento ni todos los
recorridos móviles. No se cierran historias ni issues por este incremento.

## Validación

Pruebas de dominio/arquitectura y servidor con fixture; QA Chrome de las cuatro
entradas, filtros, mascota alta/edición/foto, cuatro reportes, borrador y reintento.
Renders 1440/390/320 y texto 200%, sin overflow/CSP/hidratación. Evidencia en
apps/mobile/build/ui-preview/web-recovery y resultados finales en ESTADO.
Pendiente integración Supabase real con dos cuentas y revisión de teclado/fotos
y área segura en navegadores físicos; no afirmar validación remota de RLS.
