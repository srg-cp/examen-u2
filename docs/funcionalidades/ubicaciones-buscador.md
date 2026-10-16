# Buscador compartido de ubicaciones y ciudades

Módulo places, extraído el16 de octubre de2026 para Explorar (HU-07/RF-13) y Perfil (HU-01.7/RF-01). [ADR-051](../decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

## Qué hace y recorrido

Sugerencias al escribir3–120 caracteres tras pausa600ms. En Ubicación busca ciudad/dirección para elegir centro del mapa; en Perfil solo ciudades/asentamientos para confirmar Ciudad. Selección explícita, cinco resultados, campo editable mientras consulta, sin botón de búsqueda; teclado admite envío inmediato cuando no hay otra petición.

## Reglas, persistencia y permisos

Dominio/DTO/fuente Photon/repositorios/providers/ViewModel/widget únicos. Modo ciudad solicita layer=city y descarta tipos incompatibles/etiquetas mayores120; nombre/región/país. Caché30 consultas/5min en memoria, separada por modo; sin historial persistente. Solo el texto escrito se consulta al proveedor, sin sesión/tokens/datos privados. Perfil guarda etiqueta elegida, no coordenadas; su ciudad anterior se conserva hasta modificar/seleccionar/vaciar.

Router compone el buscador en slots de ambas funcionalidades; sin imports entre sus presentaciones. PLACE_SEARCH_URL mantiene endpoint HTTPS configurable. Atribución enlazada OpenStreetMap y condiciones de demo Photon conservadas; no acredita cobertura oficial o servicio de producción.

## Errores y reintentos

Toast superior para errores, skeleton/shimmer en consulta real. Una petición activa y última pendiente reemplazable; editar/seleccionar/limpiar/cambio de identidad/desmontaje invalidan respuestas y cancelan temporizadores. No se inventan resultados. Perfil no admite guardar texto nuevo sin selección; se permite vaciar valor opcional y conservar datos anteriores.

## Activación y validación

Sin SDK/clave/migración nueva para el buscador. Inyección de places desde bootstrap/main. Formato/análisis sin incidencias, contratos/fixtures adaptados sin ejecutar pruebas por petición del usuario. Pendiente Android: ambos modos, ciudades reales del proveedor, selección/descartar, fallo/reintento, texto ampliado y cambio de cuenta. No se hicieron consultas reales ni se garantiza disponibilidad futura.
