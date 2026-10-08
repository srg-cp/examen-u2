import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/create_account_button.dart';
import '../widgets/auth_page_layout.dart';
import '../../domain/entities/social_provider.dart';
import '../view_models/login_view_model.dart';
import '../widgets/login_credentials_form.dart';
import '../widgets/social_sign_in_button.dart';

class AccessScreen extends ConsumerWidget {
  const AccessScreen({super.key});
  void _pending(BuildContext context, String title) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text(
        'Esta opción estará disponible en la siguiente etapa de acceso y cuenta.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginViewModelProvider);
    final vm = ref.read(loginViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthPageLayout(
        title: 'Iniciar sesión',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginCredentialsForm(
              isBusy: login.isBusy,
              feedback: login,
              onFieldEdited: vm.fieldEdited,
              onSubmit: vm.password,
              onRecover: () => _pending(context, 'Recuperar contraseña'),
            ),
            if (login.isError &&
                login.fieldIssue == null &&
                login.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    login.message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB53F48),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider(color: Color(0xFFE5E5EA))),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o continúa con',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF747781)),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Color(0xFFE5E5EA))),
              ],
            ),
            const SizedBox(height: 20),
            SocialSignInButton(
              label: 'Continuar con Google',
              icon: Image.asset(
                'assets/branding/google_g.png',
                width: 20,
                height: 20,
                excludeFromSemantics: true,
              ),
              onPressed: login.isBusy
                  ? null
                  : () => vm.social(SocialProvider.google),
            ),
            const SizedBox(height: 26),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  '¿No tienes una cuenta?',
                  style: TextStyle(fontSize: 15, color: Color(0xFF747781)),
                ),
                CreateAccountButton(enabled: !login.isBusy),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
