import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/auth_view_model.dart';
import '../widgets/auth_session_status.dart';

class AccessScreen extends ConsumerWidget {
  const AccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso y cuenta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 64),
                const SizedBox(height: 24),
                Text(state.startupMessage, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                if (state.startup.isReady)
                  AuthSessionStatus(session: state.session),
                const SizedBox(height: 16),
                const Text(
                  'El registro, inicio de sesión y perfil se implementarán en la siguiente etapa.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
