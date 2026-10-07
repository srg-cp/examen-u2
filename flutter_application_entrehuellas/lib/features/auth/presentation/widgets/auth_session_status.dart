import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_session.dart';

class AuthSessionStatus extends StatelessWidget {
  const AuthSessionStatus({required this.session, super.key});

  final AsyncValue<AuthSession?> session;

  @override
  Widget build(BuildContext context) => session.when(
    // Do not display a stale signed-in state during an observation error.
    skipError: false,
    data: (value) =>
        Text(value == null ? 'Sin sesión activa.' : 'Sesión activa.'),
    loading: () => const CircularProgressIndicator(),
    error: (_, _) => const Text('No se pudo recuperar el estado de la sesión.'),
  );
}
