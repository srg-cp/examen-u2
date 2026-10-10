# Diseño de la interfaz: implementación y revisión

La norma obligatoria es [REGLAS_UI_UX.md](REGLAS_UI_UX.md). Su referencia son las pantallas actuales de Login, Crear cuenta, Recuperar contraseña, Revisa tu correo, Nueva contraseña y Contraseña actualizada. Este documento es un índice de implementación; no mantiene otra paleta ni reglas diferentes. Sustituye las propuestas antiguas de fondo crema/tarjetas menta y la UI retirada de Inicio.

## Componentes de referencia

Rutas relativas a `flutter_application_entrehuellas/lib`:

| Responsabilidad | Fuente |
| --- | --- |
| Layout, cabecera y scroll | `core/presentation/widgets/app_page_layout.dart` |
| Acción principal | `core/presentation/widgets/primary_action_button_style.dart` |
| Marca | `core/presentation/widgets/brand_mark.dart`, `brand_wordmark.dart` |
| Arranque horizontal con resorte | `core/presentation/widgets/startup_reveal.dart` |
| Cover y cambios de etapa | `core/presentation/widgets/cover_reveal.dart` |
| Stagger compartido | `core/presentation/widgets/stagger_reveal.dart` |
| Carga y atenuación | `core/presentation/widgets/loading_shimmer.dart` |
| Error de campo | `core/presentation/widgets/shake_field.dart` |
| Decoración de inputs de acceso | `features/auth/presentation/widgets/auth_input_decoration.dart` |
| Correo y OTP | `features/auth/presentation/widgets/email_code_confirmation.dart`, `email_code_input.dart` |
| Tema general | `core/theme/app_theme.dart` |

AuthPageLayout y authPrimaryButtonStyle delegan en las versiones compartidas de core. Mantienen geometría del flujo aprobado. No importar widgets de Auth desde otro módulo: extraer la responsabilidad común cuando corresponda.

## Referencias renderizadas

Desde la carpeta Flutter:

```powershell
flutter test --no-pub tool/capture_ui_preview.dart
```

Genera en `build/ui-preview` login, registro, solicitud de código, confirmaciones OTP, nueva contraseña, éxito, arranque y fases de cover/stagger/shimmer. Viewport normal 390 × 844, fuentes reales y repositorios sustituidos. Variantes pequeñas incluyen 320 × 350 con texto escala 2. Inicio provisional tiene `home.png` y `home_small.png`; conserva solo bienvenida y cierre de sesión hasta diseñar el módulo real.

Revisar capturas finales e intermedias, controles accesibles con teclado/scroll, estados de error y carga. Las capturas no prueban correo/Auth remoto ni fluidez en Android. Resultados y pendientes se registran en [ESTADO.md](ESTADO.md).

## Comportamientos conservados

El onboarding mantiene tres etapas después del primer ingreso y persistencia por cuenta según [ADR-004](decisiones/004-onboarding-por-cuenta.md), sin Omitir. Se conserva PageView y reveal textual, mascotas completas, margen de ilustración 12, alto proporcional .68 limitado a 180–460, indicadores 12/margen 5 y Continuar/Comenzar de radio 26/alto mínimo 68. Este diseño no sustituye la referencia normativa de acceso ni autoriza a copiarlo como otro estilo general.

Splash Android conserva fondo blanco y PNG 3D de marca. Su variante API 31+ usa margen proporcional de 33.3333% por lado para respetar la máscara. Debe verificarse tras recompilar/reinstalar con arranque frío; Hot Restart no actualiza recursos nativos. El resorte horizontal y el cover/stagger de Flutter se revisan tras Hot Restart.
