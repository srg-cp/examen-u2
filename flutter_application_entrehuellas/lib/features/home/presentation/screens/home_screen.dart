import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/view_models/login_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entre Huellas'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: login.isBusy
                ? null
                : () => ref.read(loginViewModelProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tu comunidad',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aquí encontrarás las mascotas y búsquedas de tu comunidad cuando estén disponibles.',
                  textAlign: TextAlign.center,
                ),
                if (login.isError)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(login.message!, textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
