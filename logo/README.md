# Icono de Entre Huellas

Originales exportados desde Figma. Se conservan aquí como fuentes de diseño.

- `Logo EntreHuellas 512 vector inner v2@2x.png`: 1024 × 1024, fuente de los iconos Android clásicos. Conserva textura y sombras del diseño.
- `Logo EntreHuellas 512 vector inner v2-16.svg`: vector con viewport 512 × 512, fuente del símbolo y gradiente de los iconos adaptativos.
- Las exportaciones PNG de 256, 512 y 1200 se conservan como variantes del original.

## Regeneración Android

Desde `apps/mobile`, con dependencias resueltas:

```powershell
flutter pub get --enforce-lockfile
./tool/generate_android_icons.ps1
```

`flutter_launcher_icons` 0.14.4 genera los PNG clásicos en las cinco densidades Android. El script genera después los VectorDrawable y los recursos adaptativos API 26+/monocromáticos API 33+. La app los utiliza mediante `@mipmap/ic_launcher` en su manifiesto.

La versión adaptativa mantiene las formas y los colores del SVG, utiliza un fondo sin esquinas precortadas y centra el símbolo con escala 0.72. Los filtros SVG de textura/sombra interna no se trasladan a VectorDrawable. La variante monocromática permite aplicar el tema del sistema cuando el launcher lo admite. Los recursos generados se versionan; no se editan por separado.

Si cambia el archivo fuente o su estructura, revisar la configuración y el adaptador. La generación verifica el viewport y los cinco paths esperados antes de producir recursos. La generación actualizada incluye también catálogos iOS/macOS, web/PWA y Windows; no acredita ejecución o distribución en esas plataformas.

## Comprobar el icono instalado

Detener y volver a ejecutar la app con el perfil **Entre Huellas - desarrollo local**. Los recursos del launcher requieren reinstalación/compilación, no hot reload. Revisar el icono en el launcher del emulador y sus recortes. Si el launcher mantiene una copia anterior, desinstalar la app de prueba y volver a ejecutarla; la desinstalación elimina sus datos locales y su sesión.

La validación efectivamente realizada se registra en [ESTADO.md](../docs/ESTADO.md).

## Actualización global —17 de octubre de2026

Se mantienen intactas las fuentes actualizadas por el usuario. `only-black.svg` es la fuente geométrica del emblema monocromo usado como referencia de estampado blanco en ilustraciones; `only.svg` conserva la variante verde. La web conserva copia exacta del SVG completo en `apps/platform/public/brand.svg`; navegación usa el PNG oficial actualizado y el favicon deriva del PNG oficial256 para conservar su textura a tamaño pequeño. No se superpone el símbolo a las mascotas desde Vue/CSS: los emblemas blancos forman parte de los PNG regenerados mediante imagegen.

`apps/mobile/assets/branding/app_icon.png` y el splash Android son copias del PNG@2x actualizado. El generador existente ahora regenera también iconos iOS/web/Windows/macOS, además de Android, sin cambiar paquetes ni recrear apps. La ruta de fuentes se corrigió tras mover Flutter a apps/mobile. Los recursos para plataformas futuras no equivalen a builds o distribución verificados. Véase ESTADO para evidencia y límites.
