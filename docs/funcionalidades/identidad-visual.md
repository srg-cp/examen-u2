# Identidad visual y recursos de marca

Exportación posterior de23:30 del17/10: repetida sincronización global con el
generador existente. Cinco copias verificadas idénticas,40 iconos legibles y
PNG/SVG/favicon nuevos confirmados por HTTP en5173. Sin cambios de componentes,
gradiente ni layout; sin build o instalación nueva. Evidencia en ESTADO.

Nueva exportación del usuario17/10, posterior al ajuste del pie: sincronizadas
otra vez las cinco copias oficiales PNG/SVG, splash y todos los catálogos de
iconos mediante el generador existente. Gradiente de fondo conservado por la
fuente nueva. Copias verificadas byte a byte y logo nuevo servido en web;
análisis/11 pruebas Flutter aprobados. No implica instalación o publicación.

Actualización solicitada17/10/2026, sin nueva HU/RF/issue. Fuentes oficiales en `logo/`; el usuario mantiene sus exportaciones SVG/PNG. No se recrea el símbolo ni se modifican sus originales.

## Recorrido y componentes

Web: LandingBrand y WebShell usan /brand.png actualizado; favicon /brand-icon.png desde el PNG oficial256. /brand.svg conserva el vector completo disponible. Landing usa diez ilustraciones PNG independientes, mascotas variadas y pañuelos de colores. El emblema de only-black.svg se suministra a imagegen como referencia monocroma para estamparlo en blanco siguiendo la tela; no existen logos superpuestos desde CSS/SVG. La animación hero permanece aprobada/sin cambios.

Flutter: BrandMark/BrandWordmark/StartupReveal consumen app_icon.png actualizado. Android splash y launcher clásico/adaptativo/monocromo se regeneran. También iconos de catálogos iOS/macOS, Windows y los recursos web heredados, conservando identificadores/estructura del proyecto. No activa la aplicación Flutter Web ni entrega plataformas futuras.

## Persistencia, permisos y errores

Recursos estáticos sin datos personales, sesiones, cambios de SQL ni autorización. Archivos del usuario conservados; derivados copiados/generados desde sus fuentes. Sin operaciones remotas de producto, errores de formulario ni reintentos ficticios. El logo de Google es ajeno y permanece intacto.

## Activación y validación

Nueva exportación azul17/10: sincronizadas las copias PNG/SVG de landing/lector
QR/favicon, Flutter y splash Android; regenerados launchers Android
clásico/adaptativo/monocromo, iOS/macOS, Windows y web/PWA. Los metadatos de color
de PWA y el fondo de composición iOS siguen el nuevo gradiente. El generador
sincroniza ahora las copias oficiales antes de generar catálogos, evitando que
una nueva exportación deje recursos anteriores. No se cambian componentes,
animaciones ni ilustraciones con estampados blancos; only.svg/only-black.svg
siguen siendo las fuentes auxiliares existentes. Evidencia en ESTADO.

Generación: desde apps/mobile, ./tool/generate_android_icons.ps1. Regenera recursos y preserva la bandera Xcode de Swift asset symbols. Flutter requiere compilación/reinstalación para renovar el icono del launcher; un hot reload no demuestra su cambio. Web requiere publicar/redeploy cuando se autorice.

Pruebas/tipos/análisis/renders y pendientes concretos en ESTADO. No se afirman builds Android/iOS/macOS/Windows ni instalación real por haber generado recursos. Renders usan imágenes estáticas y fixtures; confirmación remota pendiente. Prompts en apps/platform/LANDING_ASSETS.md.

Corrección de ilustraciones17/10: siluetas de pelaje natural sin contorno añadido
ni halo anaranjado, según las tres nuevas referencias del usuario. Afecta solo
a los diez PNG de landing; las fuentes de marca y los recursos móviles se
conservan. La revisión de acabado es visual, no una prueba de fidelidad vectorial
del logo generado en tela.
