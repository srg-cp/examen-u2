# Registro, edición y ciclo de vida de mascotas

Módulo: `pets`. HU-03 / RF-03; issues
[#28](../backlog/028-HU-03.1.md) y [#29](../backlog/029-HU-03.2.md).

## Qué hace y cómo se usa

Mis mascotas separa Activas y Archivadas. Permite registrar una mascota,
consultar su ficha, editar metadatos y [gestionar sus fotos](fotos-mascotas.md).
La ficha permite archivar/restaurar; el listado ofrece eliminación por swipe
con confirmación. Archivar conserva ficha y fotos, y restaurar devuelve la
mascota a Activas. Registrar una mascota aún no publica un caso perdido.

## Campos y reglas

| Campo | Regla al guardar |
| --- | --- |
| Nombre | Obligatorio,1–80 puntos de código Unicode |
| Especie | Perro, gato u otra; Otra requiere tipo concreto de1–60 |
| Tamaño | Pequeño, mediano o grande; obligatorio |
| Edad | Obligatoria; almacenamiento en meses,0–600 |
| Rasgos | Obligatorios,1–200; contador dentro del campo |
| Sexo | Opcional; Macho como selección inicial del editor |

La validación se aplica antes de escribir y también en SQL. Las fichas antiguas
incompletas no reciben datos inventados: al editar metadatos deben completarse;
se mantienen sus operaciones de ciclo de vida autorizadas.

Cada borrador tiene UUID estable para reintentar creación sin duplicar mascota.
Edición usa versión esperada para detectar cambios concurrentes. Un error conserva
el borrador; éxito solo tras confirmar el guardado. No hay cola offline persistente
ni promesa de transacción única entre metadatos y archivos.

## Privacidad, archivo y eliminación

La ficha y sus fotos pertenecen a la cuenta, con restricciones de servidor.
Archivar se rechaza cuando hay casos activos. Eliminar se rechaza si existe
historial o casos activos; el flujo marca baja, limpia archivos y verifica
la limpieza antes de finalizar. Un fallo no se presenta como eliminación exitosa.
S3 deberá actualizar los indicadores de casos en la misma transacción.

En Registrar/Editar, validación, guardado y fotos usan shake danger y toast
superior sin mensajes debajo; eliminación sigue ADR-013. Los demás recorridos
conservan sus reglas de feedback.

## Dependencias y validación

CreatePet, UpdatePet, ListMyPets, ReadPet, ArchivePet, RestorePet y DeletePet.
RPC versionadas, RLS y Storage; [configuración](../CONFIGURACION.md).
Verificar creación/edición, cancelación, reintento, conflictos, archivo/restauración,
eliminación fallida y aislamiento A/B. Evidencia y pendientes en [ESTADO](../ESTADO.md).
