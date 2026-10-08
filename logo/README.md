# Icono de Entre Huellas

Originales exportados desde Figma. Se conservan aquí como fuentes de diseño.

- `Logo EntreHuellas 512 vector inner v2@2x.png`: 1024 × 1024, fuente de los iconos Android clásicos. Conserva textura y sombras del diseño.
- `Logo EntreHuellas 512 vector inner v2-16.svg`: vector con viewport 512 × 512, fuente del símbolo y gradiente de los iconos adaptativos.
- Las exportaciones PNG de 256, 512 y 1200 se conservan como variantes del original.

## Regeneración Android

Desde `flutter_application_entrehuellas`, con dependencias resueltas:

```powershell
flutter pub get --enforce-lockfile
./tool/generate_android_icons.ps1
```

`flutter_launcher_icons` 0.14.4 genera los PNG clásicos en las cinco densidades Android. El script genera después los VectorDrawable y los recursos adaptativos API 26+/monocromáticos API 33+. La app los utiliza mediante `@mipmap/ic_launcher` en su manifiesto.

La versión adaptativa mantiene las formas y los colores del SVG, utiliza un fondo sin esquinas precortadas y centra el símbolo con escala 0.72. Los filtros SVG de textura/sombra interna no se trasladan a VectorDrawable. La variante monocromática permite aplicar el tema del sistema cuando el launcher lo admite. Los recursos generados se versionan; no se editan por separado.

Si cambia el archivo fuente o su estructura, revisar la configuración y el adaptador. La generación verifica el viewport y los cinco paths esperados antes de producir recursos. El icono de iOS, web y escritorio conserva los recursos previos; esta integración se limita a Android.

## Comprobar el icono instalado

Detener y volver a ejecutar la app con el perfil **Entre Huellas - desarrollo local**. Los recursos del launcher requieren reinstalación/compilación, no hot reload. Revisar el icono en el launcher del emulador y sus recortes. Si el launcher mantiene una copia anterior, desinstalar la app de prueba y volver a ejecutarla; la desinstalación elimina sus datos locales y su sesión.

La validación efectivamente realizada se registra en [ESTADO.md](../docs/ESTADO.md).
