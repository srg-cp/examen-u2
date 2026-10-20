# ADR-105: tipografía del título de Inicio móvil

Fecha:20/10/2026. Estado: aceptada por instrucción explícita del usuario.

El usuario solicita aplicar al título «Su regreso empieza contigo» el estilo
de su captura: formas geométricas suaves, comienzo ligero y remate más grueso.
Se usa Poppins como aproximación visual, sin afirmar identificar la fuente
original. Primera línea «Su regreso» gris #454746/peso400; segunda «empieza
contigo» azul #459FF6/peso600. Tamaño23 e interlineado1.25.

Excepción local a la fuente del sistema en REGLAS_UI_UX: solo este título.
Los dos pesos se empaquetan en Flutter con licencia OFL, procedentes de
https://github.com/google/fonts/tree/main/ofl/poppins. No hay descarga de
fuentes en ejecución ni dependencia nueva. Text.rich conserva ampliación,
ajuste natural de líneas y una etiqueta accesible con la frase completa.
La tarjeta conserva GlassSurface y su entrada compartida.

No cambia arquitectura, navegación, persistencia ni alcance de historias.
Validación y revisión nativa pendiente se registran en ESTADO e Inicio.
