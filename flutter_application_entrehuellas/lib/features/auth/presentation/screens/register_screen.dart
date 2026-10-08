import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/registration_view_model.dart';
import '../widgets/auth_page_layout.dart';
import '../widgets/registration_form.dart';
import '../widgets/registration_confirmation.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationViewModelProvider);
    final vm = ref.read(registrationViewModelProvider.notifier);
    void login() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/access');
      }
    }

    return PopScope(
      canPop: !state.isBusy,
      child: StaggerReveal(
        count: 9,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: AuthPageLayout(
            title: state.confirmationEmail == null ? 'Crear cuenta' : null,
            showClose: true,
            onClose: state.isBusy ? null : login,
            reveal: true,
            child: state.confirmationEmail != null
                ? RegistrationConfirmation(
                    state: state,
                    onResend: vm.resend,
                    onLogin: login,
                  )
                : RegistrationForm(
                    state: state,
                    onEdited: vm.edited,
                    onSubmit: vm.submit,
                  ),
          ),
        ),
      ),
    );
  }
}
