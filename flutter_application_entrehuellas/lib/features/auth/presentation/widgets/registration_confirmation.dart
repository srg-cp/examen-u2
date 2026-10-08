import 'package:flutter/material.dart';
import '../state/registration_view_state.dart';

class RegistrationConfirmation extends StatelessWidget {
  const RegistrationConfirmation({
    required this.state,
    required this.onResend,
    required this.onLogin,
    super.key,
  });
  final RegistrationViewState state;
  final VoidCallback onResend;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Icon(
        Icons.mark_email_unread_outlined,
        size: 72,
        color: Color(0xFF24282A),
      ),
      const SizedBox(height: 24),
      const Text(
        'Revisa tu correo',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111111),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        state.confirmationEmail!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF24282A),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Abre el enlace de confirmación de tu correo para continuar. Revisa también la carpeta de spam.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, height: 1.4, color: Color(0xFF747781)),
      ),
      const SizedBox(height: 28),
      OutlinedButton(
        onPressed: state.isBusy || state.resendSeconds > 0 ? null : onResend,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 16),
        ),
        child: Text(
          state.isBusy
              ? 'Reenviando…'
              : state.resendSeconds > 0
              ? 'Reenviar enlace en ${state.resendSeconds}s'
              : 'Reenviar enlace',
        ),
      ),
      if (state.message != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              state.message!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: state.isBusy ? null : onLogin,
        child: const Text(
          'Volver a iniciar sesión',
          style: TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
}
