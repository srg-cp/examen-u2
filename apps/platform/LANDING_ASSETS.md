# Ilustraciones independientes de la landing

Generadas el17 de octubre de2026 con la herramienta integrada image_gen, aplicando la habilidad imagegen. Siete llamadas independientes, una por ilustración; sin CLI/API ni credenciales. Referencia de estilo: captura de personajes facilitada por el usuario en este chat. No se utilizó esa captura como textura, fondo, atlas o recurso de la página final.

Los PNG originales de generación se conservan con transparencia en `public/images/landing`. Sin escalar artificialmente ni recortar un mockup; las dimensiones finales se registran en `landing_artwork.ts`. No se promete resolución 4K ni detalle infinito. El logo no se genera: se usa el recurso oficial existente `/brand.png`, también usado por la plataforma.

## Prompts finales

Prompt de perro curioso: una ilustración independiente cuadrada, fondo realmente transparente, del cachorro pastor alemán dorado/negro de la referencia, ojos marrones grandes, orejas expresivas erguidas, hocico crema, nariz brillante, cabeza inclinada y expresión alegre, pañuelo carbón sin emblema. Personaje de animación3D detallado, iluminación de estudio suave y cálida, bordes definidos. Busto con patas delanteras, orejas completas dentro del encuadre. Sin texto/logotipo/UI/marcos/fondos/degradados/marca de agua. Solicitado2048×2048; se conserva la resolución real devuelta, sin inventar píxeles.

Prompt común para los seis restantes: `Use case: stylized-concept. ONE independent production 3D illustration, not a website screenshot. Use the attached reference ONLY for the puppy/kitten character identity and premium 3D style. Same adorable tan-and-black German shepherd puppy, large brown eyes, upright expressive ears, cream muzzle; same fluffy seal-point ragdoll kitten, blue eyes, cream coat and brown ears/mask/tail. Simple charcoal bandanas without emblems. Detailed soft fur, expressive friendly faces, warm soft studio lighting, polished animated-film render, crisp edges, high resolution. Genuine TRANSPARENT BACKGROUND. Entire characters/ears inside canvas with 6% clear margin. NO text, NO labels, NO UI, NO cards, NO frames, NO website, NO collage, NO colored background, NO watermark, NO logos.`

Se añade la escena correspondiente:

| Archivo PNG | Especificación de escena añadida |
| --- | --- |
| dog-curious.png | Perro curioso descrito arriba; personaje base de Busco, hero y footer. |
| cat.png | Square2048×2048. ONLY the ragdoll kitten, front three-quarter sitting bust, front paws visible, looking up with adorable bright blue eyes and tongue slightly peeking, fluffy curled tail along side. No puppy. |
| dog-wave.png | Square2048×2048. ONLY the German shepherd puppy greeting the viewer, one front paw raised with realistic dark pads visible, happy open mouth, pink tongue, expressive eyes; friendly sitting bust. No kitten. |
| reunion.png | Square2048×2048. Puppy and kitten together, cuddling cheek to cheek, kitten eyes happily closed, puppy delighted, both front paws visible. Intimate warm reunion pose. |
| dog-report.png | Square2048×2048. German shepherd puppy proudly holding a small white paper notice in a front paw, paper contains ONLY a small simple purple paw symbol and three pale blue abstract horizontal lines, no letters or words. Puppy smiles at viewer. Single illustration, not a card layout. |
| pets-home.png | Landscape2048×1024. Puppy and kitten lying comfortably side by side in front of a small warm pale-wood pet house with a heart-shaped opening, a few rounded green plants on either side. Both pets as protagonists; fully visible ears and paws. Compact arrangement at bottom, no floor rectangle, surroundings transparent. No words or graphic heart stickers. |
| pets-map.png | Landscape2048×1024. Puppy and kitten collaborating over an unfolded pale street map, a single friendly purple location pin standing in middle of map, a few small rounded green leaves at edges. Both looking toward viewer/map, visible ears and paws; coherent compact tableau. No letters, words, borders or graphic labels; transparent surroundings. |

## Composición real

LandingArt inserta un PNG independiente mediante img con dimensiones nativas y carga diferida salvo hero. El mismo personaje se reutiliza donde tiene sentido para mantener identidad y caché; seis tarjetas no implican seis descargas distintas. LandingCharacterCard contiene figura, etiqueta HTML y decoración SVG. Superficies, fondos, degradados, círculos, ubicaciones decorativas, bordes, botones y textos se implementan en Vue/CSS/SVG. Sin desplazamientos/variables de atlas ni máscaras para ocultar restos de captura.

La animación aprobada del hero conserva cover-reveal y stagger-reveal, duraciones/demoras y movimiento reducido. Este cambio no altera el QR ni sus fotos de producto.

Dimensiones reales de entrega: cinco PNG de1254×1254 y dos de1774×887, todos RGBA. La petición de tamaño en el prompt no implica que la herramienta haya devuelto ese tamaño exacto. Se conservaron los píxeles devueltos sin reescalado artificial. Los originales ocupan aproximadamente12.5MB en conjunto; carga diferida y reutilización por URL reducen descargas iniciales, sin acreditar todavía Core Web Vitals ni transferencia en red móvil real.
