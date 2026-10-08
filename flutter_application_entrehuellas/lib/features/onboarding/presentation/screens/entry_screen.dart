import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/brand_wordmark.dart';
import '../../../auth/presentation/view_models/login_view_model.dart';
import '../view_models/entry_view_model.dart';

class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(entryViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: flow.hasError
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'No pudimos preparar tu cuenta. Revisa tu conexión e inténtalo de nuevo.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            ref.read(entryViewModelProvider.notifier).retry(),
                        child: const Text('Reintentar'),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(loginViewModelProvider.notifier).signOut(),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                )
              : Semantics(
                  label: 'Preparando tu cuenta',
                  liveRegion: true,
                  child: const ExcludeSemantics(
                    child: BrandWordmark(iconSize: 80, textSize: 32),
                  ),
                ),
        ),
      ),
    );
  }
}
